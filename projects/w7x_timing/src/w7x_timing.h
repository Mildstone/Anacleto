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
//                            SGPWActE
#define STATUS_MASK    254 // 11111110
#define IDLE             6 // 00000110
#define ARMED           14 // 00001110
#define WAITING_DELAY   22 // 00010110
#define WAITING_SAMPLE 114 // 01110010
#define WAITING_LOW     82 // 01010010
#define WAITING_HIGH   210 // 11010010
#define WAITING_REPEAT  50 // 00110010

#define DEVICE_NAME "w7x_timing"  /* Dev name as it appears in /proc/devices */
#define MODULE_NAME "w7x_timing"
#define MAX_SAMPLES 32000
#define MAX_TIME    1099511627775 // (1<<40)-1
#define MAX_STATUS  8
#define W7X_TIMING_IOCTL_BASE	'W'
#define W7X_TIMING_RESOFFSET _IO(W7X_TIMING_IOCTL_BASE, 0)

typedef unsigned char        uint8_t;
typedef unsigned short       uint16_t;
typedef unsigned int         uint32_t;
typedef unsigned long long   uint64_t;

# pragma pack(1)
struct w7x_timing {//manual packing 64 bit
  uint8_t  r_status[MAX_STATUS];//0x00 ++0x01
  uint8_t  w_init;              //0x08
  uint8_t  w_trig;              //0x09
  uint8_t  w_clear;             //0x0A
  uint8_t  w_reinit;            //0x0B
  uint8_t  w_save;              //0x0C
  uint8_t  w_ext_clk;           //0x0D
  uint8_t  w_flag6;             //0x0E
  uint8_t  w_flag7;             //0x0F
  uint64_t w_delay;             //0x10
  uint32_t w_width;             //0x18
  uint32_t w_period;            //0x1C
  uint64_t w_cycle;             //0x20
  uint32_t w_repeat;            //0x28
  uint32_t w_count;             //0x2C
  uint64_t w_times[MAX_SAMPLES];//0x30 ++0x08
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
