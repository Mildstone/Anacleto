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




int ring_buffer_init(struct xdma6_ring_info *r, int fd) {

    int i,j;
    int err = 0;
    struct xdma6_buffer_info buf;
    long page_size = getpagesize(); //sysconf(_SC_PAGE_SIZE);


    assert(r);
    err = ioctl(fd, XDMA_REQ_RING, r);
    if(err) {
        printf("Error ioctl on device -> err: %d \n",err);
        return err;
    }

    for(i=0; i<r->ring_size; ++i) {

        buf.flags = r->flags | xdma_OVERFLOW;
        err = ioctl(fd, XDMA_REQ_BUFFER, &buf);
        if(err) { printf("ERROR: req_buffer\n"); return 1; }

        buf.data = mmap(NULL,buf.size,PROT_READ | PROT_WRITE, MAP_SHARED,fd,0);

        buf.flags = r->flags | xdma_OVERFLOW;
        err = ioctl(fd, XDMA_ENQ_BUFFER, &buf);
        if(err) { printf("ERROR: enq_buffer\n"); return 1; }
    }


    for(i=0; i<r->ring_size; ++i) {
        buf.flags = r->flags | xdma_OVERFLOW;
        err = ioctl(fd, XDMA_REQ_BUFFER, &buf);
        if(err) { printf("ERROR: req_buffer\n"); return 1; }

        if(buf.flags & xdma_DEV_TO_MEM)
            printf("working with RX ring -> %d -- %d\n", buf.kp_data, buf.offset);
        else if (buf.flags & xdma_MEM_TO_DEV)
            printf("working with TX ring -> %d -- %d\n", buf.kp_data, buf.offset);
        else
            printf("got a problem guy !\n");

        buf.flags = r->flags | xdma_OVERFLOW;
        err = ioctl(fd, XDMA_ENQ_BUFFER, &buf);
        if(err) { printf("ERROR: enq_buffer\n"); return 1; }
    }



    return err;
}


int ring_buffer_release(struct xdma6_ring_info *r, int fd) {
    int err = 0;

    assert(r);
    err = ioctl(fd, XDMA_REL_RING, r);
    if(err) {
        printf("Error ioctl on device -> err: %d \n",err);
        return err;
    }
    return err;
    return 0;
}


int ring_start_stream(int fd) {
    int err = 0;

    err = ioctl(fd, XDMA_START_STREAM, 0);
    if(err) {
        printf("Error ioctl on device -> err: %d \n",err);
        return err;
    }
    return err;
    return 0;
}

int ring_stop_stream(int fd) {
    int err = 0;

    err = ioctl(fd, XDMA_STOP_STREAM, 0);
    if(err) {
        printf("Error ioctl on device -> err: %d \n",err);
        return err;
    }
    return err;
    return 0;
}



int poll_read(int fd, int timeout_sec) {
    int status = 0;
    int timeout_msecs = timeout_sec * 1000;
    struct pollfd pfds;
    pfds.fd = fd;
    pfds.events = POLLIN | POLLRDNORM;

    status = poll(&pfds,1,timeout_msecs);
    if(status == 0)
        printf( "Poll timed out\n" );
    else if(status < 0)
        printf( "Error on poll\n" );
//    else
//        printf( "GOT POLL READ\n" );

    return status;
}

int poll_write(int fd, int timeout_sec) {
    int status = 0;
    int timeout_msecs = timeout_sec * 1000;
    struct pollfd pfds;
    pfds.fd = fd;
    pfds.events = POLLOUT | POLLWRNORM;

    status = poll(&pfds,1,timeout_msecs);
    if(status == 0)
        printf( "Poll timed out\n" );
    else if(status < 0)
        printf( "Error on poll\n" );
//    else
//        printf( "GOT POLL WRITE\n" );
    return status;
}


static int counter = 0;
int try_send_something(int fd, int *data, int len) {
    int err = 0;
    struct xdma6_buffer_info buf;


    poll_write(fd,10);
    buf.flags = xdma_MEM_TO_DEV;
    err = ioctl(fd, XDMA_REQ_BUFFER, &buf);
    if(err) { printf("ERROR: deq_buffer\n"); return 1; }

    data[0] = counter++;
    memcpy(buf.data,(char*)data,len*sizeof(int));

    buf.flags = xdma_MEM_TO_DEV;
    err = ioctl(fd, XDMA_ENQ_BUFFER, &buf);
    if(err) { printf("ERROR: enq_buffer\n"); return 1; }
    return err;
}

int try_receive_something(int fd, int *data, int len) {
    int err = 0;
    struct xdma6_buffer_info buf;

    poll_read(fd,10);
    buf.flags = xdma_DEV_TO_MEM;
    err = ioctl(fd, XDMA_REQ_BUFFER, &buf);
    if(err) { printf("ERROR: deq_buffer\n"); return 1; }

    memcpy((char*)data,buf.data,len*sizeof(int));
    printf("-> GOT BUF no.%d: %d %d %d %d %d ...\n", buf.kp_data,
           data[0], data[1], data[2], data[3], data[4]);

    buf.flags = xdma_DEV_TO_MEM;
    err = ioctl(fd, XDMA_ENQ_BUFFER, &buf);
    if(err) { printf("ERROR: enq_buffer\n"); return 1; }

    return err;
}



////////////////////////////////////////////////////////////////////////////////
//  main  //////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

int main(int argc, char *argv[])
{
    struct xdma6_ring_info ring1, ring2;
    char * dev_file = argv[1];
    int status = 0;
    int i,j;
    int offset;

    int data[] = { 0,5,5,5,2,3,6,8 };
    int data_len = 8;

    ring1.buffer_size = 100 * BUFSIZE;
    ring1.ring_size = 10;
    ring1.flags = 0
            | xdma_MEM_TO_DEV
            | xdma_SELFCHECK
            ;

    ring2 = ring1;
    ring2.buffer_size = 100 * BUFSIZE;
    ring2.ring_size = 10;
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

    ring_buffer_init(&ring1,fd);
    ring_buffer_init(&ring2,fd);

    ring_start_stream(fd);

    for(i=0;i<5000;++i){
        try_send_something(fd,data,data_len);
        try_receive_something(fd,data,data_len);
    }

    sleep(2);
//    ring_stop_stream(fd);

    ring_buffer_release(&ring2,fd);
    ring_buffer_release(&ring1,fd);


    return 0;
}

