//AXI lite Write (Redpitaya side)

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "axi_reg.h"


int main(int argc, char **argv) {
 printf("Axi write test \n");

 if(argc<3) {
  printf("usage: %s address size\n",argv[0]);
  return 1;
 }

 size_t map_addr = strtol(argv[1],NULL,16);
 size_t map_size = atoi(argv[2]);
 int i;
 printf("reading on address %d \n",map_addr);

 axi_reg_Init();
 int *addr = axi_reg_Map(map_size, map_addr);

 printf("read:  |");
 for(i=0; i<map_size; ++i) {
     printf("%6d | ",*(addr+i));
 }
 printf("\n");

 axi_reg_Release();
 return 0;
}

