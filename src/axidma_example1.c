/* AXI DMA Example
*
* This small example is intended to simply llustate how to use the DMA engine 
* of Linux to take advantage of DMA in the PL. The hardware design is intended
* to be an AXI DMA without scatter gather and with the transmit channel looped
* back to the receive channel. 
*
*/

#include <linux/dmaengine.h>
#include <linux/module.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/dma-mapping.h>
#include <linux/slab.h>
#include <linux/amba/xilinx_dma.h>

#include <linux/platform_device.h>

static struct dma_chan *tx_chan;
static struct dma_chan *rx_chan;
static struct completion tx_cmp;
static struct completion rx_cmp;
static dma_cookie_t tx_cookie;
static dma_cookie_t rx_cookie;
static dma_addr_t tx_dma_handle;
static dma_addr_t rx_dma_handle;

#define WAIT 	1
#define NO_WAIT 0

/* Handle a callback and indicate the DMA transfer is complete to another
 * thread of control
 */
static void axidma_sync_callback(void *completion)
{
	/* Step 9, indicate the DMA transaction completed to allow the other
	 * thread of control to finish processing
	 */ 

	complete(completion);

}

/* Prepare a DMA buffer to be used in a DMA transaction, submit it to the DMA engine 
 * to queued and return a cookie that can be used to track that status of the 
 * transaction
 */
static dma_cookie_t axidma_prep_buffer(struct dma_chan *chan, dma_addr_t buf, size_t len, 
					enum dma_transfer_direction dir, struct completion *cmp) 
{
	enum dma_ctrl_flags flags = DMA_CTRL_ACK | DMA_PREP_INTERRUPT;
	struct dma_async_tx_descriptor *chan_desc;
	dma_cookie_t cookie;

	/* Step 5, create a buffer (channel)  descriptor for the buffer since only a  
	 * single buffer is being used for this transfer
	 */

	chan_desc = dmaengine_prep_slave_single(chan, buf, len, dir, flags);

	/* Make sure the operation was completed successfully
	 */
	if (!chan_desc) {
		printk(KERN_ERR "dmaengine_prep_slave_single error\n");
		cookie = -EBUSY;
	} else {
		chan_desc->callback = axidma_sync_callback;
		chan_desc->callback_param = cmp;

		/* Step 6, submit the transaction to the DMA engine so that it's queued
		 * up to be processed later and get a cookie to track it's status
		 */

		cookie = dmaengine_submit(chan_desc);
	
	}
	return cookie;
}

/* Start a DMA transfer that was previously submitted to the DMA engine and then
 * wait for it complete, timeout or have an error
 */
static void axidma_start_transfer(struct dma_chan *chan, struct completion *cmp, 
					dma_cookie_t cookie, int wait)
{
	unsigned long timeout = msecs_to_jiffies(3000);
	enum dma_status status;

	/* Step 7, initialize the completion before using it and then start the 
	 * DMA transaction which was previously queued up in the DMA engine
	 */

	init_completion(cmp);
	dma_async_issue_pending(chan);

	if (wait) {
		printk("Waiting for DMA to complete...\n");

		/* Step 8, wait for the transaction to complete, timeout, or get
		 * get an error
		 */

		timeout = wait_for_completion_timeout(cmp, timeout);
		status = dma_async_is_tx_complete(chan, cookie, NULL, NULL);

		/* Determine if the transaction completed without a timeout and
		 * withtout any errors
		 */
		if (timeout == 0)  {
			printk(KERN_ERR "DMA timed out\n");
		} else if (status != DMA_COMPLETE) {
			printk(KERN_ERR "DMA returned completion callback status of: %s\n",
			       status == DMA_ERROR ? "error" : "in progress");
		}
	}
}

static void axidma_test_transfer(void)
{
	const int dma_length = 4*1024*1024; //4MB
	int i;

	/* Step 3, allocate cached memory for the transmit and receive buffers to use for DMA
	 * zeroing the destination buffer
	 */

    //	char *src_dma_buffer = kmalloc(dma_length, GFP_KERNEL);
    //	char *dest_dma_buffer = kzalloc(dma_length, GFP_KERNEL);
    char *src_dma_buffer = dma_alloc_coherent(tx_chan->device->dev,dma_length,&tx_dma_handle,GFP_KERNEL);
    char *dest_dma_buffer = dma_alloc_coherent(rx_chan->device->dev,dma_length,&rx_dma_handle,GFP_KERNEL);
        
	if (!src_dma_buffer || !dest_dma_buffer) {
		printk(KERN_ERR "Allocating DMA memory failed\n");
		return;
	}

	/* Initialize the source buffer with known data to allow the destination buffer to
	 * be checked for success
	 */
	for (i = 0; i < dma_length; i++) 
		src_dma_buffer[i] = i;

	/* Step 4, since the CPU is done with the buffers, transfer ownership to the DMA and don't
	 * touch the buffers til the DMA is done, transferring ownership may involve cache operations
	 */

	tx_dma_handle = dma_map_single(tx_chan->device->dev, src_dma_buffer, dma_length, DMA_TO_DEVICE);	
	rx_dma_handle = dma_map_single(rx_chan->device->dev, dest_dma_buffer, dma_length, DMA_FROM_DEVICE);	
	
	/* Prepare the DMA buffers and the DMA transactions to be performed and make sure there was not
	 * any errors
	 */
    tx_cookie = axidma_prep_buffer(tx_chan, tx_dma_handle, dma_length, DMA_MEM_TO_DEV, &tx_cmp);
	rx_cookie = axidma_prep_buffer(rx_chan, rx_dma_handle, dma_length, DMA_DEV_TO_MEM, &rx_cmp);

	if (dma_submit_error(rx_cookie) || dma_submit_error(tx_cookie)) {
		printk(KERN_ERR "xdma_prep_buffer error\n");
		return;
	}

	printk(KERN_INFO "Starting DMA transfers\n");

	/* Start both DMA transfers and wait for them to complete
	 */
	axidma_start_transfer(rx_chan, &rx_cmp, rx_cookie, NO_WAIT);
	axidma_start_transfer(tx_chan, &tx_cmp, tx_cookie, WAIT);

	/* Step 10, the DMA is done with the buffers so transfer ownership back to the CPU so that
	 * any cache operations needed are done
	 */

	dma_unmap_single(rx_chan->device->dev, rx_dma_handle, dma_length, DMA_FROM_DEVICE);	
	dma_unmap_single(tx_chan->device->dev, tx_dma_handle, dma_length, DMA_TO_DEVICE);

	/* Verify the data in the destination buffer matches the source buffer 
	 */
	for (i = 0; i < dma_length; i++) {
		if (dest_dma_buffer[i] != src_dma_buffer[i]) {
			printk(KERN_INFO "DMA transfer failure");
			break;	
		}
	}

	printk(KERN_INFO "DMA bytes sent: %d\n", dma_length);

	/* Step 11, free the buffers used for DMA back to the kernel */

    dma_free_coherent(tx_chan->device->dev,dma_length,src_dma_buffer,tx_dma_handle);
    dma_free_coherent(rx_chan->device->dev,dma_length,dest_dma_buffer,rx_dma_handle);
    //	kfree(src_dma_buffer);
    //	kfree(dest_dma_buffer);	
    
}

