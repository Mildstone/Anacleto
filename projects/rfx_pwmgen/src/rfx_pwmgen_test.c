#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <stdio.h>
#include <math.h>

#define RP_OK 0;
#define RP_EMMD 1;
#define RP_EUMD 1;
#define RP_ECMD 1;
#define RP_EOMD 1;

static int fd = NULL;

int cmn_Init(const char *fname)
{
    if (!fd) {
        if((fd = open(fname, O_RDWR | O_SYNC)) == -1) { return RP_EOMD; }
    }
    return RP_OK;
}

int cmn_Release()
{
    if (fd) {
        if(close(fd) < 0) {
            return RP_ECMD;
        }
    }
    return RP_OK;
}

int cmn_Map(size_t size, size_t offset, void** mapped)
{
    if(fd == -1) {
        return RP_EMMD;
    }

    *mapped = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, offset);

    if(mapped == (void *) -1) {
        return RP_EMMD;
    }

    return RP_OK;
}



int main(int argc, char **argv) {
 printf("pwmgen test \n");

 if(argc<2) {
  printf("usage: %s ena duty\n",argv[0]);
  return 1;
 }

 int *addr;
 cmn_Init(argv[1]);   // rfx

// cmn_Map(16, 0x43c00000,(void**)&addr);
 cmn_Map(16, strtol(argv[2], NULL, 16),(void**)&addr);

 *(addr+0) = atoi(argv[3]);
 *(addr+1) = atoi(argv[4]);

 printf(" %d %d \n",*(addr+0),*(addr+1));

 cmn_Release();

 return 0;
}
