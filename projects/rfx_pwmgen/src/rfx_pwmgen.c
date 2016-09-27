

#include <linux/module.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/mm.h>
#include <linux/vmalloc.h>

#include <linux/io.h>
#include <linux/ptrace.h>

#include <asm/uaccess.h>  // put_user
#include <asm/pgtable.h>

#include <linux/fs.h>

#include <linux/platform_device.h>

#include "rfx_pwmgen.h"

#define SUCCESS 0

static struct platform_device *s_pdev = 0;
static int s_device_open = 0;




// FOPS FWDDECL //
static int device_open(struct inode *, struct file *);
static int device_release(struct inode *, struct file *);
static ssize_t device_read(struct file *, char *, size_t, loff_t *);
static ssize_t device_write(struct file *, const char *, size_t, loff_t *);
static int device_mmap(struct file *filp, struct vm_area_struct *vma);
static loff_t memory_lseek(struct file *file, loff_t offset, int orig);
static long device_ioctl(struct file *file, unsigned int cmd, unsigned long arg);

static struct file_operations fops = {
    .read = device_read,
    .write = device_write,
    .open = device_open,
    .release = device_release,
    .mmap = device_mmap,
    .llseek = memory_lseek,
    .unlocked_ioctl = device_ioctl,
//    .poll = device_poll,
};


////////////////////////////////////////////////////////////////////////////////
//  FOPS  //////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////



// OPEN //
static int device_open(struct inode *inode, struct file *file)
{

    if (s_device_open) return -EBUSY;
    s_device_open++;
    return capable(CAP_SYS_RAWIO) ? 0 : -EPERM;
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




// MMAP //

static struct vm_operations_struct vm_ops;
static void mmap_close_cb(struct vm_area_struct *vma) {
    ; // do nothing
}

static const struct vm_operations_struct mmap_mem_ops = {
    .close = mmap_close_cb,
#ifdef CONFIG_HAVE_IOREMAP_PROT
    .access = generic_access_phys,
#endif
};

pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
                  unsigned long size, pgprot_t vma_prot)
{
    if (!pfn_valid(pfn))
        return pgprot_noncached(vma_prot);
    else if (file->f_flags & O_SYNC)
        return pgprot_writecombine(vma_prot);
    return vma_prot;
}

static int device_mmap(struct file *filp, struct vm_area_struct *vma)
{
    int status = 0;
    struct resource *r_mem = platform_get_resource(s_pdev, IORESOURCE_MEM, 0);

    unsigned long off = vma->vm_pgoff << PAGE_SHIFT;
    unsigned long physical = r_mem->start + off;
    size_t vsize = vma->vm_end - vma->vm_start;
    size_t psize = (r_mem->end - r_mem->start) - off;
    unsigned long pageFrameNo = __phys_to_pfn(physical);

    // register cb //
    vma->vm_ops = &mmap_mem_ops;

    printk(KERN_DEBUG "<%s> file: mmap()\n", DEVICE_NAME);

    printk(KERN_DEBUG "<%s> file: set physical = %x, size = %d\n",
           MODULE_NAME, physical, psize);

    printk(KERN_DEBUG "<%s> file: destination = %x, size = %d\n",
           MODULE_NAME, vma->vm_start, vsize);

    vma->vm_page_prot = phys_mem_access_prot(filp, vma->vm_pgoff,
                         vsize,
                         vma->vm_page_prot);

    if (vsize > psize)
        return -EINVAL; /* spans too high */

    status = remap_pfn_range(vma, vma->vm_start,
                             pageFrameNo, vsize, vma->vm_page_prot);
    if (status) {
        printk(KERN_ERR
               "<%s> Error: in calling remap_pfn_range: returned %d\n",
               MODULE_NAME, status);
        return -EAGAIN;
    }
        return status;
}