// OLD code (not supported in 4.x? ) ///////////////////////////////////////
//
// static bool filter(struct dma_chan *chan, void *param) {
//    printk(" chan -> %d :",chan );
//    printk(" param -> %d ",*(int*)param );
//    if(chan->private) 
//        printk(": chan->private -> %d ",*((int*)chan->private) );
//    printk(" \n",param );
//
//    if ( *((int*)chan->private) == *(int*)param )
//        return true;
//    return false;
// }

static int xilinx_axidmatest_probe(struct platform_device *pdev)
{

    int err;
    dma_cap_mask_t mask;
    
    /* Step 1, zero out the capability mask then initialize
	 * it for a slave channel that is private
	 */
    dma_cap_zero(mask);
	dma_cap_set(DMA_SLAVE | DMA_PRIVATE, mask);
    

    /* Step 2, request the transmit and receive channels for the AXI DMA
	 * from the DMA engine
	 */

    // OLD code (not supported in 4.x? ) ///////////////////////////////////////
    //
    //    u32 device_id = 0 << XILINX_DMA_DEVICE_ID_SHIFT;
    //    enum dma_transfer_direction tx_direction = DMA_MEM_TO_DEV;
    //    u32 tx_match = (tx_direction & 0xFF) | XILINX_DMA_IP_DMA | device_id;
    //    tx_chan = dma_request_channel(mask, filter, (void*)&tx_match );    
    //    enum dma_transfer_direction rx_direction = DMA_DEV_TO_MEM;
    //    u32 rx_match = (rx_direction & 0xFF) | XILINX_DMA_IP_DMA | device_id;    
    //    rx_chan = dma_request_channel(mask, filter, (void*)&rx_match );
    //
    //	if (!rx_chan || !tx_chan) {
    //		printk(KERN_INFO "DMA channel request error\n");
    //		return -1;
    //	}
    //
        
	tx_chan = dma_request_slave_channel(&pdev->dev, "dma0");
	if (IS_ERR(tx_chan)) {
		pr_err("xilinx_dmatest: No Tx channel\n");
		return PTR_ERR(tx_chan);
	}

	rx_chan = dma_request_slave_channel(&pdev->dev, "dma1");
	if (IS_ERR(rx_chan)) {
		err = PTR_ERR(rx_chan);
		pr_err("xilinx_dmatest: No Rx channel\n");
		goto free_tx;
	}    
    
    axidma_test_transfer();
	return 0;

free_rx:
	dma_release_channel(rx_chan);
free_tx:
	dma_release_channel(tx_chan);

	return 0;
}

static int xilinx_axidmatest_remove(struct platform_device *pdev)
{
    /* Step 12, release the DMA channels back to the DMA engine
	 */
    
    dma_release_channel(tx_chan);
    dma_release_channel(rx_chan);
    
	return 0;
}

static const struct of_device_id rfx_axidmatest_of_ids[] = {
	{ .compatible = "xlnx,axi-dma-test-1.00.a",},
	{}
};

static struct platform_driver rfx_axidmatest_driver = {
	.driver = {
		.name = "axidma-exaple1",
		.owner = THIS_MODULE,
		.of_match_table = rfx_axidmatest_of_ids,
	},
	.probe = xilinx_axidmatest_probe,
	.remove = xilinx_axidmatest_remove,
};

static int __init axidma_init(void)
{
	printk(KERN_INFO "AXI DMA module initialized\n");
    return platform_driver_register(&rfx_axidmatest_driver);
}

static void __exit axidma_exit(void)
{
	printk(KERN_INFO "AXI DMA module exited\n");
    platform_driver_unregister(&rfx_axidmatest_driver);
}

module_init(axidma_init);
module_exit(axidma_exit);
MODULE_LICENSE("GPL");
