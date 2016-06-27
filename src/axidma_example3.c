/* AXI DMA Example 2
*
* File operations on char device to mmap a kernel allocated buffer
*
*/


#include <linux/module.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#include <asm/errno.h>

#include <linux/slab.h>   // kmalloc
#include <xen/page.h>

#include <linux/kthread.h> // kthreads

#include <asm/uaccess.h>  // put_user
#include <asm/pgtable.h>

#include <linux/dmaengine.h>         // dma api
#include <linux/amba/xilinx_dma.h>   // axi dma driver

// First of all, you should make sure #include <linux/dma-mapping.h> is in your
// driver, which provides the definition of dma_addr_t. This type can hold any
// valid DMA address for the platform and should be used everywhere you hold a
// DMA address returned from the DMA mapping functions.
//
#include <linux/dma-mapping.h> 
#include <linux/platform_device.h>

#include "axidma_example3.h"


// FOPS FWDDECL //
static int device_open(struct inode *, struct file *);
static int device_release(struct inode *, struct file *);
static ssize_t device_read(struct file *, char *, size_t, loff_t *);
static ssize_t device_write(struct file *, const char *, size_t, loff_t *);
static int device_mmap(struct file *filp, struct vm_area_struct *vma);
static long device_ioctl(struct file *file, unsigned int cmd, unsigned long arg);

static int xilinx_axidmatest_probe(struct platform_device *pdev);
static int xilinx_axidmatest_remove(struct platform_device *pdev);

////////////////////////////////////////////////////////////////////////////////
//  GLOBALS  ///////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


static int s_major;            /* Major number assigned to our device driver */
static int s_device_open = 0;  /* Is device open?  Used to prevent multiple
                                        access to the device */

#define SUCCESS 0
#define WAIT 	1
#define NO_WAIT 0


// FOPS //
static struct file_operations fops = {
    .read = device_read,
    .write = device_write,
    .open = device_open,
    .release = device_release,
    .mmap = device_mmap,
    .unlocked_ioctl = device_ioctl,
};

// DEVICE ID //
static const struct of_device_id rfx_axidmatest_of_ids[] = {
	{ .compatible = "xlnx,axi-dma-test-1.00.a",},
	{}
};

// PLATFORM //
static struct platform_driver rfx_axidmatest_driver = {
	.driver = {
		.name = MODULE_NAME,
		.owner = THIS_MODULE,
		.of_match_table = rfx_axidmatest_of_ids,
	},
	.probe = xilinx_axidmatest_probe,
	.remove = xilinx_axidmatest_remove,
};


// DMA //
static struct dma_chan *tx_chan;
static struct dma_chan *rx_chan;
static struct completion tx_cmp;
static struct completion rx_cmp;
static dma_cookie_t tx_cookie;
static dma_cookie_t rx_cookie;
static dma_addr_t tx_dma_handle;
static dma_addr_t rx_dma_handle;

struct platform_device *g_pdev;

// RING //
struct xdma_ring_buffer{
    uint16_t      ring_size;
    uint16_t      data_size;    
    uint8_t       r_pos, w_pos;
    uint16_t       flags;
    char **       data;
    dma_addr_t *  handle;
    struct completion w_cmp;
    struct device *dev;
};


enum xdma_ring_buffer_flags {
    RING_BUFFER_INITIALIZED = 1 << 0,
    RING_BUFFER_OVERFLOW = 1 << 1,
};

struct xdma_ring_buffer xdma_ring;
#define BUFFER_SIZE 10000


////////////////////////////////////////////////////////////////////////////////
//  RING  ////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


