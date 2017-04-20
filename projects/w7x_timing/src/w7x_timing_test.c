
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <time.h>
#include <math.h>

#include "w7x_timing_lib.c"

int main(int argc, char *argv[])
{
    int i, c_status;
    uint64_t delay, cycle, burst, *times;
    uint32_t width, period, repeat;
    if(argc < 7) {
	printf("Usage: %s Delay Width Burst Period Cycle Repeat [Seq1..Seq16]\n", argv[0]);
	exit(C_PARAM_ERROR);
    }
    disarm();
    delay  = (uint64_t)atoi(argv[1]);
    width  = atoi(argv[2]);
    period = atoi(argv[3]);
    burst  = (uint64_t)atoi(argv[4]);
    cycle  = (uint64_t)atoi(argv[5]);
    repeat = atoi(argv[6]);
    if(argc == 7)
        c_status = makeClock(&delay,&width,&burst,&period,&cycle,&repeat);
    else {
        uint32_t count = argc-7;
        times = malloc(count*sizeof(uint64_t));
        for(i = 0; i < count; i++)
            times[i] = (uint64_t)atoi(argv[i+7]);
        c_status = makeSequence(&delay,&width,&burst,&period,&cycle,&repeat,&count,times);
        free(times);
    }
    arm();
    w7x_timing_release_device();
    exit(c_status);
}
