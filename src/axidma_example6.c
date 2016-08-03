#include <linux/module.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#include <asm/errno.h>

// memory //
#include <linux/slab.h>   // kmalloc
#include <xen/page.h>
#include <asm/uaccess.h>  // put_user
#include <asm/pgtable.h>

// dma //
#include <linux/dmaengine.h>         // dma api
#include <linux/amba/xilinx_dma.h>   // axi dma driver
#include <linux/dma-mapping.h>
#include <linux/delay.h>
#include <linux/kthread.h>
#include <linux/poll.h>
#include <linux/wait.h>
#include <linux/list.h>

// concurrent //
#include <linux/mutex.h>
#include <linux/semaphore.h>

// platform //
#include <linux/platform_device.h>
#include "axidma_example6.h"



struct xdma6_buffer;
struct xdma6_ring;

// FOPS FWDDECL //
static int device_open(struct inode *, struct file *);
static int device_release(struct inode *, struct file *);
static ssize_t device_read(struct file *, char *, size_t, loff_t *);
static ssize_t device_write(struct file *, const char *, size_t, loff_t *);
static int device_mmap(struct file *filp, struct vm_area_struct *vma);
static long device_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
unsigned int device_poll(struct file *file, struct poll_table_struct *p);

static struct file_operations fops = {
    .read = device_read,
    .write = device_write,
    .open = device_open,
    .release = device_release,
    .mmap = device_mmap,
    .unlocked_ioctl = device_ioctl,
    .poll = device_poll,
};


struct xdma6_device {
    struct platform_device *pdev;
    struct dma_device *device;
    struct dma_chan *rx_chan;
    struct dma_chan *tx_chan;
    struct xdma6_ring *tx_ring;
    struct xdma6_ring *rx_ring;
    struct spinlock lock;
    int is_open;
    int id_major;
};

// BUFFER //
struct xdma6_buffer {
    struct list_head node;    
    u8 *data;
    dma_addr_t handle;
    dma_cookie_t cookie;

    struct xdma6_buffer_info info;
};


// RING //
struct xdma6_ring {
    struct list_head node;
    struct list_head buffers;

    enum dma_transfer_direction dir;
    struct xdma6_buffer *w_pos;
    struct xdma6_buffer *r_pos;
    struct wait_queue_head_t *w_wait;
    struct wait_queue_head_t *r_wait;
    struct dma_chan *channel;

    struct xdma6_ring_info info;
};


static struct xdma6_ring xrings[2];
static struct xdma6_device xdev;
static struct xdma6_buffer *map_buffer = 0;
static unsigned long map_offset = 0;
static DEFINE_SEMAPHORE(map_buffer_sem);

//= {
//    .pdev    = NULL,
//    .device  = NULL,
//    .rx_chan = NULL,
//    .tx_chan = NULL,
//    .tx_ring = &xrings[0],
//    .rx_ring = &xrings[1],
//    .is_open  = 0,
//    .id_major = 0,
//};





////////////////////////////////////////////////////////////////////////////////
//  DMA  ///////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


static int xdma6_request_channels(struct device *dev) {
    int status = 0;
    struct dma_chan *tx_chan;
    struct dma_chan *rx_chan;
    //    struct dma_slave_config tx_conf;
    //    struct dma_slave_config rx_conf;    

    /* Allocate DMA slave channels */
    tx_chan = dma_request_slave_channel(dev, "dma0");
    if (IS_ERR(tx_chan)) {
        status = PTR_ERR(tx_chan);
        pr_err("xilinx_dmatest: No Tx channel\n");
        dma_release_channel(tx_chan);
        return -EFAULT;
    }

    rx_chan = dma_request_slave_channel(dev, "dma1");
    if (IS_ERR(rx_chan)) {
        status = PTR_ERR(rx_chan);
        pr_err("xilinx_dmatest: No Rx channel\n");
        dma_release_channel(tx_chan);
        dma_release_channel(rx_chan);
        return -EFAULT;
    }

    xdev.tx_chan = tx_chan;
    xdev.rx_chan = rx_chan;

    return status;
}


