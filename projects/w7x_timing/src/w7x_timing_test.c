
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <time.h>
#include <math.h>

#include "w7x_timing.h"

static struct timespec t = { 0, 100 };

int main(int argc, char *argv[])
{
    int i;

    if(argc < 7)
    {
	printf("Usage: %s Delay Wid Period Cycle Repeat Count [Seq1..Seq16]\n", argv[0]);
	exit(0);
    }
    struct w7x_timing *dev = w7x_timing_get_device(0);
    if(!dev) {
        printf("ERROR: unable to get device\n");
	exit(0);
    }
    

    dev->init = 0;
    dev->delay_h = 0;
    dev->delay_l = atoi(argv[1]);
    dev->wid = atoi(argv[2]);
    dev->period = atoi(argv[3]);
    dev->cycle_h = 0;
    dev->cycle_l = atoi(argv[4]);
    dev->repeat = atoi(argv[5]);
    dev->count = atoi(argv[6]);
    for(i = 0; i < 32; i++) {
        nanosleep(&t,0);
        dev->seq[i] = 0;
    }
    for(i = 7; i < argc; i++) //Clock no sequence
    {
        nanosleep(&t,0);
	dev->seq[2*(i-7)] = atoi(argv[i]);
    }
    nanosleep(&t,0);
    dev->init = 1;

    w7x_timing_release_device();
    return 0;
}



