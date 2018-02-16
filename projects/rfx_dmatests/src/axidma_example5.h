#ifndef AXIDMA_EXAMPLE5_H
#define AXIDMA_EXAMPLE5_H

#include <linux/types.h>
#include <asm/ioctl.h>


#define BUFSIZE 4096

typedef void * Kprivate;


enum example5_dma_flags {
    example5_MEM_TO_DEV = 1 << 0,
    example5_DEV_TO_MEM = 1 << 1,
};


struct example5_dma_buffer_info {
    char *data;
    unsigned long offset;
    enum example5_dma_flags flags;

    // private data used in kernel space //
    void *kp_data;
};


struct example5_dma_ring_info {
    unsigned int buffer_size;
    unsigned int ring_size;
    enum example5_dma_flags flags;
};




#define MODULE_NAME "axidma_example5"
#define DEVICE_NAME "xdma"

#define XDMA_IOCTL_BASE	'W'
#define XDMA_REQUEST_RING  _IO(XDMA_IOCTL_BASE, 0)
#define XDMA_RELEASE_RING  _IO(XDMA_IOCTL_BASE, 1)
#define XDMA_RELEASE_RINGS  _IO(XDMA_IOCTL_BASE, 2)

#define XDMA_DEQUE_BUFFER  _IO(XDMA_IOCTL_BASE, 3)
#define XDMA_ENQUE_BUFFER  _IO(XDMA_IOCTL_BASE, 4)





#ifndef __KERNEL__
#include <poll.h>

// add functions here //

#endif

#endif // AXIDMA_EXAMPLE5_H
