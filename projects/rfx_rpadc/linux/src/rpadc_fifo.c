

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

#include <linux/interrupt.h>

#include "rpadc_fifo.h"

#include <asm/io.h>
#include <linux/slab.h>

#define SUCCESS 0


static struct platform_device *s_pdev = 0;
// static int s_device_open = 0;

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

struct rpadc_fifo_dev {
    struct platform_device *pdev;
    struct cdev *cdev;
    int busy;
    void * iomap;
    void * iomap1;
    struct semaphore sem;     /* mutual exclusion semaphore     */
};



////////////////////////////////////////////////////////////////////////////////
//  FIFO IO  ///////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

void Write(void *addr, enum AxiStreamFifo_Register op, u32 data ) {
    *(u32 *)(addr+op) = data;
}

u32 Read(void *addr, enum AxiStreamFifo_Register op ) {
    return *(u32 *)(addr+op);
}



////////////////////////////////////////////////////////////////////////////////
//  FOPS  //////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////



// OPEN //
static int device_open(struct inode *inode, struct file *file)
{    
    struct rpadc_fifo_dev *dev;
    if(!file->private_data) {
        u32 off;
        struct resource *r_mem =  platform_get_resource(s_pdev, IORESOURCE_MEM, 0);
        dev = file->private_data = kmalloc(sizeof(struct rpadc_fifo_dev),GFP_KERNEL);
        // dev->cdev = container_of(inode->i_cdev, struct rpadc_fifo_dev, cdev);
        dev->pdev = s_pdev;
        off = r_mem->start & ~PAGE_MASK;
        dev->iomap = devm_ioremap(&s_pdev->dev,r_mem->start+off,0xffff);
        r_mem =  platform_get_resource(s_pdev, IORESOURCE_MEM, 1);
        off = r_mem->start & ~PAGE_MASK;
        dev->iomap1 = devm_ioremap(&s_pdev->dev,r_mem->start+off,0xffff);
        dev->busy=0;
    }
    dev = file->private_data;
    if(!dev) return -EFAULT;
    else if (dev->busy) return -EBUSY;
    else dev->busy++;
    return capable(CAP_SYS_RAWIO) ? 0 : -EPERM;
}


// CLOSE //
static int device_release(struct inode *inode, struct file *file)
{
   struct rpadc_fifo_dev *dev = file->private_data;
   if(!dev) return -EFAULT;
   if(--dev->busy == 0)
   {
       devm_iounmap(&dev->pdev->dev,dev->iomap);
       devm_iounmap(&dev->pdev->dev,dev->iomap1);
       kfree(dev);
   }
   return 0;
}



// READ //
static ssize_t device_read(struct file *filp, char *buffer, size_t length,
                           loff_t *offset)
{    
    struct rpadc_fifo_dev *scc_dev = (struct rpadc_fifo_dev *)filp->private_data;
    void* dev  = scc_dev->iomap;
    void* dev1 = scc_dev->iomap1;
    u32 *b32 = (u32*)buffer;

    u32 i = 0;
    u32 occ = Read(dev,RDFO);
    for(i=0; i < min(length/sizeof(u32), occ); ++i) {
        put_user(Read(dev1,RDFD4), b32++);
    }
    return i*sizeof(u32);
}


// WRITE //
static ssize_t device_write(struct file *filp, const char *buff, size_t len,
                            loff_t *off)
{
   printk ("<1>Sorry, this operation isn't supported yet.\n");
   return -EINVAL;
}




// MMAP //
// static struct vm_operations_struct vm_ops;
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
    int status = 0;
    struct rpadc_fifo_dev *scc_dev = file->private_data;
    void* dev = scc_dev->iomap;
    //    void* dev1 = scc_dev->iomap1;

    switch (cmd) {
    case RFX_RPADC_RESOFFSET:
        printk(KERN_DEBUG "<%s> ioctl: rfx_rpadc_fifo_RESOFFSET\n", MODULE_NAME);
        if (copy_to_user((u32 *) arg, &dev, sizeof(u32)))
            return -EFAULT;
        break;

    case RFX_RPADC_RESET:
        printk(KERN_DEBUG "<%s> ioctl: rfx_rpadc_fifo_RESET\n", MODULE_NAME);
        Write(dev,ISR,0xFFFFFFFF);
        Write(dev,RDFR,0xa5);
        return 0;
        break;

    case RFX_RPADC_CLEAR:
        printk(KERN_DEBUG "<%s> ioctl: rfx_rpadc_fifo_CLEAR\n", MODULE_NAME);
        Write(dev,RDFR,0xa5);
        return 0;
        break;

    case RFX_RPADC_GETSR:
        printk(KERN_DEBUG "<%s> ioctl: rfx_rpadc_fifo_GETSR\n", MODULE_NAME);
        Write(dev,ISR,0xFFFFFFFF);
        return 0;
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
static struct class *rpadc_class;

static int rfx_rpadc_fifo_probe(struct platform_device *pdev)
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

    rpadc_class = class_create(THIS_MODULE, DEVICE_NAME);
    if (IS_ERR(rpadc_class))
        return PTR_ERR(rpadc_class);

    // scc52460_class->devnode = rpadc_fifo_devnode;
    device_create(rpadc_class, NULL, MKDEV(id_major, 0),
                  NULL, DEVICE_NAME);

    /* Get iospace for the device */
    r_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
    if (!r_mem)
    {
      dev_err(dev, "Can't find device base address\n");
      return 1;
    }

    //    int irq = platform_get_irq(pdev,0);
    //    request_irq(irq,)

    printk(KERN_DEBUG"mem start: %x\n",r_mem->start);
    printk(KERN_DEBUG"mem end: %x\n",r_mem->end);
    printk(KERN_DEBUG"mem offset: %x\n",r_mem->start & ~PAGE_MASK);
    //    printk(KERN_DEBUG"irq: %x\n",irq);

    return 0;
}

static int rfx_rpadc_fifo_remove(struct platform_device *pdev)
{
    printk("PLATFORM DEVICE REMOVE...\n");
    if(rpadc_class) {
        device_destroy(rpadc_class,MKDEV(id_major, 0));
        class_destroy(rpadc_class);
    }
    unregister_chrdev(id_major, DEVICE_NAME);
    return 0;
}

static const struct of_device_id rfx_rpadc_fifo_of_ids[] = {
    { .compatible = "xlnx,axi-fifo-mm-s-4.1",},
    {}
};

static struct platform_driver rfx_rpadc_fifo_driver = {
    .driver = {
        .name  = MODULE_NAME,
        .owner = THIS_MODULE,
        .of_match_table = rfx_rpadc_fifo_of_ids,
    },
    .probe = rfx_rpadc_fifo_probe,
    .remove = rfx_rpadc_fifo_remove,
};

static int __init rfx_rpadc_fifo_init(void)
{
    printk(KERN_INFO "inizializing AXI module ...\n");
    return platform_driver_register(&rfx_rpadc_fifo_driver);
}

static void __exit rfx_rpadc_fifo_exit(void)
{
    printk(KERN_INFO "exiting AXI module ...\n");
    platform_driver_unregister(&rfx_rpadc_fifo_driver);
}

module_init(rfx_rpadc_fifo_init);
module_exit(rfx_rpadc_fifo_exit);
MODULE_LICENSE("GPL");
