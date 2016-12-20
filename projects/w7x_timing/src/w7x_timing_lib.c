#include <time.h>
#include "w7x_timing.h"

static struct timespec t = { 0, 100000 };

struct w7x_timing *dev = NULL;

//Return 1 if parameters OK, 0 otherwise
int prova(int arg, int arg1)
{
    printf("%d  %d\n", arg, arg1);
}


int makeClock(unsigned int delayH, unsigned int delayL, unsigned int wid, unsigned int period, unsigned int count, unsigned int cycleH, unsigned int cycleL, unsigned int repeat)
{
    int i;
 
   printf("MAKE CLOCK delayH: %d delayL: %dwidth: %d period: %d count: %d cycleH: %d cycleL: %d repeat: %d\n",
	delayH, delayL, wid, period, count, cycleH, cycleL, repeat); 
//Consistency check
    if(wid >= period)
    {
	printf("ERROR: width must be less than period\n");
	return 0;
    }
    if(count <= 0)
    {
	printf("ERROR: count must be greater than 0\n");
	return 0;
    }

    if(period * count > cycleL)
    {
	printf("ERROR: cycle must be greater than period * count\n");
	return 0;
    }

    if(!dev)
	dev = w7x_timing_get_device(0);
    if(!dev) {
        printf("ERROR: unable to get device\n");
	return 0;
    }
    
    dev->init = 0;
    nanosleep(&t,0);
    dev->delay_h = delayH;
    nanosleep(&t,0);
    dev->delay_l = delayL;
    nanosleep(&t,0);
    dev->wid = wid;
    nanosleep(&t,0);
    dev->period = period;
    nanosleep(&t,0);
    dev->cycle_h = cycleH;
    nanosleep(&t,0);
    dev->cycle_l = cycleL;
    nanosleep(&t,0);
    dev->repeat = repeat;
    nanosleep(&t,0);
    dev->count = count;

    for(i = 0; i < 32; i++) {
        nanosleep(&t,0);
	dev->seq[i] = 0;
    }
    return 1;
}

//Return 1 if parameters OK, 0 otherwise
int makeSequence(unsigned int delayH, unsigned int delayL, unsigned int wid, unsigned int period, unsigned int count, unsigned int cycleH, unsigned int cycleL, unsigned int repeat, unsigned int *times)
{
    int i;

    printf("MAKE SEQUENCE delayH: %d delayL: %d wid: %d period: %d count: %d cycleH: %d cycleL: %d repeat: %d \n",
	delayH, delayL, wid, period, count, cycleH, cycleL, repeat);
    for(i = 0; i < count; i++)
	printf("%d: timeL: %d  timeH: %d\n", i, times[2*i], times[2*i+1]);
//Consistency check
    if(wid >= period)
    {
	printf("ERROR: width must be less than period\n");
	return 0;
    }
    if(count <  0 || count > 16)
    {
	printf("ERROR: count must be between 0 and 16\n");
	return 0;
    }
    for(i = 1; i < count/2; i++)
    {
	if(times[2*i] <= times[2*i-1])
    	{
	    printf("ERROR: times must be increasing\n");
	    return 0;
        }
    }
    if(cycleL < times[count -2]+period)
    {
	printf("ERROR: Cycle must be greater or equal to last time plus period \n");
	return 0;
    }

    if(!dev)
	dev = w7x_timing_get_device(0);
    if(!dev) {
        printf("ERROR: unable to get device\n");
	return 0;
    }
    
    dev->init = 0;
    dev->delay_h = delayH;
    nanosleep(&t,0);
    dev->delay_l = delayL;
    nanosleep(&t,0);
    dev->wid = wid;
    nanosleep(&t,0);
    dev->period = period;
    nanosleep(&t,0);
    dev->cycle_h = cycleH;
    nanosleep(&t,0);
    dev->cycle_l = cycleL;
    nanosleep(&t,0);
    dev->repeat = repeat;
    nanosleep(&t,0);
    dev->count = count;
    for(i = 0; i < 32; i++) 
    {
       nanosleep(&t,0);
       dev->seq[i] = times[i];
    }
    return 1;
}

int arm()
{
    printf("ARM!!\n");
    if(!dev)
	dev = w7x_timing_get_device(0);
    if(!dev) {
        printf("ERROR: unable to get device\n");
	return 0;
    }
    
    dev->init = 1;
   
    return 1;
}
int disarm()
{
    printf("DISARM!!\n");
    if(!dev)
	dev = w7x_timing_get_device(0);
    if(!dev) {
        printf("ERROR: unable to get device\n");
	return 0;
    }
    
    dev->init = 0;
   
    return 1;
}

