#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <assert.h>

#include <sys/ioctl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <poll.h>


#include "axidma_example6.h"

static struct xdma6_ring_info ring1, ring2;


int ring_buffer_init(struct xdma6_ring_info *r, int fd, int offset) {

    int i,j;
    int err = 0;
    struct xdma6_buffer_info buf;
    long page_size = getpagesize(); //sysconf(_SC_PAGE_SIZE);

    assert(r);
    err = ioctl(fd, XDMA_REQ_RING, r);
    if(err) {
        printf("Error ioctl on device -> err: %d \n",err);
        return 1;
    }

    for(i=0; i<3; ++i) {
        buf.flags = xdma_MEM_TO_DEV;
        err = ioctl(fd, XDMA_REQ_BUFFER, &buf);
        if(err) { printf("req_buffer\n"); return 1; }

        printf("buf->size = %d\n",buf.size);
        buf.data = mmap(NULL,buf.size,PROT_READ | PROT_WRITE, MAP_SHARED,fd,0);

        err = ioctl(fd, XDMA_ENQ_BUFFER, &buf);
        printf("buf->offset = %d\n",buf.offset);
        if(err) { printf("enq_buffer\n"); return 1; }
    }


    err = ioctl(fd, XDMA_REL_RING, r);
    if(err) {
        printf("Error ioctl on device -> err: %d \n",err);
        return 1;
    }


    return err;
}


int ring_buffer_release(struct xdma6_ring_info *r) {
    return 0;
}






////////////////////////////////////////////////////////////////////////////////
//  main  //////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


int main(int argc, char *argv[])
{
    char * dev_file = argv[1];
    int status = 0;
    int i,j;
    int offset;

    ring1.buffer_size = BUFSIZE;
    ring1.ring_size = 10;
    ring1.flags = 0
            | xdma_MEM_TO_DEV
            | xdma_SELFCHECK
            ;


    ring2 = ring1;
    ring2.flags = 0
            | xdma_DEV_TO_MEM
            | xdma_SELFCHECK
            ;

    // open file //
    int fd = open(dev_file, O_RDWR);
    if(!fd) {
        printf("error opening device file\n");
        return 1;
    }


    ring_buffer_init(&ring1,fd,0);
    ring_buffer_release(&ring1);



    return 0;
}

