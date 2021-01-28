
#include <linux/module.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/platform_device.h>


static int __init mymod_init(void)
{
    printk(KERN_INFO "inizializing AXI module ...\n");
    return 0;
}

static void __exit mymod_exit(void)
{
    printk(KERN_INFO "exiting AXI module ...\n");
}

module_init(mymod_init);
module_exit(mymod_exit);
MODULE_LICENSE("GPL");
