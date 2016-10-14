#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>

#include <math.h>

#include "rfx_pwmgen.h"

int main(int argc, char *argv[])
{
    struct rfx_pwmgen *dev = pwmgen_get_device(0);
    if(dev) {
        dev->duty = atoi(argv[2]);
        dev->ena = atoi(argv[1]);
    }
    else
        printf("ERROR: unable to get device\n");


    pwmgen_release_device();
    return 0;
}

