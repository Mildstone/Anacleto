include $(top_srcdir)/Common.am
include $(top_srcdir)/fpga/FpgaCommon.am

HELP_DESCRIPTION = w7x_timing module logic, all tagets are related to the \
		   vivado project managenment.


SOC_BOARD       ?= red_pitaya
VIVADO_VERSION  ?= 2015.4
VIVADO_SOC_PART ?= xc7z010clg400-1

SOURCES = red_pitaya.xdc


BD_SOURCES =
#p1_w7x.tcl

## NOTE: the ip name must be formatted as: [ip_path]/[ipname]_[major.minor]
IP_SOURCES = w7x_timing_1.0



all: $(FPGA_BIT) $(DTB) ##@all Write bitstream and devicetree

clean:
	-rm -rf out .Xil .srcs sdk webtalk_*

