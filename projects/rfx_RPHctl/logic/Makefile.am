
include $(top_srcdir)/Common.am
include $(top_srcdir)/fpga/Makefile.am

SOC_BOARD       ?= red_pitaya
VIVADO_VERSION  ?= 2015.4
VIVADO_SOC_PART ?= xc7z010clg400-1

FPGA_BIT  ?= out/${SOC_BOARD}.bit

FSBL_ELF  ?= sdk/fsbl/executable.elf
DTS       ?= sdk/dts/devicetree.dts
DTB       ?= sdk/dts/devicetree.dtb


SOURCES = hdl/prova1.v \
	  hdl/prova2.vhd \
	  hdl/prova3.xdc

BD_SOURCES =

## NOTE: the ip name must be foprmatted as: [ip_path]/[ipname]_[major.minor]
IP_SOURCES = ip/myip_1.0 ip/myip2_1.0


all: $(FPGA_BIT) $(DTB)

clean:
	-rm -rf out .Xil .srcs sdk webtalk_*
	




