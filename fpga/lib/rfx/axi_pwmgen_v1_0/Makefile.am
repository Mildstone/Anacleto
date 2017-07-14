include $(top_srcdir)/Common.am
include $(top_srcdir)/fpga/FpgaCommon.am

SOC_BOARD       ?= red_pitaya
VIVADO_VERSION  ?= 2015.4
VIVADO_SOC_PART ?= xc7z010clg400-1



pwm: ##@cores pwm generator
vivado_CORES = pwm

pwm_VENDOR     = rfx
pwm_VERSION    = 1.0
pwm_SOURCES    = src/pwm.vhd  \
		 src/axi_pwmgen_S00_AXI.vhd  \
		 src/axi_pwmgen.vhd
pwm_DRV_LINUX  = linux/src/pwm.c


all: cores
clean:
	-rm -rf core

