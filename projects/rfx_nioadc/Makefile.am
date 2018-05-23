include $(top_srcdir)/Common.mk
include $(top_srcdir)/fpga/Common.mk

FPGA_REPO_DIR   += $(top_builddir)/fpga/lib/red-pitaya-notes
FPGA_REPO_DIR   += $(top_builddir)/fpga/lib/rfx

VENDOR = rfx

## PROJECTS ##

vivado_PROJECTS = nioadc

nioadc_SOURCES = red_pitaya.xdc \
                 src/trarec.vhdl \
                 src/trarec_tb.vhdl

.PHONY: linux
linux:
	$(MAKE) $(AM_MAKEFLAGS) -C linux/src clean all

shell:
	ssh $(DEVICE_USER)@$(DEVICE_IP)

all: dtb linux