static int xdma_ring_init(struct platform_device *pdev, 
                          struct xdma_ring_buffer *b, 
                          uint32_t ring_size,
                          uint32_t data_size) 
{
    int i;
    int status =0;
    
    if(!b || !pdev || !ring_size || !data_size) return -EINVAL;
    b->data   = kzalloc(ring_size * sizeof(char *),GFP_KERNEL);
    b->handle = kmalloc(ring_size * sizeof(dma_addr_t),GFP_KERNEL);
    b->dev = &pdev->dev;
    b->r_pos = b->w_pos = 0;
    init_completion(&b->w_cmp);
    for(i=0; i<ring_size; ++i) {
        b->data[i] = dma_zalloc_coherent(b->dev, data_size,
                                              &b->handle[i], GFP_KERNEL);
        if(!b->data[i]) ++status;
    }
    if (status != ring_size) return -ENOMEM;
    return 1;
}

static void xdma_ring_free(struct xdma_ring_buffer *b) {
    int i;
    if(!b) return;        
    for(i=0; i<b->ring_size; ++i) {
        if(b->data[i])
            dma_free_coherent(b->dev, BUFFER_SIZE, 
                              b->data[i], b->handle[i]);
    }
}

static int xdma_ring_hasdata(const struct xdma_ring_buffer *b) {
    return b->r_pos != b->w_pos;
}

static int xdma_ring_writefwd(struct xdma_ring_buffer *b) {
    // non stopping write position advance //
//    complete(&b->w_cmp);
    b->w_pos++;
//    init_completion(&b->w_cmp);
    if( (b->w_pos - b->r_pos) % b->ring_size == 1 ) {        
        b->flags |= RING_BUFFER_OVERFLOW;        
        return -1;
    } 
    return SUCCESS;
}

static int xdma_ring_readfwd(struct xdma_ring_buffer *b) {    
    if( (b->w_pos - b->r_pos) % b->ring_size != -1 ) {
        b->r_pos++;
        return SUCCESS;
    } 
    else return -1;
}


////////////////////////////////////////////////////////////////////////////////
//  TEST_TRANSFER  /////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

/* Handle a callback and indicate the DMA transfer is complete to another
 * thread of control
 */
static void axidma_test_transfer_sync_callback(void *completion)
{
	complete(completion);
}

/* Prepare a DMA buffer to be used in a DMA transaction, submit it to the DMA engine 
 * to queued and return a cookie that can be used to track that status of the 
 * transaction
 */
static dma_cookie_t axidma_test_transfer_prep_buffer(struct dma_chan *chan, dma_addr_t buf, size_t len, 
					enum dma_transfer_direction dir, struct completion *cmp) 
{
	enum dma_ctrl_flags flags = DMA_CTRL_ACK | DMA_PREP_INTERRUPT;
	struct dma_async_tx_descriptor *chan_desc;
	dma_cookie_t cookie;

	chan_desc = dmaengine_prep_slave_single(chan, buf, len, dir, flags);
	if (!chan_desc) {
		printk(KERN_ERR "dmaengine_prep_slave_single error\n");
		cookie = -EBUSY;
	} else {
		chan_desc->callback = axidma_test_transfer_sync_callback;
		chan_desc->callback_param = cmp;
		cookie = dmaengine_submit(chan_desc);	
	}
	return cookie;
}

/* Start a DMA transfer that was previously submitted to the DMA engine and then
 * wait for it complete, timeout or have an error
 */
static void axidma_start_test_transfer(struct dma_chan *chan, struct completion *cmp, 
					dma_cookie_t cookie, int wait)
{
	unsigned long timeout = msecs_to_jiffies(3000);
	enum dma_status status;

	init_completion(cmp);
	dma_async_issue_pending(chan);

	if (wait) {
		printk("Waiting for DMA to complete...\n");
		timeout = wait_for_completion_timeout(cmp, timeout);
		status = dma_async_is_tx_complete(chan, cookie, NULL, NULL);
		if (timeout == 0)  {
			printk(KERN_ERR "DMA timed out\n");
		} else if (status != DMA_COMPLETE) {
			printk(KERN_ERR "DMA returned completion callback status of: %s\n",
			       status == DMA_ERROR ? "error" : "in progress");
		}
	}
}


