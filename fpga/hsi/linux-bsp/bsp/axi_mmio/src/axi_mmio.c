


#include <linux/module.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/mm.h>
#include <linux/vmalloc.h>

#include <linux/types.h>

#include <linux/io.h>
#include <linux/ptrace.h>

#include <asm/uaccess.h>  // put_user
#include <asm/pgtable.h>

#include <linux/fs.h>

#include <linux/platform_device.h>

#include <linux/interrupt.h>
#include <linux/poll.h>

#include "rpadc_fifo.h"

#include <asm/io.h>
#include <linux/semaphore.h>
#include <linux/spinlock.h>
#include <linux/slab.h>
#include <linux/cdev.h>
#include <linux/delay.h>


//static struct platform_device *s_pdev = 0;
// static int s_device_open = 0;

// FOPS FWDDECL //
static int device_open(struct inode *, struct file *);
static int device_release(struct inode *, struct file *);
static ssize_t device_read(struct file *, char *, size_t, loff_t *);
static ssize_t device_write(struct file *, const char *, size_t, loff_t *);
static int device_mmap(struct file *filp, struct vm_area_struct *vma);
static loff_t memory_lseek(struct file *file, loff_t offset, int orig);
static long device_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
static unsigned int device_poll(struct file *file, struct poll_table_struct *p);

static struct file_operations fops = {
    .read = device_read,
    .write = device_write,
    .open = device_open,
    .release = device_release,
    .mmap = device_mmap,
    .llseek = memory_lseek,
    .unlocked_ioctl = device_ioctl,
    .poll = device_poll,
};


struct rpadc_fifo_dev {
    struct platform_device *pdev;
    struct cdev cdev;
    int busy;
    int irq;
    void * iomap_data;     	//Data FIFO configuration registers
    struct semaphore sem;     /* mutual exclusion semaphore     */
};


////////////////////////////////////////////////////////////////////////////////
//  FOPS  //////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// interrupt handler //
irqreturn_t IRQ_cb(int irq, void *dev_id, struct pt_regs *regs) {
    struct rpadc_fifo_dev *rpadc = dev_id;
    printk("--INTERRUPT: Done\n");
    return IRQ_HANDLED;
}

// OPEN //
static int device_open(struct inode *inode, struct file *file)
{
    if(!file->private_data) {
        u32 off;
        struct rpadc_fifo_dev *privateInfo = container_of(inode->i_cdev, struct rpadc_fifo_dev, cdev);
        printk(KERN_DEBUG "OPEN: privateInfo = %0x \n",privateInfo);
        //struct resource *r_mem =  platform_get_resource(s_pdev, IORESOURCE_MEM, 0);
        file->private_data = privateInfo;

        struct resource *r_mem =  platform_get_resource(privateInfo->pdev, IORESOURCE_MEM, 0);
        off = r_mem->start & ~PAGE_MASK;
        privateInfo->iomap_data = devm_ioremap(&privateInfo->pdev->dev,r_mem->start+off,0xffff);

        privateInfo->irq = platform_get_irq(privateInfo->pdev,0);
        printk(KERN_DEBUG "OPEN: iomap = %0x IRQ: %X\n",privateInfo->iomap_data, privateInfo->irq);
        int res = request_irq( privateInfo->irq, IRQ_cb, IRQF_TRIGGER_RISING ,"rpadc_fifo",privateInfo);
        if(res) printk(KERN_INFO "rpadc_fifo: can't get IRQ %d assigned\n",privateInfo->irq);
        else printk(KERN_INFO "rpadc_fifo: got IRQ %d assigned\n",privateInfo->irq);

    }
    struct rpadc_fifo_dev *privateInfo = (struct rpadc_fifo_dev *)file->private_data;
    if(!privateInfo) return -EFAULT;
    else if (privateInfo->busy) return -EBUSY;
    else privateInfo->busy++;
    return capable(CAP_SYS_RAWIO) ? 0 : -EPERM;
}


// CLOSE //
static int device_release(struct inode *inode, struct file *file)
{
    struct rpadc_fifo_dev *dev = file->private_data;
    if(!dev) return -EFAULT;
    if(--dev->busy == 0)
    {
        printk(KERN_DEBUG "CLOSE: iomap = %0x \n",dev->iomap_data);
        free_irq(dev->irq,dev);
        devm_iounmap(&dev->pdev->dev,dev->iomap_data);
    }
    return 0;
}




