//AXI lite Write (Redpitaya side)

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "axi_reg.h"


int main(int argc, char **argv) {
 printf("Axi write test \n");

 if(argc<3) {
  printf("usage: %s address [d1 d2 ... ]\n",argv[0]);
  return 1;
 }

 size_t map_addr = strtol(argv[1],NULL,16);
 size_t map_size = argc - 2;
 int i;
 printf("writing on address %d \n",map_addr);

 axi_reg_Init();
 int *addr = axi_reg_Map(map_size, map_addr);

 printf("write in:   |");
 for(i=0; i<argc-2; ++i) {
     printf("%6d | ",atoi(argv[i+2]));
     *(addr+i) = atoi(argv[i+2]);
 }
 printf("\n");
 printf("read back:  |");
 for(i=0; i<argc-2; ++i) {
     printf("%6d | ",*(addr+i));
 }
 printf("\n");

 axi_reg_Release();
 return 0;
}

