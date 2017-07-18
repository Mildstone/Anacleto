//AXI lite Write (Redpitaya side)

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>

#define RP_OK 0;
#define RP_EMMD 1;
#define RP_EUMD 1;
#define RP_ECMD 1;
#define RP_EOMD 1;

static int fd = 0;


enum AxiSFifo_Register {
    ISR   = 0x00,   ///< Interrupt Status Register (ISR)
    IER   = 0x04,   ///< Interrupt Enable Register (IER)
    TDFR  = 0x08,   ///< Transmit Data FIFO Reset (TDFR)
    TDFV  = 0x0c,   ///< Transmit Data FIFO Vacancy (TDFV)
    TDFD  = 0x10,   ///< Transmit Data FIFO 32-bit Wide Data Write Port
    TDFD4 = 0x1000, ///< Transmit Data FIFO for AXI4 Data Write Port
    TLR   = 0x14,   ///< Transmit Length Register (TLR)
    RDFR  = 0x18,   ///< Receive Data FIFO reset (RDFR)
    RDFO  = 0x1c,   ///< Receive Data FIFO Occupancy (RDFO)
    RDFD  = 0x20,   ///< Receive Data FIFO 32-bit Wide Data Read Port (RDFD)
    RDFD4 = 0x1000, ///< Receive Data FIFO for AXI4 Data Read Port (RDFD)
    RLR   = 0x24,   ///< Receive Length Register (RLR)
    SRR   = 0x28,   ///< AXI4-Stream Reset (SRR)
    TDR   = 0x2c,   ///< Transmit Destination Register (TDR)
    RDR   = 0x30,   ///< Receive Destination Register (RDR)
    /// not supported yet .. ///
    TID   = 0x34,   ///< Transmit ID Register
    TUSER = 0x38,   ///< Transmit USER Register
    RID   = 0x3c,   ///< Receive ID Register
    RUSER = 0x40    ///< Receive USER Register
};

enum ISREnum {
    ISR_RFPE = 1 << 19,  ///< Receive FIFO Programmable Empty
    ISR_RFPF = 1 << 20,  ///< Receive FIFO Programmable Full
    ISR_TFPE = 1 << 21,  ///< Transmit FIFO Programmable Empty
    ISR_TFPF = 1 << 22,  ///< Transmit FIFO Programmable Full
    ISR_RRC = 1 << 23,   ///< Receive Reset Complete
    ISR_TRC = 1 << 24,   ///< Transmit Reset Complete
    ISR_TSE = 1 << 25,   ///< Transmit Size Error
    ISR_RC = 1 << 26,    ///< Receive Complete
    ISR_TC = 1 << 27,    ///< Transmit Complete
    ISR_TPOE = 1 << 28,  ///< Transmit Packet Overrun Error
    ISR_RPUE = 1 << 29,  ///< Receive Packet Underrun Error
    ISR_RPORE = 1 << 30, ///< Receive Packet Overrun Read Error
    ISR_RPURE = 1 << 31, ///< Receive Packet Underrun Read Error
};


int Init()
{
    if (!fd)
        if((fd = open("/dev/mem", O_RDWR | O_SYNC)) == -1) { return RP_EOMD; }
    return RP_OK;
}

int Release()
{
    if (fd && close(fd) < 0)
        return RP_ECMD;
    return RP_OK;
}

void * Map(size_t size, size_t offset)
{
    if(fd == -1) { return NULL; }
    return mmap(NULL, size,
                PROT_READ | PROT_WRITE | PROT_EXEC,
                MAP_SHARED,
                fd, offset);
}

void UnMap(void *addr, size_t size) {
    munmap(addr,size);
}

void Write(void *addr, enum AxiSFifo_Register op, u_int32_t data ) {
    // printf("address -> %p : data -> %x\n",(void *)(addr+op),data);
    *(u_int32_t *)(addr+op) = data;
}

u_int32_t Read(void *addr, enum AxiSFifo_Register op ) {
    return *(u_int32_t *)(addr+op);
}

int Fifo_Init(void *dev) {
    u_int32_t isr,ier;
    isr = Read(dev,ISR);
    Write(dev,ISR,0xFFFFFFFF);  // clear ISR
    if( isr = Read(dev,ISR) ) {
        printf("some error initializating interface .. \n");
        return 1;
    }
    printf("ISR: %d\n",isr);
    ier = Read(dev,IER);
    printf("IER: %d\n",ier);
    printf("TDVF: %d\n",Read(dev,TDFV));
    printf("RDFO: %d\n",Read(dev,RDFO));
}

int Fifo_Receive(void *dev, u_int32_t *buf) {
    u_int32_t status = Read(dev,ISR);
    if (status & ISR_RC == 0) {
        printf("no data present");
        return 0;
    } else {
        Write(dev,ISR,0xFFFFFFFF); // clear complete interrupt bit
        status = Read(dev,ISR);
        if (status) printf("some errors");
        u_int16_t occ = Read(dev,RDFO) & 0xFFFF;
        u_int16_t rlr = Read(dev,RLR) & 0x3FFFFF;
        u_int16_t rdr = Read(dev,RDR) & 0xF;
        printf("occ: %d\n",occ);
        int i;
        for(i=0; i<occ; ++i) {
            buf[i] = Read(dev,RDFD);
        }
        return occ;
    }
    return 0;
}




int main(int argc, char **argv) {
 printf("Axi fifo test \n");

 if(argc<2) {
  printf("usage: %s address [axi4addr]\n",argv[0]);
  return 1;
 }

 Init();


 size_t map_addr = strtol(argv[1],NULL,16);
 size_t map_size = 0x4f;
 void *dev  = Map(map_size, map_addr);
 void *dev4 = NULL;

 if(argc == 3) {
     size_t map_addr4 = strtol(argv[2],NULL,16);
     size_t map_size4 = 0xffff;
     dev4 = Map(map_size4, map_addr4);
 }
 printf("Setting fifo on address %p with size %d\n",(void *)map_addr,map_size);

 printf("DEV: %p\n",dev);
 printf("DEV4: %p\n",dev4);

 u_int32_t buf[1024];

 Fifo_Init(dev);


 printf("ISR: 0x%x\n",Read(dev,ISR));
 printf("ISR: 0x%x\n",Read(dev,ISR));
 // printf("IER: 0x%x\n",Read(dev,IER));

 Write(dev,ISR,0xFFFFFFFF);
 printf("RDFO: %d\n",Read(dev,RDFO));
 printf("RLR : %d\n",Read(dev,RLR) & 0x3FFFFF);
 printf("RDR : %d\n",Read(dev,RDR) & 0xF);

 int range_hlf = 0x2FFFF;
 int range_max = range_hlf << 1;
 int displ_max = 80;

// Write(dev,RDFR,0xa5);

 int i,j;
 while(1)
 for (i=0; i< Read(dev,RDFO); ++i) {
     if(dev4)
         buf[i] = Read(dev4,RDFD4);
     else
         buf[i] = Read(dev,RDFD);
     int32_t d0 = buf[i] + range_hlf;
     printf("[%3d 0x%8x] [",Read(dev,RDFO),buf[i]);
     for(j=0; j<displ_max; j++) {
              if ( j == d0   * displ_max / range_max ) printf("+");
              // else if ( j == d1   * displ_max / range_max ) printf("x");
         else if ( j == range_hlf * displ_max / range_max ) printf("^");
         else printf(" ");
     }
     printf("]\n");
 }


 Release();
 return 0;
}

