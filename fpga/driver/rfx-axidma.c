/*
 * Wrapper Driver used to control a two-channel Xilinx DMA Engine
 */
#include <linux/dmaengine.h>
#include "rfx-axidma.h"

#include <linux/module.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/types.h>
#include <linux/kdev_t.h>
#include <linux/fs.h>
#include <linux/device.h>
#include <linux/cdev.h>

// added by me
#include <linux/spinlock.h>

#include <linux/dma-mapping.h>
#include <xen/page.h>

#include <linux/slab.h>
#include <linux/amba/xilinx_dma.h>
#include <linux/platform_device.h>

#include <asm/uaccess.h>

static dev_t dev_num;		// Global variable for the device number
static struct cdev c_dev;	// Global variable for the character device structure
static struct class *cl;	// Global variable for the device class



struct dma_chan *tx_chan, *rx_chan;


////////////////////////////////////////////////////////////////////////////////
//  RING  ////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

struct xdma_ring_buffer{
    uint16_t      size;
    uint8_t       r_pos, w_pos;
    char **       data;
    dma_addr_t *  handle;
    struct device *dev;
};

struct xdma_ring_buffer xdma_ring;

static int xdma_ring_init(struct platform_device *pdev, 
                          struct xdma_ring_buffer *buffer, 
                          uint32_t size) 
{
    if(!buffer || !pdev || !size) return -EINVAL;
    buffer->data   = kzalloc(size * sizeof(char *),GFP_KERNEL);
    buffer->handle = kmalloc(size * sizeof(dma_addr_t),GFP_KERNEL);
    buffer->dev = &pdev->dev;
    buffer->r_pos = buffer->w_pos = 0;

    int i,status = 0;
    for(i=0; i<size; ++i) {
        buffer->data[i] = dma_zalloc_coherent(buffer->dev, DMA_LENGTH,
                                              &buffer->handle[i], GFP_KERNEL);
        if(!buffer->data[i]) ++status;
    }
    if (status != size) return -ENOMEM;
    return 1;
}

static void xdma_ring_free(struct xdma_ring_buffer *buffer) {
    int i;
    if(!buffer) return;        
    for(i=0; i<buffer->size; ++i) {
        if(buffer->data[i])
            dma_free_coherent(buffer->dev, DMA_LENGTH, 
                              buffer->data[i], buffer->handle[i]);
    }
}

static int xdma_ring_hasdata(const struct xdma_ring_buffer *buffer) {
    return buffer->r_pos != buffer->w_pos;
}





////////////////////////////////////////////////////////////////////////////////
//  IOCTL  /////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


static long xdma_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
{
	long ret = 0;
//	struct xdma_dev xdma_dev;
//	struct xdma_chan_cfg chan_cfg;
//	struct xdma_buf_info buf_info;
//	struct xdma_transfer trans;
//	u32 devices;
//	u32 chan;

	switch (cmd) {

	default:
		break;
	}

	return ret;
}



////////////////////////////////////////////////////////////////////////////////
//  FD OPERATIONS  /////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

static int xdma_open(struct inode *i, struct file *f)
{
	printk(KERN_DEBUG "<%s> file: open()\n", MODULE_NAME);
	return 0;
}

static int xdma_close(struct inode *i, struct file *f)
{
	printk(KERN_DEBUG "<%s> file: close()\n", MODULE_NAME);
	return 0;
}

//static ssize_t xdma_read(struct file *f, char __user * buf, size_t
//			 len, loff_t * off)
//{
//	printk(KERN_DEBUG "<%s> file: read()\n", MODULE_NAME);

//	return simple_read_from_buffer(buf, len, off, xdma_addr, DMA_LENGTH);
//}

//static ssize_t xdma_write(struct file *f, const char __user * buf,
//			  size_t len, loff_t * off)
//{
//	printk(KERN_DEBUG "<%s> file: write()\n", MODULE_NAME);
//	if (len > (DMA_LENGTH - 1))
//		return -EINVAL;

//	if (copy_from_user(xdma_addr, buf, len))
//		return -EFAULT;

//	xdma_addr[len] = '\0';
//	return len;
//}

