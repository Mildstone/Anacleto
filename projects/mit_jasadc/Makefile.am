include $(top_srcdir)/Common.mk
include $(top_srcdir)/fpga/Common.mk

FPGA_REPO_DIR   += $(top_builddir)/fpga/lib/red-pitaya-notes
FPGA_REPO_DIR   += $(top_builddir)/fpga/lib/rfx

VENDOR = mit

## PROJECTS ##

vivado_PROJECTS = jasadc

jasadc_VERSION = 1.0
jasadc_SOURCES = xdc/red_pitaya.xdc





.PHONY: linux
linux:
	$(MAKE) $(AM_MAKEFLAGS) -C linux/src clean all

shell:
	ssh $(DEVICE_USER)@$(DEVICE_IP)

all: dtb linux
