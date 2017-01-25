#ifndef W7X_TIMING_H
#define W7X_TIMING_H

#include <linux/types.h>
#include <asm/ioctl.h>

#ifdef __cplusplus
extern "C" {
#endif

#define C_OK           0
#define C_DEV_ERROR    1
#define C_PARAM_ERROR  2

#define DEVICE_NAME "w7x_timing"  /* Dev name as it appears in /proc/devices */
#define MODULE_NAME "w7x_timing"
#define MAX_SAMPLES 48
#define W7X_TIMING_IOCTL_BASE	'W'
#define W7X_TIMING_RESOFFSET _IO(W7X_TIMING_IOCTL_BASE, 0)

typedef unsigned long long   uint64_t;
typedef unsigned int         uint32_t;

# pragma pack(1)
struct w7x_timing {//packing 64 bit
    uint32_t init;   uint32_t trig;
    uint64_t delay;
    uint32_t width;  uint32_t period;
    uint64_t cycle;
    uint32_t repeat; uint32_t count;
    uint64_t times[MAX_SAMPLES];
};


#ifndef __KERNEL__
// api functions here //

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>


struct w7x_timing *w7x_timing_get_device(const char *dev_file) {
    static struct w7x_timing *dev = NULL;
    int fd;
    if(!dev) {
        if(dev_file) fd = open(dev_file, O_RDWR | O_SYNC);
        else fd = open("/dev/"DEVICE_NAME, O_RDWR | O_SYNC);
        if(fd < 0) {
            printf(" ERROR: failed to open device file\n");
            return NULL;
        }
        fprintf(stderr,"trying to allocate %u bytes of data\n",(unsigned int)sizeof(struct w7x_timing));
        dev = mmap(NULL, sizeof(struct w7x_timing), PROT_READ | PROT_WRITE, MAP_SHARED,fd,0);
    }
    if(!dev) {
        printf(" ERROR: failed to mmap device memory\n");
        return NULL;
    }
    return dev;
}

int w7x_timing_release_device() {
    struct w7x_timing *dev = w7x_timing_get_device(0);
    int c_status;
    if(dev) {// release
        c_status = munmap(dev, sizeof(struct w7x_timing));
        if(c_status == C_OK) dev = NULL;
    }
    return c_status;
}


#endif // __KERNEL__




#ifdef __cplusplus
}
#endif
#endif // W7X_TIMING_H
