include $(top_srcdir)/Common.mk
include $(top_srcdir)/fpga/Common.mk

#FPGA_REPO_DIR   += $(top_builddir)/fpga/lib/red-pitaya-notes
#FPGA_REPO_DIR   += $(top_builddir)/fpga/lib/rfx

VENDOR = rp

## PROJECTS ##

vivado_PROJECTS = logic

logic_VERSION    = 1.0
logic_SOURCES    = \
		   redpitaya/fpga/prj/logic/rtl/red_pitaya_top.sv \
		   redpitaya/fpga/prj/logic/rtl/red_pitaya_ps.sv \
		   redpitaya/fpga/rtl \
		   redpitaya/fpga/sdc/red_pitaya.xdc

logic_BD_SOURCES = redpitaya/fpga/prj/logic/ip/system.tcl

# look at: linux/drivers/iio/adc/xilinx-xadc.h
#          linux/drivers/iio/adc/xilinx-xadc-core.c

redpitaya: ## download redpitaya repo
DOWNLOADS        = redpitaya
redpitaya_URL    = https://github.com/redpitaya/redpitaya.git
redpitaya_BRANCH = master

