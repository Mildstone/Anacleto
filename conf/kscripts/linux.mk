################################################################################
# Linux build
################################################################################

LINUX_CFLAGS    ?= "-O2 -mtune=cortex-a9 -mfpu=neon -mfloat-abi=hard"
LINUX_PACKAGE   ?= uImage
LINUX_IMAGE     ?= $(TMP)/$(LINUX_PACKAGE)
LINUX_DIR       ?= linux

if LINUX_DIR_IN_SRCTREE
 LINUX_SRCDIR    = $(abs_top_srcdir)/$(LINUX_DIR)
 LINUX_BUILDDIR  = $(abs_top_builddir)/$(LINUX_DIR)
 LINUX_BUILD_O   = $(filter-out $(LINUX_SRCDIR),$(LINUX_BUILDDIR))
else
 LINUX_SRCDIR    = $(abs_top_builddir)/$(LINUX_DIR)
 LINUX_BUILDDIR  = $(abs_top_builddir)/$(LINUX_DIR)
endif




define _set_export
export ARCH=$(ARCH); \
export CROSS_COMPILE=${CROSS_COMPILE}; \
export PATH=$${PATH}:$(TOOLCHAIN_PATH); \
export O=${LINUX_BUILD_O}
endef



linux-:     ##@linux_target use: "make linux-<target>" to build target in linux directory
linux-init: ##@linux initialize linux sources applying the soc defconfig
linux-help: ##@linux_target get linux build help
linux-menuconfig: ##@linux_target enter menuconfig inside linux sources
linux-nconfig: ##@linux_target enter ncurses config inside linux sources
linux-xconfig: ##@linux_target enter xlib config inside linux sources
linux-gconfig: ##@linux_target enter gnome config inside linux sources
linux-savedefconfig: ##@linux_target save default configuration in linux builddir defconfig file
linux-kernelversion: ##@linux_target display the current kernel version
linux-kernelrelease: ##@linux_target display the current kernel release
linux-updateconfig: ##@linux update the soc defconf in /conf/linux/...


.PHONY: linux-init linux-init-s
linux-init-s: $(LINUX_SRCDIR) print-env
	$(_set_export); \
	$(MKDIR_P) $(LINUX_BUILDDIR); \
	cd $(LINUX_BUILDDIR); \
	export LS=$$(ls); \
	export CC=$(CROSS_COMPILE)$(CC); \
	export KERNELVERSION=$$($(MAKE) -s -C $< kernelversion); \
	export DEFCONFIG=${abs_top_srcdir}/conf/linux/$${KERNELVERSION}/${BOARD}.def; \
	export SRCARCH=${ARCH}; \
	export srctree=$(LINUX_SRCDIR); \
	$(LINUX_BUILDDIR)/scripts/kconfig/conf --defconfig=$${DEFCONFIG} Kconfig


linux-apply-patches: ##@linux apply patches
linux-apply-patches: $(LINUX_SRCDIR)
	@ cd $(LINUX_SRCDIR); \
	KERNELVERSION=$$($(MAKE) -s -C $(LINUX_SRCDIR) kernelversion); \
	_patch="$(abs_top_srcdir)/conf/linux/$${KERNELVERSION}/*.patch $(LINUX_PATCH)"; \
	test -f $${_patch} && \
	for p in $${_patch}; do patch -N -p0 < $$p ||:; done;

linux-init: linux-apply-patches
	$(MAKE) -s linux-init-s

.PHONY: linux-%
linux-nconfig linux-menuconfig linux-xconfig linux-gconfig: \
 $(LINUX_SRCDIR) $(LINUX_BUILDDIR)/.config
	$(_set_export); \
	_target=$@; \
	$(MAKE) -C $< O=$$O $${_target//linux-/}


linux-updateconfig: $(LINUX_SRCDIR) $(LINUX_BUILDDIR)/.config
	$(_set_export); \
	KERNELVERSION=$$($(MAKE) -s -C $< kernelversion); \
	DEFCONFIG=${abs_top_srcdir}/conf/linux/$${KERNELVERSION}/${BOARD}.def; \
	$(MAKE) linux-savedefconfig && cp $(LINUX_BUILDDIR)/defconfig $${DEFCONFIG}

linux-%: $(LINUX_SRCDIR) $(LINUX_BUILDDIR)
	$(_set_export); \
	_target=$@; \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" $${_target//linux-/}

$(LINUX_BUILDDIR)/.config: $(LINUX_SRCDIR)
	$(_set_export); \
	$(MKDIR_P) $(LINUX_BUILDDIR); \
	$(MAKE) $(AM_MAKEFLAGS) -C $< mrproper; \
	$(MAKE) -s $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" defconfig; \
	$(MAKE) -s linux-init;

$(LINUX_IMAGE): $(LINUX_SRCDIR) $(LINUX_BUILDDIR)/.config
	$(_set_export); \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" \
		UIMAGE_LOADADDR=$(LINUX_UIMAGE_LOADADDR) $(LINUX_PACKAGE); \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" modules; \
	mkdir -p $(TMP)/lib/modules; \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" \
		INSTALL_MOD_PATH=$(TMP) modules_install; \
	cp $(LINUX_BUILDDIR)/arch/arm/boot/uImage $@

