#include <time.h>
#include "w7x_timing.h"


struct w7x_timing *dev = NULL;

int getDev() {
    if (dev) return C_OK;
    dev = w7x_timing_get_device(0);
    if (dev) return C_OK;
    printf("ERROR: unable to get device\n");
    return C_DEV_ERROR;
}

int setParams(unsigned long int *delay, unsigned int *width, unsigned int *period, unsigned int *count, unsigned long int *cycle, unsigned int *repeat)
{//Consistency check
   if(*period<=1){
        printf("ERROR: period must be greater than 1\n");
        return C_PARAM_ERROR;
    }
    if (*width == 0)
        *width = *period/2;
    else if(*width >= *period) {
        printf("ERROR: width must be less than period\n");
        return C_PARAM_ERROR;
    }
    if(count <= 0) {
        printf("ERROR: count must be greater than 0\n");
        return C_PARAM_ERROR;
    }
    if (*cycle == 0)
        *cycle = *period * *count;
    else if(*cycle < *period * *count) {
        printf("ERROR: cycle must be greater than period * count\n");
        return C_PARAM_ERROR;
    }
    if (getDev()) return C_DEV_ERROR;
    dev->delay  = *delay;
    dev->width  = *width;
    dev->period = *period;
    dev->cycle  = *cycle;
    dev->repeat = *repeat;
    dev->count  = 0;
    return C_OK;
}

int makeClock(unsigned long int delay, unsigned int width, unsigned int period, unsigned int count, unsigned long int cycle, unsigned int repeat)
{
    printf("MAKE CLOCK delay: %ld, width: %d, period: %d, count: %d, cycle: %ld, repeat: %d\n",
	delay, width, period, count, cycle, repeat);
    int i,c_status = setParams(&delay, &width, &period, &count, &cycle, &repeat);
    if(c_status) return c_status;
    dev->seq[0] = 0;
    for(i = 1; i < count; i++)
	dev->seq[i] = dev->seq[i-1] + period;
    dev->count = count;
    return C_OK;
}

int makeSequence(unsigned long int delay, unsigned int width, unsigned int period, unsigned int count, unsigned long int cycle, unsigned int repeat, const unsigned long int *times)
{
    struct w7x_timing * dev = NULL;
    printf("MAKE SEQUENCE delay: %ld, width: %d, period: %d, count: %d, cycle: %ld repeat: %d \n",
	delay, width, period, count, cycle, repeat);
    int i,c_status = setParams(&delay, &width, &period, &count, &cycle, &repeat);
    if(c_status) return c_status;
    printf("%d: time: %ld\n", 0, times[0]);
    for(i = 1; i < count; i++){
       printf("%d: time: %ld\n", i, times[0]);
       if(times[i] < times[i-1]+period) {
         printf("ERROR: delta times must be greater or equal period\n");
         //w7x_timing_release_device();
         return C_PARAM_ERROR;
       }
    }
    for(i = 0; i < count; i++)
       dev->seq[i] = times[i];
    dev->count = count;
    return C_OK;
}

int trig() {
    if (getDev()) return C_DEV_ERROR;
    dev->trig = 1;
    return C_OK;
}

int arm() {
    if (getDev()) return C_DEV_ERROR;
    dev->init = 1;
    return C_OK;
}

int disarm() {
    if (getDev()) return C_DEV_ERROR;
    dev->init = 0;
    return C_OK;
}

