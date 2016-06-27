#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>


#include <sys/ioctl.h>

#include <sys/mman.h>
#include <asm/unistd.h>

#include "axidma_example3.h"

#define BUFFER_SIZE 5000

int main(int argc, char *argv[])
{
    char * dev_file = argv[1];
    
    // open file //
    int fd = open(dev_file, O_RDWR);
    if(!fd) {
        printf("error opening device file\n");
        return 1;
    }
    
    int    number_devices;
    int status = ioctl(fd, XDMA_GET_NUM_DEVICES, &number_devices);
    if(status < 0) {
        printf("error ioctl on device -> err: %d \n",status);
        return 1;        
    }
    printf( "number of devices registered: %d \n", number_devices);
    
    int   test_trasfer;
    status = ioctl(fd, XDMA_TEST_TRASFER, &number_devices);
    if(status < 0) {
        printf("error ioctl on device -> err: %d \n",status);
        return 1;        
    }
    printf( "result of test trasfer: %d \n", test_trasfer);

    status = ioctl(fd, XDMA_TEST_RING, 0);
    if(status < 0) {
        printf("error ioctl on device -> err: %d \n",status);
        return 1;        
    }
    printf( "ring trasfer done: %d \n",status);
    
    
    return 0;
}

