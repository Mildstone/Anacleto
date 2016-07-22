#include <linux/module.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/platform_device.h>

#include <linux/dmaengine.h>






static int example6_probe(struct platform_device *pdev)
{
    int err;
    dma_cap_mask_t mask;

    // CHANNEL CAPS //
    dma_cap_zero(mask);
	dma_cap_set(DMA_SLAVE | DMA_PRIVATE, mask);
    
    // REQUEST CHANNELS //
    tx_chan = dma_request_slave_channel(&pdev->dev, "dma0");
	if (IS_ERR(tx_chan)) {
		pr_err("xilinx_dmatest: No Tx channel\n");
        return PTR_ERR(tx_chan);
	}

    rx_chan = dma_request_slave_channel(&pdev->dev, "dma1");
	if (IS_ERR(rx_chan)) {
		pr_err("xilinx_dmatest: No Rx channel\n");
        dma_release_channel(tx_chan);
        return PTR_ERR(rx_chan);
	}    
    
    axidma_test_transfer();
	return 0;
}

static int example6_remove(struct platform_device *pdev)
{
    printk("PLATFORM DEVICE REMOVE...\n");
    return 0;
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