static int axidma_test_transfer(unsigned int dma_length)
{	
	int i, status = 0;

    char *src_dma_buffer = dma_alloc_coherent(tx_chan->device->dev,dma_length,&tx_dma_handle,GFP_KERNEL);
    char *dest_dma_buffer = dma_alloc_coherent(rx_chan->device->dev,dma_length,&rx_dma_handle,GFP_KERNEL);
        
	if (!src_dma_buffer || !dest_dma_buffer) {
		printk(KERN_ERR "Allocating DMA memory failed\n");
		return -EIO;
	}

	for (i = 0; i < dma_length; i++) 
		src_dma_buffer[i] = i;

	tx_dma_handle = dma_map_single(tx_chan->device->dev, src_dma_buffer, dma_length, DMA_TO_DEVICE);	
	rx_dma_handle = dma_map_single(rx_chan->device->dev, dest_dma_buffer, dma_length, DMA_FROM_DEVICE);	
    tx_cookie = axidma_test_transfer_prep_buffer(tx_chan, tx_dma_handle, dma_length, DMA_MEM_TO_DEV, &tx_cmp);
	rx_cookie = axidma_test_transfer_prep_buffer(rx_chan, rx_dma_handle, dma_length, DMA_DEV_TO_MEM, &rx_cmp);

	if (dma_submit_error(rx_cookie) || dma_submit_error(tx_cookie)) {
		printk(KERN_ERR "xdma_prep_buffer error\n");
		return -EIO;
	}

	printk(KERN_INFO "Starting DMA transfers\n");

	axidma_start_test_transfer(rx_chan, &rx_cmp, rx_cookie, NO_WAIT);
	axidma_start_test_transfer(tx_chan, &tx_cmp, tx_cookie, WAIT);

	dma_unmap_single(rx_chan->device->dev, rx_dma_handle, dma_length, DMA_FROM_DEVICE);	
	dma_unmap_single(tx_chan->device->dev, tx_dma_handle, dma_length, DMA_TO_DEVICE);

	/* Verify the data in the destination buffer matches the source buffer */
	for (i = 0; i < dma_length; i++) {
		if (dest_dma_buffer[i] != src_dma_buffer[i]) {
			printk(KERN_INFO "DMA transfer failure");
            status = -EIO;
			break;	
		}
	}

	printk(KERN_INFO "DMA bytes sent: %d\n", dma_length);
    dma_free_coherent(tx_chan->device->dev,dma_length,src_dma_buffer,tx_dma_handle);
    dma_free_coherent(rx_chan->device->dev,dma_length,dest_dma_buffer,rx_dma_handle);
    
    return status;    
}


////////////////////////////////////////////////////////////////////////////////
//  TEST_RING_TRANSFER  ////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

static struct xdma_ring_buffer src_ring, dst_ring;

static struct completion writer_completion;

static int axidma_test_ring_writer_handler(void *xdma_ring_buffer) {
    static int counter = 0;
    int i;
    struct xdma_ring_buffer *r = (struct xdma_ring_buffer *)xdma_ring_buffer;
    while( counter < 1000000 ) {
        xdma_ring_writefwd(r);
        int *data = (int*)(r->data[r->w_pos]);
        for ( i=0; i < r->data_size/4 ; ++i ) 
            data[i] = counter++;
    }    
    complete(&writer_completion);
    return SUCCESS;
}

static int axidna_test_ring_startWriteThread(struct xdma_ring_buffer *ring) {
    return 0;
}


static void axidma_test_ring_read_callback(void *completion)
{
    
}

static void axidma_test_ring_write_callback(void * _tx_desc)
{    
//    while( xdma_ring_readfwd(&src_ring) != SUCCESS )
//        wait_for_completion(&src_ring.w_cmp);
    
    printk("--> DMA chunk wrote\n");
    int *data = (int *)src_ring.data[src_ring.r_pos];
    int len = src_ring.data_size;
    struct dma_async_tx_descriptor * tx = (struct dma_async_tx_descriptor *)_tx_desc;
    tx = dmaengine_prep_slave_single(tx->chan, data, len, DMA_TO_DEVICE, tx->flags);
    tx->callback = axidma_test_ring_write_callback;
    tx->callback_param = tx;
    tx->cookie = dmaengine_submit(tx);
    dma_async_issue_pending(tx_chan);
}


