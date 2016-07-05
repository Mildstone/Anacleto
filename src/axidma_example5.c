


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
    // please adda check
    b->handle = kmalloc(ring_size * sizeof(dma_addr_t),GFP_KERNEL);
    // please adda check
    b->dev = &pdev->dev;
    b->r_pos = b->w_pos = 0;
    b->ring_size = ring_size;
    b->data_size = data_size;
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
    complete(&b->w_cmp);
    b->w_pos = (b->w_pos + 1) % b->ring_size;
    reinit_completion(&b->w_cmp);
    if( (b->w_pos - b->r_pos) % b->ring_size == 1 ) {        
        b->flags |= RING_BUFFER_OVERFLOW;        
        return -1;
    } 
    return SUCCESS;
}

static int xdma_ring_readfwd(struct xdma_ring_buffer *b) {    
    if( (b->w_pos - b->r_pos) % b->ring_size != -1 ) {
        b->r_pos = (b->r_pos + 1) % b->ring_size;
        return SUCCESS;
    } 
    else return -EAGAIN;
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
    while( counter < 200000 ) {
        xdma_ring_writefwd(r);
        int *data = (int*)(r->data[r->w_pos]);
        for ( i=0; i < r->data_size/4 ; ++i ) 
            data[i] = counter++;
    }    
    complete(&writer_completion);
    return SUCCESS;
}


static void axidma_test_ring_read_callback(void * _rx_desc)
{
    xdma_ring_writefwd(&dst_ring);
    
    printk("r");
    
    int *data = (int *)dst_ring.data[dst_ring.r_pos];
    int len = dst_ring.data_size;
    struct dma_async_tx_descriptor * rx = (struct dma_async_tx_descriptor *)_rx_desc;
    dst_ring.handle = dma_map_single(rx->chan, data, len, DMA_DEV_TO_MEM);
    rx = dmaengine_prep_slave_single(rx->chan, dst_ring.handle, len, DMA_DEV_TO_MEM, rx->flags);
    memcpy(_rx_desc,rx, sizeof (struct dma_async_tx_descriptor) );
    if (!rx) {
		printk(KERN_ERR "prep_slave_single error\n");
		rx->cookie = -EBUSY;
	} else {
        rx->callback = axidma_test_ring_read_callback;
        rx->callback_param = _rx_desc;
        rx->cookie = dmaengine_submit(rx);
    }
//    dma_async_issue_pending(rx_chan);   
}

static void axidma_test_ring_write_callback(void * _tx_desc)
{    
    while( xdma_ring_readfwd(&src_ring) != SUCCESS )
        wait_for_completion(&src_ring.w_cmp);
    
    printk("w");
    
    
    int *data = (int *)src_ring.data[src_ring.r_pos];
    int len = src_ring.data_size;
    struct dma_async_tx_descriptor * tx = (struct dma_async_tx_descriptor *)_tx_desc;
    
    enum dma_status status;
    
//    status = dma_async_is_tx_complete(chan, cookie, NULL, NULL);
    
    
    tx = dmaengine_prep_slave_single(tx->chan, data, len, DMA_MEM_TO_DEV, tx->flags);
    memcpy(_tx_desc,tx, sizeof (struct dma_async_tx_descriptor) );
    if (!tx) {
		printk(KERN_ERR "prep_slave_single error\n");
		tx->cookie = -EBUSY;
	} else {
        tx->callback = axidma_test_ring_write_callback;
        tx->callback_param = _tx_desc;
        tx->cookie = dmaengine_submit(tx);
    }
//    dma_async_issue_pending(tx_chan);
}


static struct dma_async_tx_descriptor tx_desc;
static struct dma_async_tx_descriptor rx_desc;

static int axidma_test_ring(void) {

    int i=0;
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

    printk("INIT PASSED\n");
    
    // start writing thread into src_ring //
    struct task_struct *task;
    init_completion(&writer_completion);
    
//    axidma_test_ring_writer_handler(&src_ring);
//    printk("RING FILL PASSED\n");

//    task = kthread_create( axidma_test_ring_writer_handler, &src_ring,
//                           "writer_ring_thread");
//    wake_up_process(task);
//    printk("RING THREAD STARTED ... waiting for completion\n");
    
    enum dma_ctrl_flags flags = DMA_PREP_INTERRUPT | DMA_PREP_CONTINUE | DMA_PREP_FENCE;
    
    dma_async_tx_descriptor_init(&rx_desc, rx_chan);    
    rx_desc.flags = flags;
    axidma_test_ring_read_callback(&rx_desc);

    dma_async_tx_descriptor_init(&tx_desc, tx_chan);    
    tx_desc.flags = flags;
    axidma_test_ring_write_callback(&tx_desc);

    for(i=0; i<50; ++i) {        
        xdma_ring_writefwd(&src_ring);
        dma_async_issue_pending(rx_chan);
        dma_async_issue_pending(tx_chan);
        mdelay(100);
    }
    
//    wait_for_completion(&writer_completion);
    printk("\nRING THREAD COMPLETED\n");
    
    return SUCCESS;
}


