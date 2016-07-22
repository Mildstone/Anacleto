


/* AXI DMA Example 4
*
* Ring dma transfer
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

#include <linux/delay.h>
#include <linux/kthread.h>
#include <linux/poll.h>
#include <linux/wait.h>

#include <linux/list.h>

#include "axidma_example5.h"

////////////////////////////////////////////////////////////////////////////////
//  DECLARATIONS  //////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


// FOPS FWDDECL //
static int device_open(struct inode *, struct file *);
static int device_release(struct inode *, struct file *);
static ssize_t device_read(struct file *, char *, size_t, loff_t *);
static ssize_t device_write(struct file *, const char *, size_t, loff_t *);
static int device_mmap(struct file *filp, struct vm_area_struct *vma);
static long device_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
unsigned int device_poll(struct file *file, struct poll_table_struct *p);

// FOPS //
static struct file_operations fops = {
    .read = device_read,
    .write = device_write,
    .open = device_open,
    .release = device_release,
    .mmap = device_mmap,
    .unlocked_ioctl = device_ioctl,
    .poll = device_poll,
};



struct example5_ring_buffer {
    struct example5_dma_buffer user_data;
    struct list_head node;
    u8 *data;
    u32 mmap_index;
    dma_addr_t handle;
    dma_cookie_t cookie;
};

struct example5_ring {
    struct list_head node;
    struct list_head buffers;
    u32 buffer_size;
    u32 len;
    enum dma_transfer_direction dir;
    struct example5_ring_buffer *w_pos;
    struct example5_ring_buffer *r_pos;
    struct wait_queue_head_t  *w_wait;
    struct wait_queue_head_t  *r_wait;
    struct completion *cmp;
//    struct dma_chan *channel;
};

static struct dma_chan *rx_chan, *tx_chan;
static LIST_HEAD(rings);
static struct example5_ring *last_ring_requested = NULL;


static void init_example5_ring (struct example5_ring *r) {
    INIT_LIST_HEAD(&r->buffers);
    r->buffer_size = BUFSIZE;
    r->len = 0;
    r->dir = DMA_DEV_TO_MEM;
    r->w_pos = NULL;
    r->r_pos = NULL;
    r->w_wait = NULL;
    r->r_wait = NULL;
    r->cmp = NULL;
//    r->channel = NULL;
}








////////////////////////////////////////////////////////////////////////////////
//  DMA TRANSFER  //////////////////////////////////////////////////////////////
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
    enum dma_ctrl_flags flags = /*DMA_CTRL_ACK |*/ DMA_PREP_INTERRUPT;
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
    unsigned long timeout = msecs_to_jiffies(10000);
    enum dma_status status;

    init_completion(cmp);
    dma_async_issue_pending(chan);

    if (wait) {
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


////////////////////////////////////////////////////////////////////////////////
//  RING INIT  /////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


///
/// \brief example5_request_channels
/// \param dev dma device
/// \return errors if any
///
static int example5_request_channels(struct device *dev) {
    int err = 0;
    //    struct dma_slave_config tx_conf;
    //    struct dma_slave_config rx_conf;

    /* Allocate DMA slave channels */
    tx_chan = dma_request_slave_channel(dev, "dma0");
    if (IS_ERR(tx_chan)) {
        err = PTR_ERR(tx_chan);
        pr_err("xilinx_dmatest: No Tx channel\n");
        dma_release_channel(tx_chan);
        return -EFAULT;
    }

    rx_chan = dma_request_slave_channel(dev, "dma1");
    if (IS_ERR(rx_chan)) {
        err = PTR_ERR(rx_chan);
        pr_err("xilinx_dmatest: No Rx channel\n");
        dma_release_channel(tx_chan);
        dma_release_channel(rx_chan);
        return -EFAULT;
    }
    return err;
}


///
/// \brief example5_release_channels
/// \return 0
///
static int example5_release_channels(void) {
    dma_release_channel(rx_chan);
    dma_release_channel(tx_chan);
    return 0;
}


///
/// \brief example5_request_ring
/// \param len: nuber of buffers
/// \param size: size requested for each buffer
/// \return
///
static int example5_initialize_ring(struct dma_chan *channel, int len, int size) {
    int i,j;
    int * data;
    struct device *dev = channel->device->dev;
    struct example5_ring *ring;

    printk( KERN_DEBUG"entering request for ring\n");
    ring = (struct example5_ring *)
            kmalloc(sizeof(struct example5_ring),GFP_KERNEL);

    // init buffers list
    init_example5_ring(ring);
    ring->buffer_size = size;

    // allocate buffers
    printk(KERN_DEBUG"allocating buffers %dx%d\n", len, size);
    for(i=0; i<len; i++) {
        struct example5_ring_buffer *node = (struct example5_ring_buffer *)
                kmalloc(sizeof(struct example5_ring_buffer),GFP_KERNEL);
        node->data = dma_alloc_coherent(dev,size,&node->handle,GFP_KERNEL);
        node->mmap_index = 0;
        if(!node->data || !node->handle) {
            printk(KERN_ERR"unable to allocate dma ring buffers\n");
            break;
        } else {
            list_add((struct list_head*)node,&ring->buffers);
            ++ring->len;
            node->mmap_index = i; // assinged automatically //
            // only for testing buffer content //
            data = (int*)node->data;
            for(j=0;j<size/sizeof(int);++j) data[j] = j;
        }
    }

    // setting current requested ring
    last_ring_requested = ring;
    ring->r_pos = list_first_entry(&ring->buffers,struct example5_ring_buffer,node);
    ring->w_pos = list_first_entry(&ring->buffers,struct example5_ring_buffer,node);

    // add to list
    list_add((struct list_head*)ring,&rings);
    return 0;
}







///
/// \brief example5_release_rings frees allocate bffers
/// \return 0
///
static int example5_release_all_rings(struct dma_chan *channel) {
    struct device *dev = channel->device->dev;
    struct example5_ring *r;
    struct example5_ring_buffer *n;
    list_for_each_entry(r,&rings,node){
        list_for_each_entry(n,&r->buffers,node) {
            dma_free_coherent(dev,r->buffer_size,n->data,n->handle);
            r->len--;
        }
    }
    return 0;
}




////////////////////////////////////////////////////////////////////////////////
//  FOPS  //////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

static int s_major;            /* Major number assigned to our device driver */
static int s_device_open = 0;  /* Is device open?  Used to prevent multiple
                                        access to the device */

// OPEN //
static int device_open(struct inode *inode, struct file *file)
{
    if (s_device_open) return -EBUSY;
    s_device_open++;
    return 0;
}


// CLOSE //
static int device_release(struct inode *inode, struct file *file)
{
    s_device_open --;
    return 0;
}


// READ //
static ssize_t device_read(struct file *filp, char *buffer, size_t length,
                           loff_t *offset)
{
    static const char *msg = "use mmap to access device memory\n";
    int bytes_read = 0;
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
    printk ("<1>Sorry, this operation isn't supported yet.\n");
    return -EINVAL;
}

// MMAP //
static int device_mmap(struct file *filp, struct vm_area_struct *vma) {
    int status = 0;
    int pos = 0;
    unsigned long requested_size = vma->vm_end - vma->vm_start;
    struct example5_ring_buffer *node = last_ring_requested->r_pos;
    pos = node->mmap_index;

    if(requested_size < last_ring_requested->buffer_size) {
        printk(KERN_ERR"requested wrong size: %d vs %d\n",
               (int)requested_size, last_ring_requested->buffer_size);
        return EAGAIN;
    }

    // remap pages source //
    vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
    status = remap_pfn_range(vma, vma->vm_start,
                             virt_to_pfn(node->data),
                             last_ring_requested->buffer_size, vma->vm_page_prot);
    if (status) {
        printk(KERN_ERR
               "<%s> Error: in calling remap_pfn_range: returned %d\n",
               MODULE_NAME, status);
        return -EAGAIN;
    }

    last_ring_requested->r_pos = list_next_entry(last_ring_requested->r_pos,node);
    last_ring_requested->r_pos->mmap_index = pos+1;
    return status;
}

// IOCTL //
static long device_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
{
    int status = 0;
    struct example5_dma_ring ring;
    struct dma_chan *chan;

    switch (cmd) {
    case XDMA_REQUEST_RING:
        printk(KERN_DEBUG "<%s> ioctl: XDMA_REQUEST_RING\n", MODULE_NAME);
        status = copy_from_user(&ring,(const void *)arg, sizeof(struct example5_dma_ring));
        if(status) return -EFAULT;
        chan = ring.flags & TX_CHANNEL ? tx_chan : rx_chan;
        example5_initialize_ring(chan,ring.ring_size,ring.buffer_size);
        break;

    case XDMA_RELEASE_RINGS:
        printk(KERN_DEBUG "<%s> ioctl: XDMA_RLEASE_RING\n", MODULE_NAME);
        example5_release_all_rings(tx_chan);
        break;

    case XDMA_REQUEST_BUFFER:
        printk(KERN_DEBUG "<%s> ioctl: XDMA_REQUEST_BUFFER\n", MODULE_NAME);
        break;

    case XDMA_REQUEST_TO_SEND:
        printk(KERN_DEBUG "<%s> ioctl: XDMA_REQUEST_TO_SEND\n", MODULE_NAME);
        break;

    default:
        return -EAGAIN;
        break;
    }
    return status;
}

// POLL //
unsigned int device_poll(struct file *file, struct poll_table_struct *p) {
    unsigned int mask=0;


    mask |= POLLIN | POLLRDNORM;

    return mask;
}


////////////////////////////////////////////////////////////////////////////////
//  MODULE  ////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


static int example5_probe(struct platform_device *pdev)
{
    int err = 0;

    printk("probing %s ...\n",pdev->name);

    // CHAR DEV //
    printk("registering char dev %s ...\n",DEVICE_NAME);
    s_major = register_chrdev(0, DEVICE_NAME, &fops);
    if (s_major < 0) {
        printk ("Registering the character device failed with %d\n", s_major);
        return s_major;
    }
    printk(KERN_NOTICE "mknod /dev/xdma c %d 0\n", s_major);

    // REQUST CHANNELS //
    err = example5_request_channels(&pdev->dev);

    return err;
}

static int example5_remove(struct platform_device *pdev)
{
    printk("unregistering char dev ...\n");
    example5_release_channels();
    unregister_chrdev(s_major, DEVICE_NAME);
    return 0;
}

static const struct of_device_id example5_of_ids[] = {
{ .compatible = "xlnx,axi-dma-test-1.00.a",}, {} };

static struct platform_driver example5_driver = {
    .driver = {
        .name = "example5",
        .owner = THIS_MODULE,
        .of_match_table = example5_of_ids,
    },
    .probe = example5_probe,
    .remove = example5_remove,
};

static int __init example5_init(void)
{
    printk(KERN_INFO "example5 module initialized\n");
    return platform_driver_register(&example5_driver);
}

static void __exit example5_exit(void)
{
    printk(KERN_INFO "example5 module exited\n");
    platform_driver_unregister(&example5_driver);
}

module_init(example5_init);
module_exit(example5_exit);
MODULE_LICENSE("GPL");

















//////////////////////////////////////////////////////////////////////////////////
////  THREAD  ////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////



//// RING //
//struct xdma_ring_buffer{
//    uint16_t      ring_size;
//    uint16_t      data_size;
//    uint8_t       r_pos, w_pos;
//    uint16_t      flags;
//    u8 **         data;
//    dma_addr_t *  handle;
//    struct completion w_cmp;
//    struct device *dev;
////    struct spinlock lock;

//    // dmaengine types //
//    enum dma_transaction_type type;

//    // scheduler types //
//    struct task_struct *task;
//};


//enum xdma_ring_buffer_flags {
//    RING_BUFFER_INITIALIZED = 1 << 0,
//    RING_BUFFER_OVERFLOW = 1 << 1,
//};

//struct xdma_ring_buffer xdma_ring;


//////////////////////////////////////////////////////////////////////////////////
////  RING  ////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////


//static int xdma_ring_init(struct platform_device *pdev,
//                          struct xdma_ring_buffer *b,
//                          uint32_t ring_size,
//                          uint32_t data_size)
//{
//    int i;
//    int status =0;

//    if(!b || !pdev || !ring_size || !data_size) return -EINVAL;
//    b->data   = kzalloc(ring_size * sizeof(char *),GFP_KERNEL);
//    b->handle = kmalloc(ring_size * sizeof(dma_addr_t),GFP_KERNEL);

//    b->dev = &pdev->dev;
//    b->r_pos = b->w_pos = 0;
//    b->ring_size = ring_size;
//    b->data_size = data_size;
//    init_completion(&b->w_cmp);
//    for(i=0; i<ring_size; ++i) {
//        b->data[i] = dma_zalloc_coherent(b->dev, data_size,
//                                         &b->handle[i], GFP_KERNEL);
//        if(!b->data[i]) ++status;
//    }
//    if (status != ring_size) return -ENOMEM;
//    else b->flags |= RING_BUFFER_INITIALIZED;
//    return 1;
//}

//static void xdma_ring_free(struct xdma_ring_buffer *b) {
//    int i;
//    if(!b) return;
//    for(i=0; i<b->ring_size; ++i) {
//        if(b->data[i])
//            dma_free_coherent(b->dev, BUFFER_SIZE,
//                              b->data[i], b->handle[i]);
//    }
//}

//static int xdma_ring_hasdata(const struct xdma_ring_buffer *b) {
//    return b->r_pos != b->w_pos;
//}

//static int xdma_ring_writefwd(struct xdma_ring_buffer *b) {
//    // non stopping write position advance //
//    complete(&b->w_cmp);
//    b->w_pos = (b->w_pos + 1) % b->ring_size;
//    reinit_completion(&b->w_cmp);
//    if( (b->w_pos - b->r_pos) % b->ring_size == 1 ) {
//        b->flags |= RING_BUFFER_OVERFLOW;
//        return -1;
//    }
//    return SUCCESS;
//}

//static int xdma_ring_readfwd(struct xdma_ring_buffer *b) {
//    if( (b->w_pos - b->r_pos) % b->ring_size != -1 ) {
//        b->r_pos = (b->r_pos + 1) % b->ring_size;
//        return SUCCESS;
//    }
//    else return -EAGAIN;
//}




//////////////////////////////////////////////////////////////////////////////////
////  TEST_RING_TRANSFER  ////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

//static struct xdma_ring_buffer src_ring, dst_ring;

//static struct completion writer_completion;

//static int axidma_test_ring_writer_handler(void *xdma_ring_buffer) {
//    static int counter = 0;
//    int i;
//    struct xdma_ring_buffer *r = (struct xdma_ring_buffer *)xdma_ring_buffer;
//    while( counter < 200000 ) {
//        xdma_ring_writefwd(r);
//        int *data = (int*)(r->data[r->w_pos]);
//        for ( i=0; i < r->data_size/4 ; ++i )
//            data[i] = counter++;
//    }
//    complete(&writer_completion);
//    return SUCCESS;
//}


//static void axidma_test_ring_read_callback(void * _rx_desc)
//{
//    xdma_ring_writefwd(&dst_ring);

//    printk("r");

//    int *data = (int *)dst_ring.data[dst_ring.r_pos];
//    int len = dst_ring.data_size;
//    struct dma_async_tx_descriptor * rx = (struct dma_async_tx_descriptor *)_rx_desc;
//    dst_ring.handle = dma_map_single(rx->chan, data, len, DMA_DEV_TO_MEM);
//    rx = dmaengine_prep_slave_single(rx->chan, dst_ring.handle, len, DMA_DEV_TO_MEM, rx->flags);
//    memcpy(_rx_desc,rx, sizeof (struct dma_async_tx_descriptor) );
//    if (!rx) {
//		printk(KERN_ERR "prep_slave_single error\n");
//		rx->cookie = -EBUSY;
//	} else {
//        rx->callback = axidma_test_ring_read_callback;
//        rx->callback_param = _rx_desc;
//        rx->cookie = dmaengine_submit(rx);
//    }
////    dma_async_issue_pending(rx_chan);
//}

//static void axidma_test_ring_write_callback(void * _tx_desc)
//{
//    while( xdma_ring_readfwd(&src_ring) != SUCCESS )
//        wait_for_completion(&src_ring.w_cmp);

//    printk("w");


//    int *data = (int *)src_ring.data[src_ring.r_pos];
//    int len = src_ring.data_size;
//    struct dma_async_tx_descriptor * tx = (struct dma_async_tx_descriptor *)_tx_desc;

//    enum dma_status status;

////    status = dma_async_is_tx_complete(chan, cookie, NULL, NULL);

//    tx = dmaengine_prep_slave_single(tx->chan, data, len, DMA_MEM_TO_DEV, tx->flags);
//    memcpy(_tx_desc,tx, sizeof (struct dma_async_tx_descriptor) );
//    if (!tx) {
//		printk(KERN_ERR "prep_slave_single error\n");
//		tx->cookie = -EBUSY;
//	} else {
//        tx->callback = axidma_test_ring_write_callback;
//        tx->callback_param = _tx_desc;
//        tx->cookie = dmaengine_submit(tx);
//    }
////    dma_async_issue_pending(tx_chan);
//}


//static struct dma_async_tx_descriptor tx_desc;
//static struct dma_async_tx_descriptor rx_desc;

//static int axidma_test_ring(void) {

//    int i=0;
//    static const int test_ring_size = 10;

//    if ( !xdma_ring_init(g_pdev, &src_ring, test_ring_size, BUFFER_SIZE) ) {
//        printk(KERN_ERR "error initializing ring buffers\n");
//        return -EIO;
//    }
//    if (!xdma_ring_init(g_pdev, &dst_ring, test_ring_size, BUFFER_SIZE) ) {
//        printk(KERN_ERR "error initializing ring buffers\n");
//        xdma_ring_free(&src_ring);
//        return -EIO;
//    }

//    printk("INIT PASSED\n");

//    // start writing thread into src_ring //
//    struct task_struct *task;
//    init_completion(&writer_completion);

////    axidma_test_ring_writer_handler(&src_ring);
////    printk("RING FILL PASSED\n");

////    task = kthread_create( axidma_test_ring_writer_handler, &src_ring,
////                           "writer_ring_thread");
////    wake_up_process(task);
////    printk("RING THREAD STARTED ... waiting for completion\n");

//    enum dma_ctrl_flags flags = DMA_PREP_INTERRUPT | DMA_PREP_CONTINUE | DMA_PREP_FENCE;

//    dma_async_tx_descriptor_init(&rx_desc, rx_chan);
//    rx_desc.flags = flags;
//    axidma_test_ring_read_callback(&rx_desc);

//    dma_async_tx_descriptor_init(&tx_desc, tx_chan);
//    tx_desc.flags = flags;
//    axidma_test_ring_write_callback(&tx_desc);

//    for(i=0; i<50; ++i) {
//        xdma_ring_writefwd(&src_ring);
//        dma_async_issue_pending(rx_chan);
//        dma_async_issue_pending(tx_chan);
//        mdelay(100);
//    }

////    wait_for_completion(&writer_completion);
//    printk("\nRING THREAD COMPLETED\n");

//    return SUCCESS;
//}


