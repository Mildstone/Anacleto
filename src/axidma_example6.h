#ifndef AXIDMA_EXAMPLE6_H
#define AXIDMA_EXAMPLE6_H




#include <linux/types.h>
#include <asm/ioctl.h>

#define SUCCESS 0
#define BUFSIZE 4096

typedef void * Kprivate;


enum xdma6_flags {
    xdma_MEM_TO_DEV = 1 << 0,
    xdma_DEV_TO_MEM = 1 << 1,
    xdma_SELFCHECK  = 1 << 2,
    xdma_OVERFLOW   = 1 << 3,

};


struct xdma6_buffer_info {
    size_t size;
    char *data;
    unsigned long offset;
    enum xdma6_flags flags;

    // private data used in kernel space //
    void *kp_data;
};


struct xdma6_ring_info {
    unsigned int buffer_size;
    unsigned int ring_size;
    enum xdma6_flags flags;
};



#define MODULE_NAME "xdma6"
#define DEVICE_NAME "xdma"

#define XDMA_IOCTL_BASE	'W'
#define XDMA_REQ_RING  _IO(XDMA_IOCTL_BASE, 0)
#define XDMA_REL_RING  _IO(XDMA_IOCTL_BASE, 1)
#define XDMA_REL_RINGS  _IO(XDMA_IOCTL_BASE, 2)

#define XDMA_REQ_BUFFER  _IO(XDMA_IOCTL_BASE, 3)
#define XDMA_ENQ_BUFFER  _IO(XDMA_IOCTL_BASE, 4)
#define XDMA_START_STREAM  _IO(XDMA_IOCTL_BASE, 5)
#define XDMA_STOP_STREAM  _IO(XDMA_IOCTL_BASE, 6)




#ifndef __KERNEL__
#include <poll.h>

// add functions here //

#endif




#endif // AXIDMA_EXAMPLE6_H
