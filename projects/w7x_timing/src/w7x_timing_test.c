
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
	printf("Usage: %s Delay Wid Period Cycle Repeat Count [Seq1..Seq16]\n", argv[0]);
	exit(C_PARAM_ERROR);
    }
    struct w7x_timing *dev = w7x_timing_get_device(0);
    if(!dev) {
        printf("ERROR: unable to get device\n");
	exit(C_DEV_ERROR);
    }
    dev->init   = 0;
    dev->delay  = (unsigned long)atoi(argv[1]);
    dev->width  = atoi(argv[2]);
    dev->period = atoi(argv[3]);
    dev->cycle  = (unsigned long)atoi(argv[4]);
    dev->repeat = atoi(argv[5]);
    dev->count = atoi(argv[6]);
    for(i = 7; i < argc; i++)
	dev->seq[i-7] = (unsigned long)atoi(argv[i]);
    dev->init = 1;
    dev->trig = 1;
    w7x_timing_release_device();
    exit(C_OK);
}



