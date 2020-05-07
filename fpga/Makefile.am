#SUBDIRS = lib/red-pitaya-notes \
		  lib/rfx


.ONESHELL:
include $(top_srcdir)/Common.mk


################################################################################
# device tree processing
################################################################################

DEVICETREE_BASEFILES_TAR ?= https://github.com/Xilinx/device-tree-xlnx/archive/xilinx-v2019.1.tar.gz

DOWNLOADS += xlnx-devicetree


# DTREE_TAG   = xilinx-v${VIVADO_VERSION}
# DTREE_URL  ?= https://github.com/Xilinx/device-tree-xlnx/archive/$(DTREE_TAG).tar.gz
# DTREE_TAR   = $(DL)/device-tree-xlnx-$(DTREE_TAG).tar.gz


xlnx-devicetree: ##@devicetree download devicetree repo
xlnx-devicetree: DOWNLOAD_DIR = $(top_builddir)/downloads/xlnx-devicetree
xlnx_devicetree_URL = $(DEVICETREE_BASEFILES_TAR)
xlnx_devicetree_DIR = $(DTREE_DIR)

# $(DL):
# 	mkdir -p $@

# $(DTREE_TAR): | $(DL)
# 	curl -L $(DTREE_URL) -o $@

# $(DTREE_DIR): $(DTREE_TAR)
# 	mkdir -p $@
# 	tar -zxf $< --strip-components=1 --directory=$@






