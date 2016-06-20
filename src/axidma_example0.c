/* AXI DMA Example 0
*
* This is only meant to see how to declare a driver for a platform device.
*
*/

#include <linux/module.h>
#include <linux/version.h>
#include <linux/kernel.h>

#include <linux/platform_device.h>


static int xilinx_axidmatest_probe(struct platform_device *pdev)
{
    printk("PLATFORM DEVICE PROBE...\n");
	return 0;
}

static int xilinx_axidmatest_remove(struct platform_device *pdev)
{
    printk("PLATFORM DEVICE REMOVE...\n");
	return 0;
}

static const struct of_device_id rfx_axidmatest_of_ids[] = {
	{ .compatible = "xlnx,axi-dma-test-1.00.a",},
	{}
};

static struct platform_driver rfx_axidmatest_driver = {
	.driver = {
		.name = "axidma-exaple0",
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