static int xdma_mmap(struct file *filp, struct vm_area_struct *vma)
{
	int result;
	unsigned long requested_size;
	requested_size = vma->vm_end - vma->vm_start;

	printk(KERN_DEBUG "<%s> file: mmap()\n", MODULE_NAME);
	printk(KERN_DEBUG "<%s> file: memory size reserved: %d, mmap size requested: %lu\n",
           MODULE_NAME, DMA_LENGTH, requested_size);

	if (requested_size > DMA_LENGTH) {
		printk(KERN_ERR "<%s> Error: %d reserved != %lu requested)\n",
		       MODULE_NAME, DMA_LENGTH, requested_size);
		return -EAGAIN;
	}

    if( xdma_ring_hasdata(xdma_ring) ) {
        printk(KERN_ERR "<%s> Error: dma buffer is empty)\n", MODULE_NAME);
        return 0;
    }                
    
	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
	result = remap_pfn_range(vma, vma->vm_start, virt_to_pfn(xdma_ring.data[]),
				 requested_size, vma->vm_page_prot);

//	if (result) {
//		printk(KERN_ERR
//		       "<%s> Error: in calling remap_pfn_range: returned %d\n",
//		       MODULE_NAME, result);

//		return -EAGAIN;
//	}
	return 0;
}


////////////////////////////////////////////////////////////////////////////////
//  PROBE  /////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

static struct file_operations fops = {
	.owner = THIS_MODULE,
	.open = xdma_open,
	.release = xdma_close,
//	.read = xdma_read,
//	.write = xdma_write,
//	.mmap = xdma_mmap,
//	.unlocked_ioctl = xdma_ioctl,
};

static int rfx_axidma_probe(struct platform_device *pdev)
{
	dma_cap_mask_t mask;
    /* device constructor */
	printk(KERN_DEBUG "<%s> init: registered\n", MODULE_NAME);
	if (alloc_chrdev_region(&dev_num, 0, 1, MODULE_NAME) < 0) {
		return -1;
    }
	if ((cl = class_create(THIS_MODULE, MODULE_NAME)) == NULL) {
		unregister_chrdev_region(dev_num, 1);
		return -1;
	}
	if (device_create(cl, NULL, dev_num, NULL, MODULE_NAME) == NULL) {
		class_destroy(cl);
		unregister_chrdev_region(dev_num, 1);
		return -1;
	}
	cdev_init(&c_dev, &fops);
	if (cdev_add(&c_dev, dev_num, 1) == -1) {
		device_destroy(cl, dev_num);
		class_destroy(cl);
		unregister_chrdev_region(dev_num, 1);
		return -1;
	}
    
    // Set capabilities to slave private channel
    dma_cap_zero(mask);
	dma_cap_set(DMA_SLAVE | DMA_PRIVATE, mask);
    
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
    
    
    return 0;
}

////////////////////////////////////////////////////////////////////////////////
//  REMOVE  ////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////




static int rfx_axidma_remove(struct platform_device *pdev)
{
    
    dma_release_channel(tx_chan);
    dma_release_channel(rx_chan);
    printk(KERN_DEBUG "dma channeld unregistered\n");
    
    
    /* device destructor */
	cdev_del(&c_dev);
	device_destroy(cl, dev_num);
	class_destroy(cl);
	unregister_chrdev_region(dev_num, 1);
	printk(KERN_DEBUG "<%s> exit: unregistered\n", MODULE_NAME);
        
    return 0;
}



////////////////////////////////////////////////////////////////////////////////
//  DRIVER  ////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


static const struct of_device_id rfx_axidma_of_ids[] = {
	{ .compatible = "xlnx,axi-dma-test-1.00.a",},
	{}
};

static struct platform_driver rfx_axidma_driver = {
	.driver = {
		.name = "rfx-axidma",
		.owner = THIS_MODULE,
		.of_match_table = rfx_axidma_of_ids,
	},
	.probe = rfx_axidma_probe,
	.remove = rfx_axidma_remove,
};



////////////////////////////////////////////////////////////////////////////////
//  INIT  //////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


static int __init rfx_axidma_init(void)
{
	printk(KERN_INFO "Inizialing RFX AXI DMA module\n");
    return platform_driver_register(&rfx_axidma_driver);
}

static void __exit rfx_axidma_exit(void)
{
	printk(KERN_INFO "Releasing RFX AXI DMA module\n");
    platform_driver_unregister(&rfx_axidma_driver);
}

module_init(rfx_axidma_init);
module_exit(rfx_axidma_exit);

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("RFX Wrapper Driver For Xilinx DMA Engine");
