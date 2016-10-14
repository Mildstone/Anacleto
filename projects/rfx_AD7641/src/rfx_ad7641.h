#ifndef RFX_AD7641_H
#define RFX_AD7641_H

#include <linux/types.h>
#include <asm/ioctl.h>




#ifdef __cplusplus
extern "C" {
#endif

#define DEVICE_NAME "rfx_ad7641"  /* Dev name as it appears in /proc/devices */
#define MODULE_NAME "rfx_ad7641"

#define RFX_AD7641_IOCTL_BASE	'W'
#define RFX_AD7641_RESOFFSET _IO(RFX_AD7641_IOCTL_BASE, 0)



struct rfx_ad7641 {
    int ena;   ///< enable value update
    int duty;  ///< new duty cycle value
    int _pad[2];
};


#ifndef __KERNEL__
// api functions here //

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>


struct rfx_ad7641 *rfx_ad7641_get_device(const char *dev_file) {
    static struct rfx_ad7641 *dev = NULL;
    int fd;
    if(!dev) {
        if(dev_file) fd = open(dev_file, O_RDWR | O_SYNC);
        else fd = open("/dev/"DEVICE_NAME, O_RDWR | O_SYNC);
        if(fd < 0) {
            printf(" ERROR: failed to open device file\n");
            return NULL;
        }
        dev = mmap(NULL, sizeof(struct rfx_ad7641), PROT_READ | PROT_WRITE, MAP_SHARED,fd,0);
    }

    if(!dev) {
        printf(" ERROR: failed to mmap device memory\n");
        return NULL;
    }
    return dev;
}

int rfx_ad7641_release_device() {
    struct rfx_ad7641 *dev = rfx_ad7641_get_device(0);
    int status;
    if(dev) {
        status = munmap(dev, sizeof(struct rfx_ad7641));
        if(status == 0) dev = NULL;
    }
    return status;
}


#endif // __KERNEL__




#ifdef __cplusplus
}
#endif
#endif // rfx_ad7641_H