// LSEEK //
static loff_t memory_lseek(struct file *file, loff_t offset, int orig)
{
    loff_t ret;

    mutex_lock(&file_inode(file)->i_mutex);
    switch (orig) {
    case SEEK_CUR:
        offset += file->f_pos;
    case SEEK_SET:
        /* to avoid userland mistaking f_pos=-9 as -EBADF=-9 */
        if (IS_ERR_VALUE((unsigned long long)offset)) {
            ret = -EOVERFLOW;
            break;
        }
        file->f_pos = offset;
        ret = file->f_pos;
        force_successful_syscall_return();
        break;
    default:
        ret = -EINVAL;
    }
    mutex_unlock(&file_inode(file)->i_mutex);
    return ret;
}



// IOCTL //
static long device_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
{
    u32 res_offset;
    int status = 0;
    struct resource *r_mem = platform_get_resource(s_pdev, IORESOURCE_MEM, 0);
    res_offset = r_mem->start & ~PAGE_MASK;


    switch (cmd) {
    case RFX_PWMGEN_RESOFFSET:
        printk(KERN_DEBUG "<%s> ioctl: RFX_PWMGEN_RESOFFSET\n", MODULE_NAME);
        if (copy_to_user((u32 *) arg, &res_offset, sizeof(u32)))
            return -EFAULT;
        break;

    default:
        return -EAGAIN;
        break;
    }
    return status;
}





////////////////////////////////////////////////////////////////////////////////
//  PROBE  /////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

static int id_major;
static struct class *pwmgen_class;

static int rfx_pwmgen_probe(struct platform_device *pdev)
{

    struct resource *r_mem;
    struct device *dev = &pdev->dev;

    s_pdev = pdev;
    printk("PLATFORM DEVICE PROBE...\n");


    // CHAR DEV //
    printk("registering char dev %s ...\n",pdev->name);
    id_major = register_chrdev(0, DEVICE_NAME, &fops);
    if (id_major < 0) {
        printk ("Registering the character device failed with %d\n", id_major);
        return id_major;
    }
    printk(KERN_NOTICE "mknod /dev/%s c %d 0\n", DEVICE_NAME, id_major);

    pwmgen_class = class_create(THIS_MODULE, DEVICE_NAME);
    if (IS_ERR(pwmgen_class))
        return PTR_ERR(pwmgen_class);

    // pwmgen_class->devnode = pwmgen_devnode;
    device_create(pwmgen_class, NULL, MKDEV(id_major, 0),
                  NULL, DEVICE_NAME);

    /* Get iospace for the device */
    r_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
    if (!r_mem)
    {
      dev_err(dev, "Can't find device base address\n");
      return 1;
    }

    printk(KERN_DEBUG"mem start: %x\n",r_mem->start);
    printk(KERN_DEBUG"mem end: %x\n",r_mem->end);
    printk(KERN_DEBUG"mem offset: %x\n",r_mem->start & ~PAGE_MASK);

    return 0;
}

static int rfx_pwmgen_remove(struct platform_device *pdev)
{
    printk("PLATFORM DEVICE REMOVE...\n");
    if(pwmgen_class) {
        device_destroy(pwmgen_class,MKDEV(id_major, 0));
        class_destroy(pwmgen_class);
    }
    unregister_chrdev(id_major, DEVICE_NAME);
	return 0;
}

static const struct of_device_id rfx_pwmgen_of_ids[] = {
    { .compatible = "xlnx,rfx-pwmgen-1.0",},
	{}
};

static struct platform_driver rfx_pwmgen_driver = {
	.driver = {
        .name  = MODULE_NAME,
		.owner = THIS_MODULE,
        .of_match_table = rfx_pwmgen_of_ids,
	},
    .probe = rfx_pwmgen_probe,
    .remove = rfx_pwmgen_remove,
};

static int __init rfx_pwmgen_init(void)
{
    printk(KERN_INFO "inizializing AXI module ...\n");
    return platform_driver_register(&rfx_pwmgen_driver);
}

static void __exit rfx_pwmgen_exit(void)
{
    printk(KERN_INFO "exiting AXI module ...\n");
    platform_driver_unregister(&rfx_pwmgen_driver);
}

module_init(rfx_pwmgen_init);
module_exit(rfx_pwmgen_exit);
MODULE_LICENSE("GPL");
