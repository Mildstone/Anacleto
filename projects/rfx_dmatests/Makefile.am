include $(top_srcdir)/Common.mk
include $(top_srcdir)/fpga/Common.mk


VENDOR = rfx

## PROJECTS ##
vivado_PROJECTS = axidma_example
axidma_example_VERSION = 1.0
axidma_example_SOURCES = src/system.bd \
						 src/red_pitaya.xdc


.PHONY: linux
linux: ##@linux compile drivers
	@ $(MAKE) -C linux clean all
