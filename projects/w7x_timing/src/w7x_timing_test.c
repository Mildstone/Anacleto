
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
    dev->w_init   = 0;
    dev->w_delay  = (uint64_t)atoi(argv[1]);
    dev->w_width  = atoi(argv[2]);
    dev->w_period = atoi(argv[3]);
    dev->w_cycle  = (uint64_t)atoi(argv[4]);
    dev->w_repeat = atoi(argv[5]);
    for(i = 6; i < argc; i++)
	dev->w_times[i-6] = (uint64_t)atoi(argv[i]);
    dev->w_count  = argc-6;
    dev->w_init   = 1;
    dev->w_trig   = 1;
    w7x_timing_release_device();
    exit(C_OK);
}



