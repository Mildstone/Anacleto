/* AXI DMA Example 0
*
* This is only meant to see how to declare a driver for a platform device. this
* example does nothing, you can start the driver using insmod axidma_example0
* and remove the same using rmmod. Once the driver loads it starts searching
* for the platform device called "axi-dma-test-1.00.a" in the device tree
* loaded into kernel. So that to make it properly functioning the device must
* be set in the device tree prior to the kernel load or with the online layers.
* 
* dts device tree example:
* 
*        amba_pl: amba_pl {
*                #address-cells = <1>;
*                #size-cells = <1>;
*                compatible = "simple-bus";
*                ranges ;
*                axi_dma_0: dma@40400000 {
*                        #dma-cells = <1>;
*                        compatible = "xlnx,axi-dma-1.00.a";
*                        interrupt-parent = <&intc>;
*                        interrupts = <0 29 4 0 30 4>;
*                        reg = <0x40400000 0x400000>;
*                        xlnx,include-sg ;
*                        linux,phandle = <0x6>;
*                        phandle = <0x6>;
*
*                        dma-channel@40400000 {
*                                compatible = "xlnx,axi-dma-mm2s-channel";
*                                interrupts = <0 29 4>;
*                                xlnx,datawidth = <0x40>;
*                                xlnx,device-id = <0x0>;
*                        };
*                        dma-channel@40400030 {
*                                compatible = "xlnx,axi-dma-s2mm-channel";
*                                interrupts = <0 30 4>;
*                                xlnx,datawidth = <0x40>;
*                                xlnx,device-id = <0x0>;
*                        };
*                };
*        
*                dmatest@0 {
*                        compatible = "xlnx,axi-dma-test-1.00.a";
*                        dmas = <0x6 0x0 0x6 0x1>;
*                        dma-names = "dma0", "dma1";
*                };
*
*        };
* 
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
    { .compatible = "xlnx,axi-dma-1.00.a",},
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
