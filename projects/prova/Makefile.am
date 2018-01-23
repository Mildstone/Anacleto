include $(top_srcdir)/Common.mk
include $(top_srcdir)/fpga/Common.mk

FPGA_REPO_DIR   += $(top_builddir)/fpga/lib/red-pitaya-notes
FPGA_REPO_DIR   += $(top_builddir)/fpga/lib/rfx

VENDOR = rfx

## CORES ##
vivado_CORES    = pwm_1.0 example ipdes

rfx_pwm_SOURCES = pwm.vhd
rfx_pwm_DRV_LINUX = linux/data/pwm_1.0.mdd \
					linux/src/pwm_1_0.c \
					linux/data/pwm_1.0.tcl


example_SOURCES = example.cpp


## PROJECTS ##
vivado_PROJECTS = pwmtest ipdes_prj ipdes_ps0

pwm_VERSION = 1.0
pwmtest_VERSION = 1.0
pwmtest_IP_SOURCES = pwm_1.0

vivado_PROJECTS += example_test
example_test_IP_SOURCES = example

ipdes_ps0_VERSION = 1.0

ipdes_VERSION = 1.0

ipdes_prj_IP_SOURCES = ipdes


