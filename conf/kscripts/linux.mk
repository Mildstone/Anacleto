################################################################################
# Linux build
################################################################################


DOWNLOADS += linux
linux_DIR    = $(LINUX_SRCDIR)
linux_URL    = $(LINUX_URL)
linux_BRANCH = $(LINUX_GIT_BRANCH)


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
	export KERNELVERSION=$$($(MAKE) -s -C $< kernelversion); \
	export DEFCONFIG=${abs_top_srcdir}/conf/linux/$${KERNELVERSION}/${BOARD}.def; \
	export SRCARCH=${ARCH}; \
	export srctree=$(LINUX_SRCDIR); \
	$(LINUX_BUILDDIR)/scripts/kconfig/conf --defconfig=$${DEFCONFIG} Kconfig

linux-init:
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

