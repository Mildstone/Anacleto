#ifndef AXIDMA_EXAMPLE3_H
#define AXIDMA_EXAMPLE3_H

#ifdef __cplusplus
extern "C" {
#endif

#include <linux/types.h>
#include <asm/ioctl.h>



#define DEVICE_NAME "signal"  /* Dev name as it appears in /proc/devices */
#define MODULE_NAME "axidma_example3"
#define RING_SIZE 10
#define BUFFER_SIZE 16*1024*1024

#define XDMA_IOCTL_BASE	'W'
#define XDMA_GET_NUM_DEVICES  _IO(XDMA_IOCTL_BASE, 0)
#define XDMA_GET_DEV_INFO	  _IO(XDMA_IOCTL_BASE, 1)
#define XDMA_TEST_TRASFER	  _IO(XDMA_IOCTL_BASE, 2)
#define XDMA_TEST_MMAPTRASFER _IO(XDMA_IOCTL_BASE, 3)





#ifdef __cplusplus
}
#endif
#endif // AXIDMA_EXAMPLE3_H
