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
	make -C $< mrproper; \
	make -C $< O=$$O ARCH=arm xilinx_zynq_defconfig; \
	make -C $< O=$$O ARCH=arm CFLAGS=$(LINUX_CFLAGS) -j $(MAKE_PROCESS) \
		   UIMAGE_LOADADDR=0x8000 $@; \
	make -C $< O=$$O ARCH=arm CFLAGS=$(LINUX_CFLAGS) -j $(MAKE_PROCESS) \
		   modules; \
	mkdir -p $(TMP)/lib/modules; \
	make -C $< O=$$O ARCH=arm CFLAGS=$(LINUX_CFLAGS) -j $(MAKE_PROCESS) \
	           INSTALL_MOD_PATH=$(TMP) modules_install; \
	cp $</arch/arm/boot/$@ $(TMP)


MOSTLYCLEANFILES = $(LINUX)
                   
