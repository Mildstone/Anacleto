include $(top_srcdir)/Common.mk
include $(top_srcdir)/fpga/Common.mk

VENDOR = rfx

## CORES ##
vivado_CORES    = rfx_pwm_1.0
rfx_pwm_1_0_SOURCES = src/rfx_pwm_v1_0.vhd \
					  src/rfx_pwm_v1_0_S00_AXI.vhd \
					  src/pwm.vhd

## PROJECTS ##
vivado_PROJECTS = pwmgen
pwmgen_VERSION = 1.0
pwmgen_SOURCES = src/test_script.tcl \
				 red_pitaya.xdc

pwmgen_IP_SOURCES = rfx_pwm_1.0


