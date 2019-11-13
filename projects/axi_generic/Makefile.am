include $(top_srcdir)/Common.mk
include $(top_srcdir)/fpga/Common.mk

VENDOR = axi

## CORES ##
vivado_CORES    = cfgreg
axi_cfgreg_SOURCES   = src/axi_cfgreg.v
axi_cfgreg_DRV_LINUX = linux/data/cfgreg_0.1.mdd \
					   linux/data/cfgreg_0.1.tcl \
					   linux/src/cfgreg_0.1.c


## PROJECTS ##
vivado_PROJECTS = cfgreg_tbp
cfgreg_tbp_IP_SOURCES = cfgreg




