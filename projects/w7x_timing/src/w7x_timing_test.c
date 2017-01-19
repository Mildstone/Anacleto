
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <time.h>
#include <math.h>

#include "w7x_timing.h"

int main(int argc, char *argv[])
{
    int i;

    if(argc < 7) {
	printf("Usage: %s Delay Wid Period Cycle Repeat [Seq1..Seq16]\n", argv[0]);
	exit(C_PARAM_ERROR);
    }
    struct w7x_timing *dev = w7x_timing_get_device(0);
    if(!dev) {
        printf("ERROR: unable to get device\n");
	exit(C_DEV_ERROR);
    }
    dev->init   = 0;
    dev->delay  = (uint64_t)atoi(argv[1]);
    dev->width  = atoi(argv[2]);
    dev->period = atoi(argv[3]);
    dev->cycle  = (uint64_t)atoi(argv[4]);
    dev->repeat = atoi(argv[5]);
    for(i = 6; i < argc; i++)
	dev->times[i-6] = (uint64_t)atoi(argv[i]);
    dev->count  = argc-6;
    dev->init = 1;
    dev->trig = 1;
    w7x_timing_release_device();
    exit(C_OK);
}



