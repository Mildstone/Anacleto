include $(top_srcdir)/Common.mk
include $(top_srcdir)/fpga/Common.mk

VENDOR = rfx


## CORES ##
vivado_CORES    = rfx_pwm_1.0
pwm_SOURCES = src/rfx_pwm_v1_0.vhd \
			  src/rfx_pwm_v1_0_S00_AXI.vhd \
			  src/pwm.vhd



pwm_DRV_LINUX = linux/data/pwm_1.0.mdd \
				linux/data/pwm_1.0.tcl \
				linux/src/Kbuild.in \
				linux/src/rfx_pwmgen.c \
				linux/src/rfx_pwmgen.h


## PROJECTS ##
vivado_PROJECTS = pwmgen
pwmgen_VERSION = 1.0
pwmgen_SOURCES = src/test_script.tcl \
				 red_pitaya.xdc

pwmgen_IP_SOURCES = rfx_pwm_1.0

# pwmgen_PRJCFG = gen_script.tcl




