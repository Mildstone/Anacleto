#include <time.h>
#include "w7x_timing.h"


struct w7x_timing *dev = NULL;

//Return 1 if parameters OK, 0 otherwise
int prova(int arg, int arg1){
    printf("%d  %d\n", arg, arg1);
}

int getDev() {
    if (!dev) {
        dev = w7x_timing_get_device(0);
        if (!dev) {
            printf("ERROR: unable to get device\n");
            return 0;
        }
    }
    return 1;
}

int setParams(const unsigned long int delay, unsigned int* width, const unsigned int period, const unsigned int count, unsigned long int* cycle, const unsigned int repeat)
{//Consistency check
   if(period<=1){
        printf("ERROR: period must be greater than 1\n");
        return 0;
    }
    if (*width == 0)
        *width = period/2;
    else if(*width >= period) {
        printf("ERROR: width must be less than period\n");
        return 0;
    }
    if(count <= 0) {
        printf("ERROR: count must be greater than 0\n");
        return 0;
    }
    if (*cycle == 0)
        *cycle = period * count;
    else if(*cycle < period * count) {
        printf("ERROR: cycle must be greater than period * count\n");
        return 0;
    }
    if (!getDev()) return 0;
    dev->delay  = delay;
    dev->width  = *width;
    dev->period = period;
    dev->cycle  = *cycle;
    dev->repeat = repeat;
    dev->count  = count;
    return 1;
}

int makeClock(const unsigned long int delay, unsigned int width, const unsigned int period, const unsigned int count, unsigned long int cycle, const unsigned int repeat)
{
    printf("MAKE CLOCK delay: %ld, width: %d, period: %d, count: %d, cycle: %ld, repeat: %d\n",
	delay, width, period, count, cycle, repeat);
    if(!setParams(delay, &width, period, count, &cycle, repeat))
        return 0;
    unsigned int sample = delay;
    int i;
    for(i = 0; i < count; i++) {
	dev->seq[i] = sample;
        sample += period;
    }
    w7x_timing_release_device();
    return 1;
}

//Return 1 if parameters OK, 0 otherwise
int makeSequence(const unsigned long int delay, unsigned int width, const unsigned int period, const unsigned int count, unsigned long int cycle, const unsigned int repeat, const unsigned long int *times)
{
    struct w7x_timing * dev = NULL;
    printf("MAKE SEQUENCE delay: %ld, width: %d, period: %d, count: %d, cycle: %ld repeat: %d \n",
	delay, width, period, count, cycle, repeat);
    if(!setParams(delay, &width, period, count, &cycle, repeat))
        return 0;
    int i;
    printf("%d: time: %ld\n", 0, times[0]);
    for(i = 1; i < count; i++){
       printf("%d: time: %ld\n", i, times[0]);
       if(times[i] < times[i-1]+period) {
         printf("ERROR: delta times must be greater or equal period\n");
         //w7x_timing_release_device();
         return 0;
       }
    }
    for(i = 0; i < count; i++) {
       dev->seq[i] = times[i];
    }
    //w7x_timing_release_device();
    return 1;
}

int trig() {
    if (!getDev()) return 0;
    dev->trig = 1;
    //w7x_timing_release_device();
    return 1;
}

int arm() {
    if (!getDev()) return 0;
    dev->init = 1;
    //w7x_timing_release_device();
    return 1;
}

int disarm() {
    if (!getDev()) return 0;
    dev->init = 0;
    //w7x_timing_release_device();
    return 1;
}

