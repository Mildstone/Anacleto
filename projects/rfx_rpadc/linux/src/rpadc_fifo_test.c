#include <sys/ioctl.h>
#include <stdlib.h>
#include <string.h>

#include "rpadc_fifo.h"
#include "axi_reg.h"

#define BUF_SIZE 10240

#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))

#define CFG_REG_ADDR 0x43c20000

void plot_ascii_a(u_int32_t data, FILE *f) {
    int j;
    int range_hlf = 0x2FFFF;
    int displ_max = 80;
    int range_max = range_hlf << 1;

    fprintf(f,"[0x%8x] [",data);
    data = data & 0xFFFF + range_hlf;
    for(j=0; j<displ_max; j++) {
        if ( j == data * displ_max / range_max ) fprintf(f,"+");
        else if ( j == range_hlf * displ_max / range_max ) fprintf(f,"^");
        else fprintf(f," ");
    }
    fprintf(f,"]\n");
}

void plot_ascii_ab(u_int32_t data, FILE *f) {
    int j;
    int range_hlf = 0x2000;
    int displ_max = 80;
    int range_max = range_hlf << 1;

    int16_t d0 = data & 0xFFFF;
    int16_t d1 = data >> 16;
    fprintf(f,"[0x%8x,0x%8x] [",d0,d1);
    for(j=0; j<displ_max; j++) {
        if ( j == (d0 + range_hlf) * displ_max / range_max ) fprintf(f,"+");
        else if ( j == (d1 + range_hlf)   * displ_max / range_max ) printf("x");
        else if ( j == range_hlf * displ_max / range_max ) fprintf(f,"^");
        else fprintf(f," ");
    }
    fprintf(f,"]\n");
}

struct decimator_reg_t {
    int dec;
};


int main(int argc, char **argv) {

    struct decimator_reg_t *dec_reg;
    printf("rpadc test \n");
    const char *file_out_name = "rpadc_data";

    if(argc<3) {
        printf("usage: %s dev samples [file_out] \n",argv[0]);
        return 1;
    }


    int status = 0;
    int fd = open(argv[1], O_RDWR | O_SYNC);
    if(fd < 0) {
        printf(" ERROR: failed to open device file %s error: %d\n",argv[1],fd);
        return 1;
    }
    if(argc>=4) { file_out_name = argv[3]; }

    // PLOT TO SCREEN //
    // set decimation register //
    axi_reg_Init();
    dec_reg = axi_reg_Map(sizeof(struct decimator_reg_t),CFG_REG_ADDR);
    dec_reg->dec = 4E6;
    if(dec_reg->dec != 4E6) {
        perror("I was not able to set decimation\n");
        exit(1);
    }

    status = ioctl(fd, RFX_RPADC_RESET, 0);
    // usleep(10);
    int i, size = atoi(argv[2]);
    size = MIN((size)*sizeof(u_int32_t),BUF_SIZE);
    if (size <= 0) { return size; }

    u_int32_t *data = malloc(sizeof(u_int32_t) * size);
    if (!data) { perror("malloc\n"); exit (1); }

    status = ioctl(fd, RFX_RPADC_CLEAR, 0);
    for(i=0;i<size;) {
        int rb = read(fd,&data[0], size );
        for(int j=0; j<rb; j+=sizeof(u_int32_t)) {
            plot_ascii_ab(data[j],stdout);
        }
        i += rb;
    }


    // PLOT TO FILE //
    //
    //    u_int32_t *data = malloc(sizeof(u_int32_t) * size);
    //    if (!data) { perror("malloc\n"); exit (1); }
    //    for(i=0;i<size;) {
    //        int rb = read(fd,&data[i],BUF_SIZE);
    //        i += rb/sizeof(u_int32_t);
    //    }
    //
    //    char name[256];
    //    FILE *file_out = fopen(strcat(strcpy(name,file_out_name),".out"),"w");
    //    FILE *file_plt = fopen(strcat(strcpy(name,file_out_name),".plt"),"w");
    //    FILE *file_py = fopen(strcat(strcpy(name,file_out_name),".py"),"w");
    //    fwrite(data,sizeof(u_int32_t),size,file_out);
    //
    //    fprintf(file_py,
    //            "\ndef get_data():\n"
    //            "\timport struct\n"
    //            "\tf = open(\"%s.out\", \"rb\")\n"
    //            "\ta=[]\n"
    //            "\tfor i in range(%d):\n"
    //            "\t\ta.append(struct.unpack('i', f.read(4))[0])\n"
    //            "\treturn a"
    //            ,
    //            file_out_name,
    //            size
    //            );
    //
    //    fprintf(file_py,
    //            "\ndef plot_data():\n"
    //            "\timport matplotlib.pyplot as plt\n"
    //            "\ta=get_data();"
    //            "\tplt.plot(a)\n"
    //            "\tplt.show()\n"
    //            );
    //
    //    fprintf(file_plt,"plot \"scc52460_data.out\" binary format=\"%int32\" u 1 w lp");
    //
    //    fclose(file_out);
    //    fclose(file_plt);
    //    fclose(file_py);
    //    free(data);



    // AXI REG RELEASE //
    axi_reg_Release();

    // CLOSE FILE //
    close(fd);
    return 0;
}
