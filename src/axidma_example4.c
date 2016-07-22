/* AXI DMA Example 4
*
* This example demonstrates the use of dma transfer in two ways:
* 
* 1) A single send/receive short circuit loop PS->PL->PS where the overall
*    memory involved are allocated and handled within the kernel.
* 
* 2) Send and receive a mmapped memory, the user can do the tranfer directly.
*    See: test_example3.c
*
* 
* NOTE: Both methods are using a coherent allocated memory.
* 
*/


#include <linux/module.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/fs.h>

#include <asm/errno.h>

#include <linux/slab.h>   // kmalloc
#include <xen/page.h>

#include <asm/uaccess.h>  // put_user
#include <asm/pgtable.h>
#include <linux/mm.h>

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

#include "axidma_example4.h"


// FOPS FWDDECL //
static int device_open(struct inode *, struct file *);
static int device_release(struct inode *, struct file *);
static ssize_t device_read(struct file *, char *, size_t, loff_t *);
static ssize_t device_write(struct file *, const char *, size_t, loff_t *);
static int device_mmap(struct file *filp, struct vm_area_struct *vma);
static long device_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
unsigned int device_poll(struct file *, struct poll_table_struct *);

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
    .poll = device_poll,
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


static u8* buffer;
static u64 buffer_len;
static struct vm_operations_struct vm_ops;

struct fill_thread_data {
    u8 *buf;
    u64 len;
    struct completion cmp;
    u8 done;
};
static struct fill_thread_data buf_th;
        
DECLARE_WAIT_QUEUE_HEAD(fill_wq);


////////////////////////////////////////////////////////////////////////////////
//  IOCTLS  ////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////



int fill_thread_func(void *arg) {
    int i;
    int *data = (int *)buf_th.buf;
    if(!buf_th.buf || !buf_th.len) return -1;
    for(i=0; i<buf_th.len/sizeof(int); ++i) {
        data[i] = i;
        mdelay(1);
    }
    printk("completed\n");
    complete(&buf_th.cmp);
    buf_th.done = 1;
    wake_up(&fill_wq);
    return 0;
}

void start_fill_thread(void) {
    struct task_struct *task;
    buf_th.buf = buffer;
    buf_th.len = buffer_len;
    buf_th.done = 0;
    
    // starts a kernel thread to fill up the buffer //
    init_completion(&buf_th.cmp); 
    task = kthread_run(fill_thread_func, NULL, "fill function");
}




////////////////////////////////////////////////////////////////////////////////
//  FOPS  //////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


// OPEN //
static int device_open(struct inode *inode, struct file *file)
{
    
    if (s_device_open) return -EBUSY;
    s_device_open++;

    return SUCCESS;
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




static void mmap_close_cb(struct vm_area_struct *vma) { 
    // release buffer //
    vfree(buffer);
}



// helper function, mmap's the vmalloc'd area which is not physically contiguous
static int mmap_vmem(struct file *filp, struct vm_area_struct *vma,
                     char * vmalloc_area_ptr)
{
    int ret;
    long length = vma->vm_end - vma->vm_start;
    unsigned long start = vma->vm_start;
    unsigned long pfn;
    
    /* loop over all pages, map it page individually */
    while (length > 0) {
        pfn = vmalloc_to_pfn(vmalloc_area_ptr);
        if ((ret = remap_pfn_range(vma, start, pfn, PAGE_SIZE,
                                   PAGE_SHARED)) < 0) {
            return ret;
        }
        start += PAGE_SIZE;
        vmalloc_area_ptr += PAGE_SIZE;
        length -= PAGE_SIZE;
    }
    return 0;
}


// MMAP //
static int device_mmap(struct file *filp, struct vm_area_struct *vma)
{
	int result;
	unsigned long requested_size;
    
    requested_size = vma->vm_end - vma->vm_start;
    
    // ALLOCATE BUFFERS //    
    buffer = vzalloc(requested_size);
    if (!buffer) {
		printk(KERN_ERR "Allocating kernel virtual memory failed\n");
		return -EIO;
	}
    else 
        buffer_len = requested_size;
    
    // register free cb //
    vm_ops.close = mmap_close_cb;
    vma->vm_ops = &vm_ops;
    
	printk(KERN_DEBUG "<%s> file: mmap()\n", DEVICE_NAME);    
    
    // remap pages //
	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
    
    // each single page allocated must be remapped individually //
    result = mmap_vmem(filp, vma, (char *)buffer);
    if (result) {
		printk(KERN_ERR
		       "<%s> Error: in calling remap_pfn_range: returned %d\n",
		       MODULE_NAME, result);
		return -EAGAIN;
	}

    return 0;
}

// IOCTL //
static long device_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
{
    u32 ready;
    int status = 0;
    
    switch (cmd) {
	case XDMA_GET_BUF_READY:
		printk(KERN_DEBUG "<%s> ioctl: XDMA_GET_BUFFER_READY\n", MODULE_NAME);
		ready = (buffer!=NULL);
		if (copy_to_user((u32 *) arg, &ready, sizeof(u32)))
			return -EFAULT;
		break;
        
    case XDMA_START_FILLBUF:
        printk(KERN_DEBUG "<%s> ioctl: XDMA_START_FILLBUF\n", MODULE_NAME);
        start_fill_thread();
        return 0;
        break;
        
    default:
        return -EAGAIN;
		break;        
    }    
    return status;
}

unsigned int device_poll(struct file *file, struct poll_table_struct *p) {
    unsigned int mask=0;
    printk("polling file\n");
    poll_wait(file,&fill_wq,p);    
    if(buf_th.done)
        mask |= POLLIN | POLLRDNORM;
    return mask;                                       
}



////////////////////////////////////////////////////////////////////////////////
//  PLATFORM  //////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


static int xilinx_axidmatest_probe(struct platform_device *pdev)
{
    printk("probing %s ...\n",pdev->name);
    
    buffer = NULL;
    
    // CHAR DEV //
    printk("registering char dev %s ...\n",DEVICE_NAME);
    s_major = register_chrdev(0, DEVICE_NAME, &fops);    
    if (s_major < 0) {
        printk ("Registering the character device failed with %d\n", s_major);
        return s_major;
    }
    printk(KERN_NOTICE "mknod /dev/xdma c %d 0\n", s_major);    
        
    return 0;
}

static int xilinx_axidmatest_remove(struct platform_device *pdev)
{
        
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
