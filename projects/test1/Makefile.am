include $(top_srcdir)/Common.am
include $(top_srcdir)/fpga/FpgaCommon.am

BOARD           ?= red_pitaya
VIVADO_VERSION  ?= 2015.4
VIVADO_SOC_PART ?= xc7z010clg400-1

VENDOR = rfx
vivado_CORES    = rfx_pwmbis_1.0

pwmbis_SOURCES = test_script.tcl


pwmbis_SOURCES = rfx_pwmgen_v1_0_S00_AXI.vhd \
				 rfx_pwmgen_v1_0.vhd \
				 pwm.vhd


all:

clean:
	-rm -rf out .Xil .srcs sdk webtalk_*


