#ifndef AXIDMA_EXAMPLE5_H
#define AXIDMA_EXAMPLE5_H

#include <linux/types.h>
#include <asm/ioctl.h>


#define BUFSIZE 4096


enum example5_dma_flags {
    TX_CHANNEL = 1 << 1,
    RX_CHANNEL = 1 << 2
};


struct example5_dma_buffer {
    char *data;
    unsigned long offset;
};

struct example5_dma_ring {
    int buffer_size;
    int ring_size;
    enum example5_dma_flags flags;
    char **data;

    void *kp_data;
};




#define MODULE_NAME "axidma_example5"
#define DEVICE_NAME "xdma"

#define XDMA_IOCTL_BASE	'W'
#define XDMA_REQUEST_RING  _IO(XDMA_IOCTL_BASE, 0)
#define XDMA_RELEASE_RING  _IO(XDMA_IOCTL_BASE, 1)
#define XDMA_RELEASE_RINGS  _IO(XDMA_IOCTL_BASE, 2)
#define XDMA_REQUEST_BUFFER  _IO(XDMA_IOCTL_BASE, 3)

#define XDMA_REQUEST_TO_SEND  _IO(XDMA_IOCTL_BASE, 4)



#ifndef __KERNEL__
#include <poll.h>

// add functions here //

#endif

#endif // AXIDMA_EXAMPLE5_H
