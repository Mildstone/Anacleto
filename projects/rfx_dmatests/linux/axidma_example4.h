#ifndef AXIDMA_EXAMPLE4_H
#define AXIDMA_EXAMPLE4_H

#ifdef __cplusplus
extern "C" {
#endif

#include <linux/types.h>
#include <asm/ioctl.h>

#define DEVICE_NAME "signal"  /* Dev name as it appears in /proc/devices */
#define MODULE_NAME "axidma_example4"
#define RING_SIZE 10
#define BUFFER_SIZE 4*1024*1024

#define XDMA_IOCTL_BASE	'W'
#define XDMA_GET_BUF_READY  _IO(XDMA_IOCTL_BASE, 0)
#define XDMA_START_FILLBUF  _IO(XDMA_IOCTL_BASE, 1)



#ifdef __cplusplus
}
#endif
#endif // AXIDMA_EXAMPLE4_H
