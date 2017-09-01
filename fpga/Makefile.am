SUBDIRS = lib/red-pitaya-notes \
		  lib/rfx


.ONESHELL:
include $(top_srcdir)/Common.mk


################################################################################
# device tree processing
################################################################################


DTREE_TAG     = xilinx-v${VIVADO_VERSION}
DTREE_URL    ?= https://github.com/Xilinx/device-tree-xlnx/archive/$(DTREE_TAG).tar.gz
DTREE_TAR     = $(DL)/device-tree-xlnx-$(DTREE_TAG).tar.gz

xlnx-devicetree: $(DTREE_DIR)

$(DL):
	mkdir -p $@

$(DTREE_TAR): | $(DL)
	curl -L $(DTREE_URL) -o $@

$(DTREE_DIR): $(DTREE_TAR)
	mkdir -p $@
	tar -zxf $< --strip-components=1 --directory=$@






