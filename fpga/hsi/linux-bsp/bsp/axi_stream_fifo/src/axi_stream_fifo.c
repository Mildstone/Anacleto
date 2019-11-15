

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
#include <linux/poll.h>

#include "$mod_name$.h"

#include <asm/io.h>
#include <linux/semaphore.h>
#include <linux/spinlock.h>
#include <linux/slab.h>
#include <linux/cdev.h>
#include <linux/delay.h>

#define SUCCESS 0
#define FIFO_LEN 16384

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

#define BUFSIZE 65536

struct rpadc_fifo_dev {
    struct platform_device *pdev;
    struct cdev cdev;
    int busy;
    int irq;
    void * iomap_data;     	//Data FIFO configuration registers
    void * iomap1_data;    	//Data FIFO samples
    void * iomap_cmd_reg;	//Command register
    void * iomap_pre_post_reg;	//Pre/Post register
    void * iomap_dec_reg;	//Decimator register
    void * iomap_mode_reg;	//Mode register

    void * buffer;
    struct semaphore sem;     /* mutual exclusion semaphore     */
    spinlock_t spinLock;     /* spinlock     */
    u32 *fifoBuffer;
    int bufSize;
    u32 rIdx, wIdx, bufCount;
    wait_queue_head_t readq;  /* read queue */
    int fifoHalfInterrupt;
    int fifoOverflow;
    int armed;
};



int writeBuf(struct rpadc_fifo_dev *info, u32 sample)
{
    //   printk(KERN_DEBUG "rpadc_fifo: %d \n",sample&0xffff);
    spin_lock_irq(&info->spinLock);
    if(info->bufCount >= info->bufSize)
    {
	printk(KERN_DEBUG "ADC FIFO BUFFER OVERFLOW!\n");
	spin_unlock_irq(&info->spinLock);
	return -1;
    }
    else
    {
	info->fifoBuffer[info->wIdx] = sample;
	info->wIdx = (info->wIdx + 1) % info->bufSize;
	info->bufCount++;
    }
    spin_unlock_irq(&info->spinLock);
    return 0;
}

u32 readBuf(struct rpadc_fifo_dev *info)
{
    u32 data;
    spin_lock_irq(&info->spinLock);
    if(info->bufCount <= 0)
    {
	printk(KERN_DEBUG "ADC FIFO BUFFER UNDERFLOW!\n");  //Should never happen
	data = 0;
    }
    else
    {
	data = info->fifoBuffer[info->rIdx];
	info->rIdx = (info->rIdx+1) % info->bufSize;
	info->bufCount--;
    }
    spin_unlock_irq(&info->spinLock);
    return data;
}



////////////////////////////////////////////////////////////////////////////////
//  FIFO IO  ///////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

void Write(void *addr, enum AxiStreamFifo_Register op, u32 data ) {
    *(u32 *)(addr+op) = data;
}

u32 Read(void *addr, enum AxiStreamFifo_Register op ) {
    return *(u32 *)(addr+op);
}


///////////Clear everythin when arming

void clearFifoAndBuf(struct rpadc_fifo_dev *rpadc)
{
    int i;
    //Clear FIFO
    void* dev  = rpadc->iomap_data;
    void* dev1 = rpadc->iomap1_data;
    u32 occ = Read(dev,RDFO);
    u32 currSample;
    for(i = 0; i < occ; i++)
	currSample = Read(dev1,RDFD4);

    //Clear Buffer
    rpadc->wIdx =  rpadc->rIdx = 0;
    rpadc->bufCount = 0;
}



