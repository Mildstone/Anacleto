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
#include <linux/dma/xilinx_dma.h>   // axi dma driver
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
    struct completion cmp;
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

DECLARE_WAIT_QUEUE_HEAD(wait_tx);
DECLARE_WAIT_QUEUE_HEAD(wait_rx);
DECLARE_WAIT_QUEUE_HEAD(wait_poll);


static int state_streaming = 0;
static int state_has_txdata = 0;
static int state_has_rxdata = 0;



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
    dma_release_channel(xdev.rx_chan);
    dma_release_channel(xdev.tx_chan);
    return 0;
}

//static void xdma6_device_control(struct dma_chan *chan,struct xdma6_chan_cfg *cfg)
//{
//    struct dma_device *chan_dev;
//    struct xilinx_dma_config config;

//    config.coalesc = cfg->coalesc;
//    config.delay = cfg->delay;
//    config.reset = cfg->reset;

//    if (chan) {
//        chan_dev = chan->device;
//        chan_dev->device_control(chan, DMA_SLAVE_CONFIG,
//                     (unsigned long)&config);
//    }
//}

////////////////////////////////////////////////////////////////////////////////
//  DMA TRANSFER  //////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

/* Handle a callback and indicate the DMA transfer is complete to another
 * thread of control
 */
static void axidma_test_transfer_sync_callback_tx(void *completion)
{
    printk(KERN_DEBUG" DMA transfer TX complete\n");
    wake_up_interruptible(&wait_poll);
    complete(completion);
}

static void axidma_test_transfer_sync_callback_rx(void *completion)
{
    printk(KERN_DEBUG" DMA transfer RX complete\n");
    complete(completion);
}

/* Prepare a DMA buffer to be used in a DMA transaction, submit it to the DMA engine
 * to queued and return a cookie that can be used to track that status of the
 * transaction
 */
static dma_cookie_t axidma_test_transfer_prep_buffer(struct dma_chan *chan, struct xdma6_buffer *buf,
                    enum dma_transfer_direction dir, dma_async_tx_callback cb)
{
    enum dma_ctrl_flags dma_flags = /*DMA_CTRL_ACK |*/ DMA_PREP_INTERRUPT;
    struct dma_async_tx_descriptor *chan_desc;
    dma_cookie_t cookie;

    chan_desc = dmaengine_prep_slave_single(chan, buf->handle , buf->info.size, dir, dma_flags);
    if (!chan_desc) {
        printk(KERN_ERR "dmaengine_prep_slave_single error\n");
        cookie = -EBUSY;
    } else {
        chan_desc->callback = cb;
        chan_desc->callback_param = &buf->cmp;
        cookie = dmaengine_submit(chan_desc);
    }
    init_completion(&buf->cmp);
    buf->cookie = cookie;

    return cookie;
}



////////////////////////////////////////////////////////////////////////////////
//  RING  //////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


