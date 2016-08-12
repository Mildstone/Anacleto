
SUBDIRS = src

include Common.am
export O=$(LINUX_BUILDDIR)

AM_MAKEFLAGS = -j$(MAKE_PROCESS)


################################################################################
# Linux build provides: $(LINUX)
################################################################################

all: $(LINUX_IMAGE)

nconfig menuconfig xconfig gconfig: $(LINUX_DIR) $(LINUX_BUILDDIR)
	$(MAKE) -C $< $@

.PHONY: linux-init
linux-init: $(LINUX_DIR) $(LINUX_BUILDDIR) print-env
	$(MAKE) $(AM_MAKEFLAGS) -C $< mrproper; \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" xilinx_zynq_defconfig;

$(LINUX_BUILDDIR):
	mkdir -p $@;

$(LINUX_IMAGE): $(LINUX_DIR) $(LINUX_BUILDDIR) linux-init
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" UIMAGE_LOADADDR=0x8000 $@; \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" modules; \
	mkdir -p $(TMP)/lib/modules; \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" \
		INSTALL_MOD_PATH=$(TMP) modules_install; \
	cp $$O/arch/arm/boot/$@ $(TMP)

.PHONY: linux
linux: $(LINUX_IMAGE)


print-env:
	@\
	echo ""; \
	echo "---[KERNEL BUILD]----------------------------------------------------------"; \
	echo " compiler: $${CROSS_COMPILE}${CC}"; \
	echo " arch    : $${ARCH}"; \
	echo " flags   : $${LINUX_CFLAGS}"; \
	echo " builddir: $${O}"; \
	echo "---------------------------------------------------------------------------"; \
	echo ""

clean-local:
	-$(MAKE) -C $(LINUX_BUILDDIR) clean
	-rm -rf lib/modules

MOSTLYCLEANFILES = $(LINUX_IMAGE)
                   