// READ //
static ssize_t device_read(struct file *filp, char *buffer, size_t length,
                           loff_t *offset)
{
    struct rpadc_fifo_dev *rpadc = (struct rpadc_fifo_dev *)filp->private_data;
    return 0;
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
    struct rpadc_fifo_dev *privateInfo =  (struct rpadc_fifo_dev *)filp->private_data;
    struct resource *r_mem = platform_get_resource(privateInfo->pdev, IORESOURCE_MEM, 0);
    //struct resource *r_mem = platform_get_resource(s_pdev, IORESOURCE_MEM, 0);

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
    void* dev = scc_dev->iomap_data;
    //    void* dev1 = scc_dev->iomap1;

    switch (cmd) {
    case RFX_RPADC_RESET:
        printk(KERN_DEBUG "<%s> ioctl: $ip_name$_RESET\n", MODULE_NAME);
        return 0;
        break;

    default:
        return -EAGAIN;
        break;
    }
    return status;
}


static unsigned int device_poll(struct file *file, struct poll_table_struct *p)
{
    unsigned int mask=0;
    struct rpadc_fifo_dev *privateInfo =  (struct rpadc_fifo_dev *)file->private_data;
    down(&privateInfo->sem);
    up(&privateInfo->sem);
    return mask;
}




////////////////////////////////////////////////////////////////////////////////
//  PROBE  /////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

static int id_major;
static struct class *rpadc_class;
static struct rpadc_fifo_dev staticPrivateInfo;
static int $ip_name$_probe(struct platform_device *pdev)
{
    int i;

    struct resource *r_mem;
    struct device *dev = &pdev->dev;

    // CHAR DEV //
    printk("registering char dev %s ...\n",pdev->name);
    printk("PLATFORM DEVICE PROBE...%x\n", &staticPrivateInfo);

    int err, devno;
    dev_t newDev;
    err = alloc_chrdev_region(&newDev, 0, 1, DEVICE_NAME);
    id_major = MAJOR(newDev);
    printk("MAJOR ID...%d\n", id_major);
    if(err < 0)
    {
        printk ("alloc_chrdev_region failed\n");
        return err;
    }
    cdev_init(&staticPrivateInfo.cdev, &fops);
    staticPrivateInfo.cdev.owner = THIS_MODULE;
    staticPrivateInfo.cdev.ops = &fops;
    devno = MKDEV(id_major, 0); //Minor Id is 0
    err = cdev_add(&staticPrivateInfo.cdev, devno, 1);
    if(err < 0)
    {
        printk ("cdev_add failed\n");
        return err;
    }
    staticPrivateInfo.pdev = pdev;

    printk(KERN_NOTICE "mknod /dev/%s c %d 0\n", DEVICE_NAME, id_major);

    rpadc_class = class_create(THIS_MODULE, DEVICE_NAME);
    if (IS_ERR(rpadc_class))
        return PTR_ERR(rpadc_class);

    // scc52460_class->devnode = rpadc_fifo_devnode;
    device_create(rpadc_class, NULL, MKDEV(id_major, 0),
                  NULL, DEVICE_NAME);

    /* Get iospace for the device */

        //	r_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
    r_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
    if (!r_mem)
    {
        dev_err(dev, "Can't find device base address\n");
        return 1;
    }

    printk(KERN_DEBUG"mem start: %x\n",r_mem->start);
    printk(KERN_DEBUG"mem end: %x\n",r_mem->end);
    printk(KERN_DEBUG"mem offset: %x\n",r_mem->start & ~PAGE_MASK);

    // Initialize semaphores and queues
    sema_init(&staticPrivateInfo.sem, 1);

    return 0;
}

static int $ip_name$_remove(struct platform_device *pdev)
{
    printk("PLATFORM DEVICE REMOVE...\n");
    if(rpadc_class) {
        device_destroy(rpadc_class,MKDEV(id_major, 0));
        class_destroy(rpadc_class);
    }
    //Gabriele Dec 2017
    cdev_del(&staticPrivateInfo.cdev);
    return 0;
}

static const struct of_device_id $ip_name$_of_ids[] = {
{ .compatible = "xlnx,$compatible$",},
{}
};

static struct platform_driver $ip_name$_driver = {
    .driver = {
        .name  = MODULE_NAME,
        .owner = THIS_MODULE,
        .of_match_table = $ip_name$_of_ids,
    },
    .probe = $ip_name$_probe,
    .remove = $ip_name$_remove,
};

static int __init $ip_name$_init(void)
{
    printk(KERN_INFO "inizializing AXI module ...\n");
    return platform_driver_register(&$ip_name$_driver);
}

static void __exit $ip_name$_exit(void)
{
    printk(KERN_INFO "exiting AXI module ...\n");
    platform_driver_unregister(&$ip_name$_driver);
}

module_init($ip_name$_init);
module_exit($ip_name$_exit);
MODULE_LICENSE("GPL");
