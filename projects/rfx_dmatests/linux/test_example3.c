#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>


#include <sys/ioctl.h>

#include <sys/mman.h>
#include <asm/unistd.h>

#include "axidma_example3.h"



static int test_transfer_mmap(int fd, unsigned long size) {
    char *buffer;
    int status;
    
    // MMAP buffer //
    buffer = mmap(NULL,size,PROT_READ | PROT_WRITE, MAP_SHARED,fd,0);
    if(!buffer) {
        printf("error mmapping device buffer\n");
        return 1;
    }

    int i;
    int * src = (int *)buffer;
    int * dst = (int *)(buffer+size/2);
    
    // init source data //
    for (i=0; i<size/2/sizeof(int); ++i) src[i] = i;
    
    status = ioctl(fd, XDMA_TEST_MMAPTRASFER, 0);
    if(status < 0) {
        printf("error ioctl on device -> err: %d \n",status);
        return 1;        
    }
    
    // compare result //
    int err = 0;
    for(i=0; i<size/2/sizeof(int); ++i)
        if(src[i] != dst[i]) ++err;

    // MUNMAP buffer //
    munmap(buffer,size);
    
    return err;
}

int main(int argc, char *argv[])
{
    char *buffer;
    char * dev_file = argv[1];
    int status = 0;
    // open file //
    int fd = open(dev_file, O_RDWR);
    if(!fd) {
        printf("error opening device file\n");
        return 1;
    }

    // MMAP buffer //
    buffer = mmap(NULL,BUFFER_SIZE,PROT_READ | PROT_WRITE, MAP_SHARED,fd,0);
    if(!buffer) {
        printf("error mmapping device buffer\n");
        return 1;
    }

    for (int i=0; i < 100; ++i) {
        int size = BUFFER_SIZE;
//        int * src = (int *)buffer;
//        int * dst = (int *)(buffer+size/2);
//        for (int j=0; j<size/2/sizeof(int); ++j) src[j] = i+j;

        status = ioctl(fd, XDMA_TEST_MMAPTRASFER, 0);
        if(status < 0) {
            printf("error ioctl on device -> err: %d \n",status);
            return 1;
        }


//        int err = 0;
//        for(int j=0; j<size/2/sizeof(int); ++j)
//            if(src[j] != dst[j]) ++err;
//        if(err)
//            printf("ERROR: pattern does not match\n");
        else
            printf(":");

    }
    printf("\n");

    // MUNMAP buffer //
    munmap(buffer,BUFFER_SIZE);

    return 0;
}



int _main(int argc, char *argv[])
{
    char * dev_file = argv[1];
    int status = 0;
    // open file //
    int fd = open(dev_file, O_RDWR);
    if(!fd) {
        printf("error opening device file\n");
        return 1;
    }
    
    int    number_devices;
    status = ioctl(fd, XDMA_GET_NUM_DEVICES, &number_devices);
    if(status < 0) {
        printf("error ioctl on device -> err: %d \n",status);
        return 1;
    }
    printf( "number of devices registered: %d \n", number_devices);

    status = ioctl(fd, XDMA_TEST_TRASFER, 0);
    if(status < 0) {
        printf("error ioctl on device -> err: %d \n",status);
        return 1;
    }
    printf( "result of test trasfer: %d \n", status);

    int i;
    printf("\n");
    for (i=0; i<50; ++i) {
        test_transfer_mmap(fd,BUFFER_SIZE);
        printf(".");
        fflush(stdout);
    }
    
        
    return 0;
}