static struct dma_async_tx_descriptor tx_desc;

static int axidma_test_ring(void) {

    static const int test_ring_size = 10;

    
    if ( !xdma_ring_init(g_pdev, &src_ring, test_ring_size, BUFFER_SIZE) ) {
        printk(KERN_ERR "error initializing ring buffers\n");
        return -EIO;
    }    
    if (!xdma_ring_init(g_pdev, &dst_ring, test_ring_size, BUFFER_SIZE) ) {
        printk(KERN_ERR "error initializing ring buffers\n");
        xdma_ring_free(&src_ring);
        return -EIO;
    }
    
    // start writing thread into src_ring //
    struct task_struct *task;
    init_completion(&writer_completion);
    axidma_test_ring_writer_handler(&src_ring);
//    task = kthread_create( axidma_test_ring_writer_handler, &src_ring,
//                           "writer_ring_thread");
//    wake_up_process(task);

    wait_for_completion(&writer_completion);
    
//    dma_async_tx_descriptor_init(&tx_desc, tx_chan);    
//    axidma_test_ring_read_callback(&tx_desc);

    return SUCCESS;
}


////////////////////////////////////////////////////////////////////////////////
//  IOCTLS  ////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

static int device_ioctl_testtrasfer(unsigned int dma_length)
{
    // TEST DMA FUNCTIONALITY //
    if(!dma_length) dma_length = 1*1024*1024; //1MB
    return axidma_test_transfer(dma_length);    
}





////////////////////////////////////////////////////////////////////////////////
//  FOPS  //////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


// OPEN //
static int device_open(struct inode *inode, struct file *file)
{
   int err;
   dma_cap_mask_t mask;
   
   /* Step 1) Allocate DMA slave channels */
   
   if (s_device_open) return -EBUSY;
   s_device_open++;

   dma_cap_zero(mask);
   dma_cap_set(DMA_SLAVE | DMA_PRIVATE, mask);
   
   tx_chan = dma_request_slave_channel(&g_pdev->dev, "dma0");
   if (IS_ERR(tx_chan)) {
       pr_err("xilinx_dmatest: No Tx channel\n");
       dma_release_channel(tx_chan);
       return -EFAULT;
   }

   rx_chan = dma_request_slave_channel(&g_pdev->dev, "dma1");
   if (IS_ERR(rx_chan)) {
       err = PTR_ERR(rx_chan);
       pr_err("xilinx_dmatest: No Rx channel\n");
       dma_release_channel(tx_chan);
       dma_release_channel(rx_chan);
       return -EFAULT;
   }    
   
   return SUCCESS;
}


// CLOSE //
static int device_release(struct inode *inode, struct file *file)
{
   s_device_open --;
   dma_release_channel(rx_chan);
   dma_release_channel(tx_chan);
   return 0;
}


// READ //
static ssize_t device_read(struct file *filp, char *buffer, size_t length, 
                           loff_t *offset)
{
   int bytes_read = 0;
   const char *msg = "use mmap to access device memory\n";
   const char *msg_Ptr = msg;
   while (length && *msg_Ptr)  {
         put_user(*(msg_Ptr++), buffer++);
         length--; bytes_read++;
   }
   return bytes_read;
}


// WRITE //
static ssize_t device_write(struct file *filp, const char *buff, size_t len, 
                            loff_t *off)
{
   printk ("<1>Sorry, this operation isn't supported.\n");
   return -EINVAL;
}


