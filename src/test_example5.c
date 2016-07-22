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


#include "axidma_example5.h"

static struct example5_dma_ring ring1, ring2;


///
/// \brief ring_buffer_init
/// \param r
/// \param fd
/// \return
///
int ring_buffer_init(struct example5_dma_ring *r, int fd, int offset) {

    int i,j;
    int status = 0;
    long page_size = getpagesize(); //sysconf(_SC_PAGE_SIZE);

    assert(r);
    status = ioctl(fd, XDMA_REQUEST_RING, r);
    if(status < 0) {
        printf("error ioctl on device -> err: %d \n",status);
        return 1;
    }

    // ioct (REQUEST_BUFFERS) NON NECESSARIO
    r->data = (char **)malloc(r->ring_size * sizeof(char *));
    for (i=0; i<r->ring_size; ++i) {
        r->data[i] = mmap(NULL,r->ring_size,
                            PROT_READ | PROT_WRITE, MAP_SHARED,fd, offset +
                            i*(r->buffer_size/page_size + 1)*page_size);
        if(!r->data[i])
        {
            printf("ERROR: mmaping buffers");
            return 1;
        }
    }

    return status;
}


///
/// \brief ring_buffer_release
/// \param r
/// \return
///
int ring_buffer_release(struct example5_dma_ring *r) {
    int i;
    for (i=0; i<r->ring_size; ++i)
        munmap(r->data[i],r->ring_size);
    free(r->data);
}



int ring_write(int fd, struct example5_dma_ring *r, int timeout_sec) {

    int status = 0;
    int timeout_msecs = timeout_sec * 1000;
    struct pollfd pfds;
    pfds.fd = fd;
    pfds.events = POLLIN | POLLRDNORM;


    // 1) poll device for writing
    status = poll(&pfds,1,timeout_msecs);
    if(status == 0)
        printf( "Poll timed out\n" );
    else if(status < 0)
        printf( "Error on poll\n" );

    // 2) DQUE BUFFER
    //    status = ioctl(fd, -);

    // 3) copy buffer content

    // 4) ENQUE BUFFER

    return status;
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
    ring1.flags = TX_CHANNEL;
    ring1.data = NULL;

    ring2 = ring1;
    ring2.flags = RX_CHANNEL;

    // open file //
    int fd = open(dev_file, O_RDWR);
    if(!fd) {
        printf("error opening device file\n");
        return 1;
    }


    ring_buffer_init(&ring1,fd,0);

    // TEST //
    printf("testing: ");
    for(i=0;i<ring1.ring_size; ++i) {
        for(j=0;j<ring1.buffer_size/sizeof(int);++j) {
            int * data = (int*)ring1.data[i];
            if(data[j] != j) {
                status++;
                printf("%d-%d:%d \n",i,j,data[j]);
            }
        }
    }
    if (status) { printf("FAIL\n"); }
    else printf("OK\n");


    ring_buffer_release(&ring1);

    offset = (ring1.buffer_size/getpagesize()+1)*getpagesize() * ring1.ring_size;
    ring_buffer_init(&ring2,fd, offset);
    ring_buffer_release(&ring2);

    status = ioctl(fd, XDMA_RELEASE_RINGS, 0);
    if(status < 0) {
        printf("error ioctl on device -> err: %d \n",status);
        return 1;
    }


    return 0;
}

