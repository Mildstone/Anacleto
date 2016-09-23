SUBDIRS =

include Common.am

AM_MAKEFLAGS = -j$(MAKE_PROCESS)






################################################################################
# Linux build provides: $(LINUX)
################################################################################

all: $(LINUX_IMAGE)

nconfig menuconfig xconfig gconfig: $(LINUX_DIR) $(LINUX_BUILDDIR)
	$(MAKE) -C $< $@

.PHONY: linux-init
linux-init: $(LINUX_DIR) $(LINUX_BUILDDIR) print-env
	$(_set_export); \
	$(MAKE) $(AM_MAKEFLAGS) -C $< mrproper; \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" xilinx_zynq_defconfig;

$(LINUX_BUILDDIR):
	mkdir -p $@;

$(LINUX_IMAGE): $(LINUX_DIR) $(LINUX_BUILDDIR) linux-init
	$(_set_export); \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" UIMAGE_LOADADDR=0x8000 uImage; \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" modules; \
	mkdir -p $(TMP)/lib/modules; \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" \
		INSTALL_MOD_PATH=$(TMP) modules_install; \
	cp $(LINUX_BUILDDIR)/arch/arm/boot/uImage $@

.PHONY: linux
linux: $(LINUX_IMAGE)



################################################################################
# device tree processing
################################################################################

DTREE_TAG     = xilinx-v${VIVADO_VERSION}
DEVICETREE    = $(TMP)/devicetree.dtb
DTREE_DIR     = $(TMP)/device-tree-xlnx-$(DTREE_TAG)
DTREE_URL     ?= https://github.com/Xilinx/device-tree-xlnx/archive/$(DTREE_TAG).tar.gz
DTREE_TAR     = $(DL)/device-tree-xlnx-$(DTREE_TAG).tar.gz
DL            = $(top_builddir)/download

$(DL):
	mkdir -p $@

devicetree: $(DEVICETREE)


$(DTREE_TAR): | $(DL)
	curl -L $(DTREE_URL) -o $@

$(DTREE_DIR): $(DTREE_TAR)
	mkdir -p $@
	tar -zxf $< --strip-components=1 --directory=$@

$(DEVICETREE): $(DTREE_DIR) $(LINUX) fpga
#        cp $(DTS) $(TMP)
#       patch $(TMP)/devicetree.dts $(srcdir)/patches/devicetree.patch
#        $(LINUX_DIR)/scripts/dtc/dtc -i $(FPGA_DIR)/sdk/dts/ $(TMP)/system.dts > $(TMP)/devicetree.dts
#        $(LINUX_DIR)/scripts/dtc/dtc -I dts -O dtb -o $(DEVICETREE) -i $(FPGA_DIR)/sdk/dts/ $(TMP)/devicetree.dts


clean-local:
	-$(MAKE) -C $(LINUX_BUILDDIR) clean
	-rm -rf lib/modules

MOSTLYCLEANFILES = $(LINUX_IMAGE)
                   
