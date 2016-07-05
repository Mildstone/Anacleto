
SUBDIRS = src

include Common.am


################################################################################
# Linux build provides: $(LINUX)
################################################################################

nconfig menuconfig xconfig gconfig: $(LINUX_DIR) $(LINUX_BUILDDIR)
	export PATH="$${PATH}:$(TOOLCHAIN_PATH)"; \
	export CROSS_COMPILE=${CROSS_COMPILE}; \
	export O=$(LINUX_BUILDDIR); \
	$(MAKE) -C $(top_srcdir)/linux-xlnx O=$$O $@


.PHONY: linux-init
linux-init: $(LINUX_DIR) $(LINUX_BUILDDIR)
	export PATH="$${PATH}:$(TOOLCHAIN_PATH)"; \
	export CROSS_COMPILE=${CROSS_COMPILE}; \
	export O=$(LINUX_BUILDDIR); \
	$(MAKE) -C $< mrproper; \
	$(MAKE) -C $< O=$$O ARCH=arm xilinx_zynq_defconfig;

$(LINUX_BUILDDIR):
	mkdir -p $@;

$(LINUX_IMAGE): $(LINUX_DIR) $(LINUX_BUILDDIR) linux-init
	export PATH="$${PATH}:$(TOOLCHAIN_PATH)"; \
	export CROSS_COMPILE=${CROSS_COMPILE}; \
	export O=$(LINUX_BUILDDIR); \
	$(MAKE) -C $< O=$$O ARCH=arm CFLAGS="$(LINUX_CFLAGS)" -j $(MAKE_PROCESS) \
		   UIMAGE_LOADADDR=0x8000 $@; \
	$(MAKE) -C $< O=$$O ARCH=arm CFLAGS="$(LINUX_CFLAGS)" -j $(MAKE_PROCESS) \
		   modules; \
	$(MAKE) -p $(TMP)/lib/modules; \
	$(MAKE) -C $< O=$$O ARCH=arm CFLAGS="$(LINUX_CFLAGS)" -j $(MAKE_PROCESS) \
	           INSTALL_MOD_PATH=$(TMP) modules_install; \
	cp $$O/arch/arm/boot/$@ $(TMP)


.PHONY: linux
linux: $(LINUX_IMAGE)



all: $(LINUX_IMAGE)


clean-local:
	-$(MAKE) -C $(top_builddir)/linux-xlnx clean
	-rm -rf lib/modules

MOSTLYCLEANFILES = $(LINUX_IMAGE)
                   