static int ring_init(struct xdma6_ring *r) {
    r->r_pos = NULL;
    r->w_pos = NULL;
    INIT_LIST_HEAD(&r->buffers);

    r->info.flags = 0;
//    r->info.chan_cfg.coalesc = 1;
//    r->info.chan_cfg.delay   = 0;
//    r->info.chan_cfg.reset   = 0;

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


static struct xdma6_buffer * ring_has_read_next(struct xdma6_ring *ring) {
    struct xdma6_buffer *buf;
    if(!list_is_last(&ring->r_pos->node,&ring->buffers))
        buf = list_next_entry(ring->r_pos,node);
    else
        buf = list_first_entry(&ring->buffers,struct xdma6_buffer,node);
    if(buf != ring->w_pos) return buf;
    return 0;
}

static struct xdma6_buffer * ring_has_write_next(struct xdma6_ring *ring) {
    struct xdma6_buffer *buf;
    if(!list_is_last(&ring->w_pos->node,&ring->buffers))
        buf = list_next_entry(ring->w_pos,node);
    else
        buf = list_first_entry(&ring->buffers,struct xdma6_buffer,node);

    if(buf != ring->r_pos) return buf;
    return 0;
}

static int ring_read_next(struct xdma6_ring *ring, struct xdma6_buffer **buf, int over) {
    if(!list_is_last(&ring->r_pos->node,&ring->buffers))
        *buf = list_next_entry(ring->r_pos,node);
    else
        *buf = list_first_entry(&ring->buffers,struct xdma6_buffer,node);
    if(over || *buf != ring->w_pos) {
        ring->r_pos = *buf;
        return over;
    }
    else return 1;
}

static int ring_write_next(struct xdma6_ring *ring, struct xdma6_buffer **buf, int over) {
    if(!list_is_last(&ring->w_pos->node,&ring->buffers))
        *buf = list_next_entry(ring->w_pos,node);
    else
        *buf = list_first_entry(&ring->buffers,struct xdma6_buffer,node);

    if(over || *buf != ring->r_pos) {
        ring->w_pos = *buf;
        return over;
    }
    else return 1;
}





static int xdma6_request_ring(struct xdma6_ring **ring,
                              struct xdma6_ring_info * info) {
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

    // set channel control //
    //    xdma6_device_control(r->channel,&r->info.chan_cfg);

    if(r->info.ring_size == 0) {
        // allocate buffers
        printk(KERN_DEBUG"allocating buffers %dx%d\n", len, size);
        for(i=0; i<len; i++) {
            buf = (struct xdma6_buffer *)
                    kmalloc(sizeof(struct xdma6_buffer),GFP_KERNEL);
            buf->info.data = NULL;
            buf->info.offset = 0;
            buf->info.flags = info->flags;
            buf->info.kp_data = buf;
            buf->data = dma_alloc_coherent(dev,size,&buf->handle,GFP_KERNEL);
            if(!buf->data || !buf->handle) {
                printk(KERN_ERR"unable to allocate dma ring buffers\n");
                status = -ENOMEM;
                break;
            } else {
                list_add_tail(&buf->node,&r->buffers);
                buf->info.size = size;
                r->info.buffer_size = size;
                ++r->info.ring_size;

                // only for testing buffer content //
                data = (int*)buf->data;
                for(j=0;j<size/sizeof(int);++j) data[j] = j;
            }
        }
        r->info.flags = info->flags;
        r->r_pos = list_first_entry(&r->buffers,struct xdma6_buffer,node);
        r->w_pos = list_next_entry(r->r_pos,node);
    }

    // INTERNAL TEST //    
    if(info->flags & xdma_SELFCHECK) {
        buf = r->r_pos;

        // check if empty //
        if(!r->info.ring_size)
            return -EFAULT;

        // check if circular //
        for(i=0; i<3*(r->info.ring_size); ++i) {
            //            printk(" %d %d\n",i%10, &buf->node);
            if(!list_is_last(&buf->node,&r->buffers))
                buf = list_next_entry(buf,node);
            else
                buf = list_first_entry(&r->buffers,struct xdma6_buffer,node);
        }
        if(buf != r->r_pos) {
            printk(KERN_ERR"ring not sane! %d vs %d\n",&buf->node,&r->r_pos->node);
            return -EFAULT;
        }
        else
            printk(KERN_DEBUG"ring sane!\n");
    }

    *ring = r;
    return status;
}


static int xdma6_release_ring(struct xdma6_ring_info *info) {
    struct xdma6_buffer *buf;
    struct xdma6_buffer *n;
    struct device *dev = xdev.device->dev;
    struct xdma6_ring *r = info->flags & xdma_MEM_TO_DEV ? xdev.tx_ring : xdev.rx_ring;

    dmaengine_terminate_all(r->channel);

    if(r && dev) {
        printk("Releasing ring ");
        list_for_each_entry_safe_reverse(buf,n,&r->buffers,node) {
            printk(".");
            dma_free_coherent(dev,r->info.buffer_size,buf->data,buf->handle);
            ring_remove(r,buf);
        }
        printk("\n");
        r->info.ring_size = 0;
        *info = r->info;
    }

    return 0;
}


static int xdma6_release_all_rings(void) {
    xdma6_release_ring(&xdev.tx_ring->info);
    xdma6_release_ring(&xdev.rx_ring->info);
    return 0;
}



static int xdma6_request_buffer(struct xdma6_buffer_info *info) {
    int status = 0;
    int over = 0;
    struct xdma6_ring *r = 0;
    struct xdma6_buffer *buf = 0;

    status = down_trylock(&map_buffer_sem);
    if(status) return -EAGAIN;

    over = info->flags & xdma_OVERFLOW;
    if(info->flags & xdma_MEM_TO_DEV) {
        r = xdev.tx_ring;
        buf = r->w_pos;
    }
    else if(info->flags & xdma_DEV_TO_MEM)
    {
        r = xdev.rx_ring;
        status = ring_read_next(r,&buf,over);
        ++state_has_rxdata;
        wake_up_interruptible(&wait_rx);
    }
    else {
        printk(KERN_ERR "ERROR DIRECTION!! \n");
    }

    if(status && info->flags & xdma_OVERFLOW) status = 0;

    map_buffer = buf;
    *info = buf->info;

    return status;
}


static int xdma6_release_buffer(struct xdma6_buffer_info *info) {
    int over;
    int status = 0;
    struct xdma6_ring *r = 0;
    struct xdma6_buffer *buf = (struct xdma6_buffer *)info->kp_data;
    buf->info.data = info->data;

    over = info->flags & xdma_OVERFLOW;
    if(info->flags & xdma_MEM_TO_DEV) {
        r = xdev.tx_ring;
        status = ring_write_next(r,&buf,over);
        ++state_has_txdata;
        wake_up_interruptible(&wait_tx);
    }
    else  if(info->flags & xdma_DEV_TO_MEM) {
        r = xdev.rx_ring;
        buf = r->r_pos;
    }

    if(status && info->flags & xdma_OVERFLOW) status = 0;

    *info = buf->info;
    up(&map_buffer_sem);

    return status;
}





static int xdma6_stream_tx_fn(void *arg) {
    int status = 0;
    struct xdma6_ring *r = xdev.tx_ring;
    struct xdma6_buffer *buf;
    unsigned long timeout = msecs_to_jiffies(10000); // 10 sec
    enum dma_status dma_status;

//    allow_signal(SIGKILL);
//    allow_signal(SIGSTOP);

    printk(KERN_DEBUG"Started TX thread:\n");
    while(state_streaming) {
        if(kthread_should_stop()) return 0;
        // while read from TX ring
        while( ring_read_next(r,&buf,0) == SUCCESS) {
            axidma_test_transfer_prep_buffer(r->channel,
                                             buf,
                                             DMA_MEM_TO_DEV,
                                             axidma_test_transfer_sync_callback_tx);
            if (dma_submit_error(buf->cookie)) {
                printk(KERN_ERR "xdma_prep_buffer error\n");
                return -EIO;
            }
            else {
                printk(KERN_DEBUG "xdma_prep_buffer tx ok\n");
            }
            // - issue
            printk(KERN_DEBUG"TX sent %d %d\n",buf->info.kp_data,(int)buf->data[0]);
            dma_async_issue_pending(r->channel);

            timeout = msecs_to_jiffies(10000);
            timeout = wait_for_completion_interruptible_timeout(&buf->cmp, timeout);
            if(kthread_should_stop()) printk("Thread should stop TX!!\n");
            dma_status = dma_async_is_tx_complete(r->channel, buf->cookie, NULL, NULL);
            if (timeout == 0)  {
                printk(KERN_ERR "DMA TX timed out\n");
                status = -EAGAIN;
                state_streaming = 0;
                break;
            } else if (dma_status != DMA_COMPLETE) {
                printk(KERN_ERR "DMA TX returned completion callback status of: %s\n",
                       dma_status == DMA_ERROR ? "error" : "in progress");
                status = (int)dma_status;
                state_streaming = 0;
                break;
            }
        }

        // subscribe(wqueue)

        printk(KERN_DEBUG"Start waiting into wait_tx\n");
        state_has_txdata = 0;
        status = wait_event_interruptible(wait_tx, state_has_txdata || kthread_should_stop());
        if(status) {
            state_streaming = 0;
            break;
        }
        //        if(status == 0 || status == -ERESTARTSYS) {
        //            state_streaming = 0;
        //            do_exit(status);
        //            break;
        //        }
    }
    return status;
}

static int xdma6_stream_rx_fn(void *arg) {
    int status = 0;
    struct xdma6_ring *r = xdev.rx_ring;
    struct xdma6_buffer *buf;
    unsigned long timeout; // = msecs_to_jiffies(10000); // 10 sec
    enum dma_status dma_status;

    allow_signal(SIGKILL);
    allow_signal(SIGSTOP);

    printk(KERN_DEBUG"Started RX thread:\n");
    buf = r->w_pos;
    while(state_streaming) {
        // while DMA writes from RX ring
        buf->cookie = axidma_test_transfer_prep_buffer(r->channel,
                                                       buf,
                                                       DMA_DEV_TO_MEM,
                                                       axidma_test_transfer_sync_callback_rx);
        if (dma_submit_error(buf->cookie)) {
            printk(KERN_ERR "xdma_prep_buffer error\n");
            return -EIO;
        }
        else
            printk(KERN_DEBUG "xdma_prep_buffer rx ok\n");

        // - issue
        dma_async_issue_pending(r->channel);
//        printk("issued RX pending ... \n");

        //  wait cmp
        timeout = msecs_to_jiffies(10000);
        timeout = wait_for_completion_killable_timeout(&buf->cmp, timeout);
        if(timeout == -ERESTARTSYS) {
            if(kthread_should_stop()) printk(KERN_ERR"should stop..\n");
            break;
        }
        dma_status = dma_async_is_tx_complete(r->channel, buf->cookie, NULL, NULL);
        if (timeout == 0)  {
            printk(KERN_ERR "- DMA RX timed out\n");
            status = -EAGAIN;
            state_streaming = 0;
            break;
        } else if (dma_status != DMA_COMPLETE) {
            printk(KERN_ERR "DMA RX returned completion callback status of: %s\n",
                   dma_status == DMA_ERROR ? "error" : "in progress");
            status = (int)dma_status;
            state_streaming = 0;
            break;
        }

        printk(KERN_DEBUG "Received buffer no.%d\n",buf->info.kp_data);
        ring_write_next(r,&buf,1);
        wake_up_interruptible(&wait_poll);

    }

    return status;
}



static struct task_struct *task_tx = 0;
static struct task_struct *task_rx = 0;

static int xdma6_start_stream(void) {
    state_streaming = 1;
    // starts a kernel thread to fill up the buffer //
    task_tx = kthread_run(xdma6_stream_tx_fn, NULL, "tx_dmaq");
    task_rx = kthread_run(xdma6_stream_rx_fn, NULL, "rx_dmaq");
    return SUCCESS;
}

static int xdma6_stop_stream(void) {
    state_streaming = 0;
    printk("Try to stop streaming !!!\n");
    // starts a kernel thread to fill up the buffer //
    if(task_tx) kthread_stop(task_tx);
    if(task_rx) kthread_stop(task_rx);
    return SUCCESS;
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
        return -EAGAIN;
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

    case XDMA_START_STREAM:
        status = xdma6_start_stream();
        break;
    case XDMA_STOP_STREAM:
        status = xdma6_stop_stream();
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

    poll_wait(file,&wait_poll,p);
    if( ring_has_read_next(xdev.rx_ring) )
        mask |= POLLIN | POLLRDNORM;
    if( ring_has_write_next(xdev.tx_ring) )
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
    xdev.tx_ring->info.flags |= xdma_MEM_TO_DEV;
    xdev.rx_ring->info.flags |= xdma_DEV_TO_MEM;

    // REQUST CHANNELS //    
    err = xdma6_request_channels(&pdev->dev);

    if(!err) {
        xdev.device = xdev.tx_chan->device;
        xdev.tx_ring->channel = xdev.tx_chan;
        xdev.rx_ring->channel = xdev.rx_chan;
    } else {
        printk(KERN_ERR"Error probing device! \n");
    }

    return err;
}

static int example6_remove(struct platform_device *pdev)
{
    int err = 0;
    printk("PLATFORM DEVICE REMOVE...\n");
    dmaengine_terminate_all(xdev.tx_chan);
    dmaengine_terminate_all(xdev.rx_chan);
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

