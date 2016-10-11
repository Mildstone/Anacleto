
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>

#include <math.h>

#include "w7x_timing.h"

int main(int argc, char *argv[])
{
    struct w7x_timing *dev = w7x_timing_get_device(0);
    if(dev) {
        dev->seq[0] = atoi(argv[1]);
    }
    else
        printf("ERROR: unable to get device\n");


    w7x_timing_release_device();
    return 0;
}

