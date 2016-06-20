
SUBDIRS = src

include Common.am


################################################################################
# Linux build provides: $(LINUX)
################################################################################

nconfig menuconfig xconfig gconfig:
	$(MAKE) -C $(top_srcdir)/linux-xlnx $@

.PHONY: linux
linux: $(LINUX_IMAGE) 


# $(LINUX_DIR): $(LINUX_TAR)
#	mkdir -p $@
#	tar -zxf $< --strip-components=1 --directory=$@
#	patch -d $@ -p 1 < $(top_srcdir)/patches/linux-xlnx-$(LINUX_TAG)-config.patch
#	patch -d $@ -p 1 < $(top_srcdir)/patches/linux-xlnx-$(LINUX_TAG)-eeprom.patch
#	patch -d $@ -p 1 < $(top_srcdir)/patches/linux-xlnx-$(LINUX_TAG)-lantiq.patch
#	patch -d $@ -p 1 < $(top_srcdir)/patches/linux-xlnx-$(LINUX_TAG)-wifi.patch
#	cp -r $(top_srcdir)/patches/rtl8192cu $@/drivers/net/wireless/
#	cp -r $(top_srcdir)/patches/lantiq/*  $@/drivers/net/phy/


$(LINUX_IMAGE): $(LINUX_DIR)
	export PATH="$${PATH}:$(TOOLCHAIN_PATH)"; \
	export CROSS_COMPILE=${CROSS_COMPILE}; \
	export O=${LINUX_BUILDDIR}; \
	mkdir -p $$O; \
	$(MAKE) -C $< mrproper; \
	$(MAKE) -C $< O=$$O ARCH=arm xilinx_zynq_defconfig; \
	$(MAKE) -C $< O=$$O ARCH=arm CFLAGS="$(LINUX_CFLAGS)" -j $(MAKE_PROCESS) \
		   UIMAGE_LOADADDR=0x8000 $@; \
	$(MAKE) -C $< O=$$O ARCH=arm CFLAGS="$(LINUX_CFLAGS)" -j $(MAKE_PROCESS) \
		   modules; \
	$(MAKE) -p $(TMP)/lib/modules; \
	$(MAKE) -C $< O=$$O ARCH=arm CFLAGS="$(LINUX_CFLAGS)" -j $(MAKE_PROCESS) \
	           INSTALL_MOD_PATH=$(TMP) modules_install; \
	cp $</arch/arm/boot/$@ $(TMP)


.PHONY: linux
linux: $(LINUX_IMAGE)

all: $(LINUX_IMAGE)


clean-local:
	-$(MAKE) -C $(top_builddir)/linux-xlnx clean
	-rm -rf lib/modules

MOSTLYCLEANFILES = $(LINUX_IMAGE)
                   
