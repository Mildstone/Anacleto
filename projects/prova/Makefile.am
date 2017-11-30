include $(top_srcdir)/Common.mk
include $(top_srcdir)/fpga/Common.mk

FPGA_REPO_DIR   += $(top_builddir)/fpga/lib/red-pitaya-notes
FPGA_REPO_DIR   += $(top_builddir)/fpga/lib/rfx

VENDOR = rfx

## CORES ##
vivado_CORES    = pwm_1.0 example
rfx_pwm_SOURCES = pwm.vhd
example_SOURCES = example.cpp

## PROJECTS ##
vivado_PROJECTS = pwmtest
pwm_VERSION = 1.0
pwmtest_VERSION = 1.0
pwmtest_IP_SOURCES = pwm_1.0

vivado_PROJECTS += example_test
example_test_IP_SOURCES = example

vivado_PROJECTS += newp
newp_VERSION = 1.0
# newp_PRJCFG  = init.tcl
