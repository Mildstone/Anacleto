
/*
 * Double linked list implemented in the kernel sources example:
 * 
 * 
 * 
 */


#include <linux/module.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/platform_device.h>

#include <linux/vmalloc.h>

#include <linux/list.h>


struct MyObjectType {
    struct list_head node;
    u8 a,b,c,d;
    char *str;
};

static LIST_HEAD(prova);

static int use_prova_list(void) {
    int i,e;
    struct list_head *it;    
    
    // init list //
    INIT_LIST_HEAD(&prova);
    
    // fill up  list adding to head //
    for(i=0;i<10;++i) {
        struct MyObjectType *ob = 
                (struct MyObjectType *)vmalloc(sizeof (struct MyObjectType));
        ob->a = i;
        list_add((struct list_head *)ob,&prova);
    }
    
    // check using foreach construct //
    i=10; e=0;
    list_for_each(it,&prova) {
        struct MyObjectType *el = list_entry(it, struct MyObjectType, node);
        if(el->a != --i) ++e;        
    }
    if(e) list_for_each(it,&prova) {
        struct MyObjectType *el = list_entry(it, struct MyObjectType, node);
        printk("%d ",el->a);
    }        
    printk("\n");    
    return e;
}







////////////////////////////////////////////////////////////////////////////////
//  DRIVER  ////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


static int base_example_list_probe(struct platform_device *pdev)
{
    printk("PLATFORM DEVICE PROBE...\n");
    if(use_prova_list() == 0) 
        printk("OK it works\n");
    return 0;
}

static int base_example_list_remove(struct platform_device *pdev)
{
    printk("PLATFORM DEVICE REMOVE...\n");
    return 0;
}

static const struct of_device_id base_example_list_of_ids[] = {
{ .compatible = "xlnx,axi-dma-test-1.00.a",}, {} };

static struct platform_driver base_example_list_driver = {
    .driver = {
        .name = "base_example_list",
        .owner = THIS_MODULE,
        .of_match_table = base_example_list_of_ids,
    },
    .probe = base_example_list_probe,
    .remove = base_example_list_remove,
};

static int __init base_example_list_init(void)
{
    printk(KERN_INFO "base_example_list module initialized\n");
    return platform_driver_register(&base_example_list_driver);
}

static void __exit base_example_list_exit(void)
{
    printk(KERN_INFO "base_example_list module exited\n");
    platform_driver_unregister(&base_example_list_driver);
}

module_init(base_example_list_init);
module_exit(base_example_list_exit);
MODULE_LICENSE("GPL");


