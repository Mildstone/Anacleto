/* AXI DMA Example 2
*
* File operations on char device to mmap a kernel allocated buffer to the user
* space.
*
*/

#include <linux/module.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/mm.h>
#include <linux/fs.h>
#include <asm/errno.h>

#include <linux/slab.h>   // kmalloc
#include <xen/page.h>

#include <asm/uaccess.h>  // put_user
#include <asm/pgtable.h>

#include <linux/platform_device.h>

// FOPS FWDDECL //
static int device_open(struct inode *, struct file *);
static int device_release(struct inode *, struct file *);
static ssize_t device_read(struct file *, char *, size_t, loff_t *);
static ssize_t device_write(struct file *, const char *, size_t, loff_t *);
static int device_mmap(struct file *filp, struct vm_area_struct *vma);

static int xilinx_axidmatest_probe(struct platform_device *pdev);
static int xilinx_axidmatest_remove(struct platform_device *pdev);

////////////////////////////////////////////////////////////////////////////////
//  GLOBALS  ///////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


static int s_major;            /* Major number assigned to our device driver */
static int s_device_open = 0;  /* Is device open?  Used to prevent multiple
                                        access to the device */

#define SUCCESS 0
#define DEVICE_NAME "signal"  /* Dev name as it appears in /proc/devices   */
#define BUF_LEN 80            /* Max length of the message from the device */

static char msg[BUF_LEN];    /* The msg the device will give when asked    */
static char *msg_Ptr;

static struct file_operations fops = {
  .read = device_read,
  .write = device_write,
  .open = device_open,
  .release = device_release,
  .mmap = device_mmap
};

static const struct of_device_id rfx_axidmatest_of_ids[] = {
    { .compatible = "xlnx,axi-dma-1.00.a",},
	{}
};

static struct platform_driver rfx_axidmatest_driver = {
	.driver = {
		.name = "axidma-exaple2",
		.owner = THIS_MODULE,
		.of_match_table = rfx_axidmatest_of_ids,
	},
	.probe = xilinx_axidmatest_probe,
	.remove = xilinx_axidmatest_remove,
};

static char *s_buffer;
#define BUFFER_SIZE 10000





////////////////////////////////////////////////////////////////////////////////
//  FOPS  //////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


// OPEN //
static int device_open(struct inode *inode, struct file *file)
{
   static int counter = 0;
   if (s_device_open) return -EBUSY;

   s_device_open++;
   sprintf(msg,"I already told you %d times use mmap to acces buffer!\n", counter++);
   msg_Ptr = msg;

   sprintf(s_buffer,"This is the buffer of device %s\n", rfx_axidmatest_driver.driver.name);
   
   return SUCCESS;
}


// CLOSE //
static int device_release(struct inode *inode, struct file *file)
{
   s_device_open --;     /* We're now ready for our next caller */
   return 0;
}


// READ //
static ssize_t device_read(struct file *filp,
   char *buffer,    /* The buffer to fill with data */
   size_t length,   /* The length of the buffer     */
   loff_t *offset)  /* Our offset in the file       */
{
   /* Number of bytes actually written to the buffer */
   int bytes_read = 0;

   /* If we're at the end of the message, return 0 signifying end of file */
   if (*msg_Ptr == 0) return 0;

   /* Actually put the data into the buffer */
   while (length && *msg_Ptr)  {

        /* The buffer is in the user data segment, not the kernel segment;
         * assignment won't work.  We have to use put_user which copies data from
         * the kernel data segment to the user data segment. */
         put_user(*(msg_Ptr++), buffer++);

         length--;
         bytes_read++;
   }

   /* Most read functions return the number of bytes put into the buffer */
   return bytes_read;
}


// WRITE //
static ssize_t device_write(struct file *filp,
   const char *buff,
   size_t len,
   loff_t *off)
{
   printk ("<1>Sorry, this operation isn't supported.\n");
   return -EINVAL;
}


static struct vm_operations_struct vm_ops;
static void mmap_close_cb(struct vm_area_struct *vma) { 
    printk("close operation on vm object called by munmap\n"); 
}

// MMAP //
static int device_mmap(struct file *filp, struct vm_area_struct *vma)
{
	int result;
	unsigned long requested_size;
	requested_size = vma->vm_end - vma->vm_start;

	printk(KERN_DEBUG "<%s> file: mmap()\n", DEVICE_NAME);
	printk(KERN_DEBUG "<%s> file: memory size reserved: %d, mmap size requested: %lu\n",
           DEVICE_NAME, BUFFER_SIZE, requested_size);

	if (requested_size > BUFFER_SIZE) {
		printk(KERN_ERR "<%s> Error: %d reserved != %lu requested)\n",
		       DEVICE_NAME, BUFFER_SIZE, requested_size);
		return -EAGAIN;
	}
    
    // set close callback
    vm_ops.close = mmap_close_cb;
    vma->vm_ops = &vm_ops;       
    
    // AVOID CACHING BUFFER //
	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
    
    // REMAP BUFFER TO THE FILE //
    result = remap_pfn_range(vma, vma->vm_start, virt_to_pfn(s_buffer),
				 requested_size, vma->vm_page_prot);

	if (result) {
		printk(KERN_ERR
		       "<%s> Error: in calling remap_pfn_range: returned %d\n",
		       DEVICE_NAME, result);
		return -EAGAIN;
	}
	return 0;
}






////////////////////////////////////////////////////////////////////////////////
//  PLATFORM  //////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


static int xilinx_axidmatest_probe(struct platform_device *pdev)
{
    printk("probing %s ...\n",pdev->name);
    
    // BUFFER //
    printk("allocating fuffer of size: %d ...\n",BUFFER_SIZE);
    s_buffer = kmalloc(BUFFER_SIZE,GFP_KERNEL);

    // CHAR DEV //
    printk("registering char dev %s ...\n",DEVICE_NAME);
    s_major = register_chrdev(0, DEVICE_NAME, &fops);
    
    if (s_major < 0) {
        printk ("Registering the character device failed with %d\n", s_major);
        return s_major;
    }
    
    printk("<1>I was assigned major number %d.  To talk to\n", s_major);
    printk("<1>the driver, create a dev file with\n");
    printk("'mknod /dev/hello c %d 0'.\n", s_major);
    printk("<1>Try various minor numbers.  Try to cat and echo to\n");
    printk("the device file.\n");
    printk("<1>Remove the device file and module when done.\n");
    
    return 0;
}

static int xilinx_axidmatest_remove(struct platform_device *pdev)
{
    
    
    printk("removing %s ...\n",pdev->name);
    
    printk("unregistering char dev ...\n");
    unregister_chrdev(s_major, DEVICE_NAME);
    
    
    printk("freeing buffer ...\n");
    kfree(s_buffer);
    
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