// MMAP //
static int device_mmap(struct file *filp, struct vm_area_struct *vma)
{
	int result;
	unsigned long requested_size;

    requested_size = vma->vm_end - vma->vm_start;
	printk(KERN_DEBUG "<%s> file: mmap()\n", DEVICE_NAME);
	printk(KERN_DEBUG "<%s> file: memory size reserved: %d, mmap size requested: %lu\n",
           MODULE_NAME, BUFFER_SIZE, requested_size);

	if (requested_size > BUFFER_SIZE) {
		printk(KERN_ERR "<%s> Error: %d reserved != %lu requested)\n",
		       MODULE_NAME, BUFFER_SIZE, requested_size);
		return -EAGAIN;
	}
    
	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
    result = remap_pfn_range(vma, vma->vm_start, virt_to_pfn(xdma_ring.data[0]),
				 requested_size, vma->vm_page_prot);
    
	if (result) {
		printk(KERN_ERR
		       "<%s> Error: in calling remap_pfn_range: returned %d\n",
		       MODULE_NAME, result);
		return -EAGAIN;
	}
	return 0;
}


static long device_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
{
    u32 devices;
    int status;
    
    switch (cmd) {
	case XDMA_GET_NUM_DEVICES:
		printk(KERN_DEBUG "<%s> ioctl: XDMA_GET_NUM_DEVICES\n", MODULE_NAME);
		devices = 1;
		if (copy_to_user((u32 *) arg, &devices, sizeof(u32)))
			return -EFAULT;
		break;
    case XDMA_TEST_TRASFER:
        printk(KERN_DEBUG "<%s> ioctl: XDMA_TEST_TRASFER\n", MODULE_NAME);
        status = -1;
        status = device_ioctl_testtrasfer(0);
		if (copy_to_user((u32 *) arg, &status, sizeof(u32)))
			return -EFAULT;        
        break;
    case XDMA_TEST_RING:
        printk(KERN_DEBUG "<%s> ioctl: XDMA_TEST_RING\n", MODULE_NAME);
        axidma_test_ring();
        break;        
        
    default:
        return -EAGAIN;
		break;        
    }    
    return 0;
}





////////////////////////////////////////////////////////////////////////////////
//  PLATFORM  //////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


static int xilinx_axidmatest_probe(struct platform_device *pdev)
{
    printk("probing %s ...\n",pdev->name);

    // store pdevice //
    g_pdev = pdev;
    
    
    
    // CHAR DEV //
    printk("registering char dev %s ...\n",DEVICE_NAME);
    s_major = register_chrdev(0, DEVICE_NAME, &fops);
    
    if (s_major < 0) {
        printk ("Registering the character device failed with %d\n", s_major);
        return s_major;
    }
    
    printk(KERN_NOTICE "I was assigned major number %d.  To talk to\n", s_major);
    printk(KERN_NOTICE "the driver, create a dev file with\n");
    printk(KERN_NOTICE "'mknod /dev/hello c %d 0'.\n", s_major);
    printk(KERN_NOTICE "Try various minor numbers.  Try to cat and echo to\n");
    printk(KERN_NOTICE "the device file.\n");
    printk(KERN_NOTICE "Remove the device file and module when done.\n");
    
    
    // INIT RING //
    xdma_ring_init(pdev,&xdma_ring,RING_SIZE,BUFFER_SIZE);
    
    return 0;
}

static int xilinx_axidmatest_remove(struct platform_device *pdev)
{
    printk("removing %s ...\n",pdev->name);    
    xdma_ring_free(&xdma_ring);
    
    printk("unregistering char dev ...\n");
    unregister_chrdev(s_major, DEVICE_NAME);
    
	return 0;
}


static int __init axidma_init(void)
{
    printk(KERN_INFO "initializing module %s\n",rfx_axidmatest_driver.driver.name);
    return platform_driver_register(&rfx_axidmatest_driver);
}

static void __exit axidma_exit(void)
{
	printk(KERN_INFO "exiting module %s\n",rfx_axidmatest_driver.driver.name);
    platform_driver_unregister(&rfx_axidmatest_driver);
}

module_init(axidma_init);
module_exit(axidma_exit);
MODULE_LICENSE("GPL");