////////////////////////////////////////////////////////////////////////////////
//  FOPS  //////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// interrupt handler //
irqreturn_t IRQ_cb(int irq, void *dev_id, struct pt_regs *regs) {
    struct rpadc_fifo_dev *rpadc = dev_id;
    static int isFirst = 1;
    //Check whether he cause of interrupt has been reveive overrun
    Write(rpadc->iomap_data,ISR,0xFFFFFFFF);
    Write(rpadc->iomap_data,IER,0x00000000);

    void* dev  = rpadc->iomap_data;
    void* dev1 = rpadc->iomap1_data;

    static u32 prev1, prev2;

    u32 occ = Read(dev,RDFO);
    {
	isFirst = 0;
    }

    //printk("--INTERRUPT: Available samples: %d\n", occ);


    if(occ >= FIFO_LEN)
    {
	rpadc->fifoOverflow = 1;
	wake_up(&rpadc->readq);
	//When oveflow is detected, disable interrupts
    }

    int i;
    for(i = 0; i < occ; i++)
    {
	u32 currSample = Read(dev1,RDFD4);
	if(writeBuf(rpadc, currSample) < 0) //In case of ADC FIFO overflow, abort data readout from FPGA
	{
	    Write(rpadc->iomap_data,IER,0x00000000);
	    return IRQ_HANDLED;
	}
    }
    wake_up(&rpadc->readq);

    if(rpadc->fifoHalfInterrupt)
	Write(rpadc->iomap_data,IER,0x00100000);
    else
	Write(rpadc->iomap_data,IER,0x04000000);

    //printk("--INTERRUPT: Done\n");
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

	r_mem =  platform_get_resource(privateInfo->pdev, IORESOURCE_MEM, 1);
	off = r_mem->start & ~PAGE_MASK;
	privateInfo->iomap1_data = devm_ioremap(&privateInfo->pdev->dev,r_mem->start+off,0xffff);

	privateInfo->irq = platform_get_irq(privateInfo->pdev,0);
	printk(KERN_DEBUG "OPEN: iomap = %0x IRQ: %X\n",privateInfo->iomap_data, privateInfo->irq);
	int res = request_irq( privateInfo->irq, IRQ_cb, IRQF_TRIGGER_RISING ,"rpadc_fifo",privateInfo);
	if(res) printk(KERN_INFO "rpadc_fifo: can't get IRQ %d assigned\n",privateInfo->irq);
	else printk(KERN_INFO "rpadc_fifo: got IRQ %d assigned\n",privateInfo->irq);

	privateInfo->busy = 0;
	privateInfo->wIdx = 0;
	privateInfo->rIdx = 0;
	privateInfo->bufCount = 0;
	privateInfo->bufSize = BUFSIZE;
	privateInfo->fifoBuffer = (u32 *)kmalloc(privateInfo->bufSize * sizeof(u32), GFP_KERNEL);
	privateInfo->armed = 0;
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
	Write(dev->iomap_data,IER,0x0);
	free_irq(dev->irq,dev);
	devm_iounmap(&dev->pdev->dev,dev->iomap_data);
	devm_iounmap(&dev->pdev->dev,dev->iomap1_data);
	kfree(dev->fifoBuffer);
    }
    return 0;
}




