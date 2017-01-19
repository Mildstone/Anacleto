#ifndef W7X_TIMING_H
#define W7X_TIMING_H

#include <linux/types.h>
#include <asm/ioctl.h>




#ifdef __cplusplus
extern "C" {
#endif

#define DEVICE_NAME "w7x_timing"  /* Dev name as it appears in /proc/devices */
#define MODULE_NAME "w7x_timing"
#define MAX_SAMPLES  59//4096/64-5
#define W7X_TIMING_IOCTL_BASE	'W'
#define W7X_TIMING_RESOFFSET _IO(W7X_TIMING_IOCTL_BASE, 0)

# pragma pack(1)
struct w7x_timing {
	unsigned      int init;
        unsigned      int trig;
	unsigned long int delay;
	unsigned      int width;
	unsigned      int period;
	unsigned long int cycle;
	unsigned      int repeat;
	unsigned      int count;
	unsigned long int seq[MAX_SAMPLES];
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
    int status;
    if(dev) {
        status = munmap(dev, sizeof(struct w7x_timing));
        if(status == 0) dev = NULL;
    }
    return status;
}


#endif // __KERNEL__




#ifdef __cplusplus
}
#endif
#endif // W7X_TIMING_H