static int xdma6_release_channels(void) {
//    example5_release_all_rings();
    dma_release_channel(xdev.rx_chan);
    dma_release_channel(xdev.tx_chan);
    return 0;
}



////////////////////////////////////////////////////////////////////////////////
//  RING  //////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


static int ring_init(struct xdma6_ring *r) {
    r->r_pos = NULL;
    r->w_pos = NULL;
    r->buffers.next = &r->buffers;
    r->buffers.prev = &r->buffers;
    return 0;
}

static int ring_add(struct xdma6_ring *r, struct xdma6_buffer *b) {
    int status = 0;
    list_add(&b->node,&r->buffers);
    ++r->info.ring_size;
    return status;
}

static int ring_remove(struct xdma6_ring *r, struct xdma6_buffer *b) {
    list_del(&b->node);
    --r->info.ring_size;
    return 0;
}

static int ring_read_next(struct xdma6_ring *ring, struct xdma6_buffer **buf) {
    *buf = list_next_entry(ring->r_pos,node);
    if(*buf != ring->w_pos) {
        ring->r_pos = *buf;
        return 0;
    }
    else return 1;
}

static int ring_write_next(struct xdma6_ring *ring, struct xdma6_buffer **buf) {
    *buf = list_next_entry(ring->w_pos,node);
    if(*buf != ring->r_pos) {
        ring->w_pos = *buf;
        return 0;
    }
    else return 1;
}





static int xdma6_request_ring(struct xdma6_ring **ring,
                              const struct xdma6_ring_info * const info) {
    int i,j;
    int status = 0;
    int size = info->buffer_size;
    int len  = info->ring_size;
    int * data;
    struct device *dev = xdev.device->dev;
    struct xdma6_buffer *buf;
    struct xdma6_ring *r = *ring;


    printk( KERN_DEBUG"entering request for ring\n");

    // select ring //
    if(!r) r = info->flags & xdma_MEM_TO_DEV ? xdev.tx_ring : xdev.rx_ring;
    if(!r) return -EFAULT;

    if(r->info.ring_size == 0) {
        // allocate buffers
        printk(KERN_DEBUG"allocating buffers %dx%d\n", len, size);
        for(i=0; i<len; i++) {
            buf = (struct xdma6_buffer *)
                    kmalloc(sizeof(struct xdma6_buffer),GFP_KERNEL);
            buf->info.data = NULL;
            buf->info.offset = 0;
            buf->info.kp_data = buf;
            buf->data = dma_alloc_coherent(dev,size,&buf->handle,GFP_KERNEL);
            if(!buf->data || !buf->handle) {
                printk(KERN_ERR"unable to allocate dma ring buffers\n");
                status = -ENOMEM;
                break;
            } else {
                list_add((struct list_head*)buf,&r->buffers);
                buf->info.size = size;
                r->info.buffer_size = size;
                ++r->info.ring_size;

                // only for testing buffer content //
                data = (int*)buf->data;
                for(j=0;j<size/sizeof(int);++j) data[j] = j;
            }
        }
        r->r_pos = list_first_entry(&r->buffers,struct xdma6_buffer,node);
        r->w_pos = list_first_entry(&r->buffers,struct xdma6_buffer,node);
    }

    // INTERNAL TEST //    
    if(r->info.flags & xdma_SELFCHECK) {
        buf = r->r_pos;

        // check if empty //
        if(!r->info.ring_size)
            return -EFAULT;

        // check if circular //
        for(i=0; i<r->info.ring_size+1; ++i)
            buf = list_next_entry(buf,node);
        if(buf != r->r_pos) {
            printk(KERN_ERR"ring not sane!\n");
            return -EFAULT;
        }
    }

    *ring = r;
    return status;
}


