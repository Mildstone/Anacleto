#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>

#include <sys/ioctl.h>

#include <sys/mman.h>
#include <asm/unistd.h>

#include "axidma_example4.h"

#include <poll.h>


static char * buffer = NULL;
static const int buffer_len = 500;


int test_using_select(int fd, int timeout_sec) {

    int status = 0;
    struct timeval tout;
    tout.tv_sec = timeout_sec;
    tout.tv_usec = 0;
    fd_set fds;
    
    FD_ZERO(&fds);
    FD_SET(fd, &fds);
    
    // starts thread that fills buffer //
    status = ioctl(fd, XDMA_START_FILLBUF, 0);
    if(status < 0) {
        printf("error ioctl on device -> err: %d \n",status);
        return status;
    }

    printf("now start selecting on file\n");
    status = select(fd+1,&fds,NULL,NULL,&tout);
    if(status == 0)
        printf( "Select timed out\n" );
    else if(status < 0) 
        printf( "Error on select\n" );
    else 
        printf(" GOT SELECT !! \n");
    
    return status;
}


int test_using_poll(int fd, int timeout_sec) {
    int status = 0;
    int timeout_msecs = timeout_sec * 1000;
    struct pollfd pfds;
    pfds.fd = fd;
    pfds.events = POLLIN | POLLRDNORM;
    
    
    // starts thread that fills buffer //
    status = ioctl(fd, XDMA_START_FILLBUF, 0);
    if(status < 0) {
        printf("error ioctl on device -> err: %d \n",status);
        return status;
    }

    printf("now start polling on file\n");
    status = poll(&pfds,1,timeout_msecs);
    if(status == 0)
        printf( "Poll timed out\n" );
    else if(status < 0) 
        printf( "Error on poll\n" );
    else 
        printf(" GOT POLL !! \n");
    
    return status;    
}

void reset_buffer(char *b, int len) {
    int i;
    int * b_int=(int *)b;
    for (i=0; i<len/sizeof(int); ++i)
        b_int[i] = 0;
}

int check_buffer(char *b, int len) {
    int i,e=0;
    int * b_int=(int *)b;
    printf("\n");
    for (i=0; i<len/sizeof(int); ++i) {
        printf("%d ",b_int[i]);
        if(b_int[i] != i) ++e;
    }
    printf("\n");
    if(e) printf("check buffer FAILED: %d !\n",e);
    return e;
}

int main(int argc, char *argv[])
{
    char * dev_file = argv[1];
    int status = 0;    
    
    // open file //
    int fd = open(dev_file, O_RDWR);
    if(!fd) {
        printf("error opening device file\n");
        return 1;
    }
    
    buffer = mmap(NULL, buffer_len, PROT_READ | PROT_WRITE, MAP_SHARED,fd,0);
    if(!buffer) {
        printf("error mmapping device buffer\n");
        return 1;
    }
       
    int ready = 0;    
    status = ioctl(fd, XDMA_GET_BUF_READY, &ready);
    if(status < 0) {
        printf("error ioctl on device -> err: %d \n",&status);
        return 1;        
    }    
    if(ready)    
    {       
        reset_buffer(buffer,buffer_len);
        test_using_select(fd,3);
        check_buffer(buffer,buffer_len);
                
        reset_buffer(buffer,buffer_len);
        test_using_poll(fd,3);        
        check_buffer(buffer,buffer_len);
    }
    
    close(fd);        
    return 0;
}