static ssize_t device_read(struct file *filp, char *buffer, size_t length,
			   loff_t *offset)
{
    struct rpadc_fifo_dev *rpadc = (struct rpadc_fifo_dev *)filp->private_data;
    u32 *b32 = (u32*)buffer;

    if(rpadc->fifoOverflow)
	return -1;

    u32 i = 0;
    //spin_lock(&rpadc->spinLock);
    while(rpadc->bufCount == 0)
    {
	if(filp->f_flags & O_NONBLOCK)
	    return -EAGAIN;
	if(wait_event_interruptible(rpadc->readq, rpadc->bufCount > 0))
	    return -ERESTARTSYS;
	if(!rpadc->armed)
	    return 0;
    }

    u32 occ = rpadc->bufCount;
    for(i=0; i < min(length/sizeof(u32), occ); ++i) {
	u32 curr = readBuf(rpadc);
	put_user(curr, b32++);
    }
    //spin_unlock(&rpadc->spinLock);

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
    case $MOD_NAME$_RESOFFSET:
	printk(KERN_DEBUG "<%s> ioctl: $mod_name$_RESOFFSET\n", MODULE_NAME);
	if (copy_to_user((u32 *) arg, &dev, sizeof(u32)))
	    return -EFAULT;
	break;

    case $MOD_NAME$_RESET:
	printk(KERN_DEBUG "<%s> ioctl: $mod_name$_RESET\n", MODULE_NAME);
	Write(dev,ISR,0xFFFFFFFF);
	Write(dev,RDFR,0xa5);
	scc_dev->fifoOverflow = 0;
	return 0;
	break;

    case $MOD_NAME$_CLEAR:
	printk(KERN_DEBUG "<%s> ioctl: $mod_name$_CLEAR\n", MODULE_NAME);
	Write(dev,RDFR,0xa5);
	if(scc_dev->fifoHalfInterrupt)
	    Write(dev,IER,0x00100000);
	else
	    Write(dev,IER,0x04000000);
	return 0;
	break;

    case $MOD_NAME$_GETSR:
	printk(KERN_DEBUG "<%s> ioctl: $mod_name$_GETSR\n", MODULE_NAME);
	Write(dev,ISR,0xFFFFFFFF);
	return 0;
	break;

    case $MOD_NAME$_OVERFLOW:
	printk(KERN_DEBUG "<%s> ioctl: $mod_name$_OVERFLOW\n", MODULE_NAME);
	return scc_dev->fifoOverflow;
	break;
    case $MOD_NAME$_INT_HALF_SIZE:
	scc_dev->fifoHalfInterrupt = 1;
	return 0;
	break;
    case $MOD_NAME$_INT_FIRST_SAMPLE:
	scc_dev->fifoHalfInterrupt = 0;
	return 0;
	break;


    case $MOD_NAME$_SET_BUFSIZE:
    {
	int newSize;
	copy_from_user (&newSize, (void __user *)arg, sizeof(u32));
	if(newSize < 0)
	    return -1;
	if(scc_dev->armed)  //Buffer in operation
	    return -1;
	kfree(scc_dev->fifoBuffer);
	scc_dev->bufSize = newSize;
	scc_dev->fifoBuffer = kmalloc(newSize * sizeof(u32), GFP_KERNEL);
	return 0;
    }
    case $MOD_NAME$_GET_BUFSIZE:
    {
	copy_to_user ((void __user *)arg, &scc_dev->bufSize, sizeof(u32));
	return 0;
    }

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
    poll_wait(file,&privateInfo->readq,p);
    if(privateInfo->bufCount > 0)
	mask |= POLLIN | POLLRDNORM;
    up(&privateInfo->sem);
    return mask;
}




////////////////////////////////////////////////////////////////////////////////
//  PROBE  /////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

static int id_major;
static struct class *rpadc_class;
static struct rpadc_fifo_dev staticPrivateInfo;
static int $mod_name$_probe(struct platform_device *pdev)
{
    int i;

    struct resource *r_mem;
    struct device *dev = &pdev->dev;

    //s_pdev = pdev;


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

    for(i = 0; i < 8; i++)
    {

	//	r_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	r_mem = platform_get_resource(pdev, IORESOURCE_MEM, i);
	if (!r_mem)
	{
	    dev_err(dev, "Can't find device base address\n");
	    return 1;
	}


	printk(KERN_DEBUG"mem start: %x\n",r_mem->start);
	printk(KERN_DEBUG"mem end: %x\n",r_mem->end);
	printk(KERN_DEBUG"mem offset: %x\n",r_mem->start & ~PAGE_MASK);
    }

    // Initialize semaphores and queues
    sema_init(&staticPrivateInfo.sem, 1);
    spin_lock_init(&staticPrivateInfo.spinLock);
    init_waitqueue_head(&staticPrivateInfo.readq);
    staticPrivateInfo.bufCount = 0;
    staticPrivateInfo.rIdx = 0;
    staticPrivateInfo.wIdx = 0;
    staticPrivateInfo.fifoHalfInterrupt = 0;
    staticPrivateInfo.fifoOverflow = 0;

    return 0;
}

static int $mod_name$_remove(struct platform_device *pdev)
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

static const struct of_device_id $mod_name$_of_ids[] = {
{ .compatible = "xlnx,axi-fifo-mm-s-4.1",},
{}
};

static struct platform_driver $mod_name$_driver = {
    .driver = {
	.name  = MODULE_NAME,
	.owner = THIS_MODULE,
	.of_match_table = $mod_name$_of_ids,
    },
    .probe = $mod_name$_probe,
    .remove = $mod_name$_remove,
};

static int __init $mod_name$_init(void)
{
    printk(KERN_INFO "inizializing AXI module ...\n");
    return platform_driver_register(&$mod_name$_driver);
}

static void __exit $mod_name$_exit(void)
{
    printk(KERN_INFO "exiting AXI module ...\n");
    platform_driver_unregister(&$mod_name$_driver);
}

module_init($mod_name$_init);
module_exit($mod_name$_exit);
MODULE_LICENSE("GPL");