static int xdma6_release_ring(struct xdma6_ring_info *info) {
    struct list_head *pos;
    struct list_head *n;
    struct xdma6_buffer *buf;
    struct device *dev = xdev.device->dev;
    struct xdma6_ring *r = info->flags & xdma_MEM_TO_DEV ? xdev.tx_ring : xdev.rx_ring;

    if(r && dev) {
        list_for_each_prev_safe(pos,n,&r->buffers) {
            buf = list_entry(pos,struct xdma6_buffer,node);
            dma_free_coherent(dev,r->info.buffer_size,buf->data,buf->handle);
            ring_remove(r,buf);
        }
        *info = r->info;
    }

    if(r->info.flags & xdma_SELFCHECK)
        if(r->info.ring_size)
            return -EFAULT;

    return 0;
}


static int xdma6_release_all_rings(void) {
    xdma6_release_ring(&xdev.tx_ring->info);
    xdma6_release_ring(&xdev.rx_ring->info);
    return 0;
}



static int xdma6_request_buffer(struct xdma6_buffer_info *info) {
    int status = 0;
    struct xdma6_ring *r = 0;
    struct xdma6_buffer *buf = 0;

    status = down_trylock(&map_buffer_sem);
    if(status) return -EAGAIN;

    if(info->flags & xdma_MEM_TO_DEV) {
        r = xdev.tx_ring;
        status = ring_write_next(r,&buf);
    }
    else {
        r = xdev.rx_ring;
        status = ring_read_next(r,&buf);
    }

    map_buffer = buf;
    *info = buf->info;

    return status;
}


static int xdma6_release_buffer(struct xdma6_buffer_info *info) {
    int status = 0;
    struct xdma6_buffer *buf = (struct xdma6_buffer *)info->kp_data;

    up(&map_buffer_sem);
    *info = buf->info;
    return status;
}



////////////////////////////////////////////////////////////////////////////////
//  FOPS  //////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// OPEN //
static int device_open(struct inode *inode, struct file *file)
{
    if (xdev.is_open) return -EBUSY;
    else ++xdev.is_open;
    return 0;
}


// CLOSE //
static int device_release(struct inode *inode, struct file *file)
{
    --xdev.is_open;
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
    unsigned long requested_size = vma->vm_end - vma->vm_start;
    struct xdma6_buffer *buf = map_buffer;

    printk("MMAP %d\n",PAGE_SIZE);

    if(!buf) return -EAGAIN;
    status = down_trylock(&map_buffer_sem);
    if(status) {
        buf->info.offset = map_offset;
        map_offset += (buf->info.size/PAGE_SIZE)*PAGE_SIZE;
        if(buf->info.size%PAGE_SIZE > 0)
            map_offset += PAGE_SIZE;
    }
    else {
        up(&map_buffer_sem);
        printk("prblem in lock mmap\n");
        status = -EAGAIN;
    }

    if(requested_size < buf->info.size) {
        printk(KERN_ERR"requested wrong size: %d vs %d\n",
               (int)requested_size, buf->info.size);
        return EAGAIN;
    }

    // remap pages source //
    vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
    status = remap_pfn_range(vma, vma->vm_start,
                             virt_to_pfn(buf->data),
                             buf->info.size, vma->vm_page_prot);
    if (status) {
        printk(KERN_ERR
               "<%s> Error: in calling remap_pfn_range: returned %d\n",
               MODULE_NAME, status);
        return -EAGAIN;
    }

    return status;
}

