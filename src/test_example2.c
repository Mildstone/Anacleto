#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include <sys/mman.h>
#include <asm/unistd.h>

#define BUFFER_SIZE 5000

int main(int argc, char *argv[])
{
    char *buffer;
    char * dev_file = argv[1];
    
    // open file //
    int fd = open(dev_file, O_RDWR);
    if(!fd) {
        printf("error opening device file\n");
        return 1;
    }
    
    
    // mmap //
    buffer = mmap(NULL, BUFFER_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if(!buffer) {
        printf("error mmapping device buffer\n");
        return 1;
    }
    
    
    printf("buffer content -> %s", buffer);    
    return 0;
}