// IOCTL //
static long device_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
{
    int status = 0;
    struct xdma6_ring   *ring = NULL;
    struct xdma6_buffer *buf  = NULL;
    struct xdma6_ring_info   r_info;
    struct xdma6_buffer_info b_info;

    switch (cmd) {
    case XDMA_REQ_RING:
        printk(KERN_DEBUG "<%s> ioctl: XDMA_REQ_RING\n", MODULE_NAME);
        status = copy_from_user(&r_info,(const void *)arg, sizeof(struct xdma6_ring_info));
        if(status) return -EFAULT;
        status = xdma6_request_ring(&ring,&r_info);
        if(status) return -EFAULT;
        status = copy_to_user((void *)arg,&ring->info,sizeof(struct xdma6_ring_info));
        if(status) return -EFAULT;
        break;

    case XDMA_REL_RING:
        printk(KERN_DEBUG "<%s> ioctl: XDMA_REL_RING\n", MODULE_NAME);
        status = copy_from_user(&r_info,(const void *)arg, sizeof(struct xdma6_ring_info));
        if(status) return -EFAULT;
        status = xdma6_release_ring(&r_info);
        if(status) return -EFAULT;
        status = copy_to_user((void *)arg,&r_info,sizeof(struct xdma6_ring_info));
        if(status) return -EFAULT;
        break;

    case XDMA_REL_RINGS:
        xdma6_release_all_rings();
        break;

    case XDMA_REQ_BUFFER:
        printk(KERN_DEBUG "<%s> ioctl: XDMA_REQ_BUFFER\n", MODULE_NAME);
        status = copy_from_user(&b_info,(const void *)arg, sizeof(struct xdma6_buffer_info));
        if(status) return -EFAULT;
        status = xdma6_request_buffer(&b_info);
        if(status) return -EFAULT;
        status = copy_to_user((void *)arg,&b_info,sizeof(struct xdma6_buffer_info));
        if(status) return -EFAULT;
        break;

    case XDMA_ENQ_BUFFER:
        printk(KERN_DEBUG "<%s> ioctl: XDMA_ENQ_BUFFER\n", MODULE_NAME);
        status = copy_from_user(&b_info,(const void *)arg, sizeof(struct xdma6_buffer_info));
        if(status) return -EFAULT;
        status = xdma6_release_buffer(&b_info);
        if(status) return -EFAULT;
        status = copy_to_user((void *)arg,&b_info,sizeof(struct xdma6_buffer_info));
        if(status) return -EFAULT;
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
    mask |= POLLOUT | POLLWRNORM;
    return mask;
}





////////////////////////////////////////////////////////////////////////////////
//  PLATFORM  //////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


static int example6_probe(struct platform_device *pdev)
{
    int err = 0;
    int major;

    // CHAR DEV //
    printk("registering char dev %s ...\n",pdev->name);
    major = register_chrdev(0, DEVICE_NAME, &fops);
    if (major < 0) {
        printk ("Registering the character device failed with %d\n", major);
        return major;
    }
    printk(KERN_NOTICE "mknod /dev/xdma c %d 0\n", major);

    // setup device //
    xdev.pdev = pdev;
    xdev.device  = NULL;
    xdev.rx_chan = NULL;
    xdev.tx_chan = NULL;
    xdev.tx_ring = &xrings[0];
    xdev.rx_ring = &xrings[1];
    xdev.is_open  = 0;
    xdev.id_major = major;

    ring_init(xdev.tx_ring);
    ring_init(xdev.rx_ring);

    // REQUST CHANNELS //    
    err = xdma6_request_channels(&pdev->dev);

    if(!err) {
        xdev.device = xdev.tx_chan->device;
        xdev.tx_ring->channel = xdev.tx_chan;
        xdev.rx_ring->channel = xdev.rx_chan;
    }

    return err;
}

static int example6_remove(struct platform_device *pdev)
{
    int err = 0;
    printk("PLATFORM DEVICE REMOVE...\n");
    err = xdma6_release_channels();
    unregister_chrdev(xdev.id_major, DEVICE_NAME);
    return err;
}

static const struct of_device_id example6_of_ids[] = {
{ .compatible = "xlnx,axi-dma-test-1.00.a",}, {} };

static struct platform_driver example6_driver = {
    .driver = {
        .name = "example6",
        .owner = THIS_MODULE,
        .of_match_table = example6_of_ids,
    },
    .probe = example6_probe,
    .remove = example6_remove,
};

static int __init example6_init(void)
{
    printk(KERN_INFO "example6 module initialized\n");
    return platform_driver_register(&example6_driver);
}

static void __exit example6_exit(void)
{
    printk(KERN_INFO "example6 module exited\n");
    platform_driver_unregister(&example6_driver);
}

module_init(example6_init);
module_exit(example6_exit);
MODULE_LICENSE("GPL");
