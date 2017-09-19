include Common.mk

AM_MAKEFLAGS = -j$(MAKE_PROCESS)

all: ##@all download and build the selected toolchain and the linux image
all: $(top_builddir)/toolchain $(LINUX_IMAGE)



################################################################################
# Linux build
################################################################################

# TODO: move this to configure step
# TODO: identify file type
$(LINUX_SRCDIR):
	@ echo "Download linux sources"; \
	  mkdir -p $@;
if WITH_LINUX_GIT
	@ echo "git clone ${LINUX_GIT} $@"; \
	  git clone ${LINUX_GIT} $@;
else
if WITH_LINUX_TAR
	@ \
	  mkdir -p ${DL} $@; \
	  echo " getting linux from tar:  ${LINUX_TAR}"; \
	  _tar=${DL}/$$(echo $(LINUX_TAR) | sed -e 's|.*/||'); \
	  test -f $$_tar || curl -SL $(LINUX_TAR) > $$_tar; \
	  _wcl=$$(tar -tzf $$_tar | sed -e 's|/.*||' | uniq | wc -l); \
	  if test $$_wcl = 1; then \
	  tar -xzf $$_tar -C $@ --strip 1; \
	  else \
	  tar -xzf $$_tar -C $@; \
	  fi
endif
endif

if LINUX_DIR_IN_SRCTREE
$(LINUX_BUILDDIR):
	mkdir -p $@;
endif


.PHONY: linux-init linux-init-s
linux-init-s: $(LINUX_SRCDIR) $(LINUX_BUILDDIR) print-env
	$(_set_export); \
	cd $(LINUX_BUILDDIR); \
	export LS=$$(ls); \
	export KERNELVERSION=$$($(MAKE) -s -C $< kernelversion); \
	export DEFCONFIG=${abs_top_srcdir}/conf/linux/$${KERNELVERSION}/${BOARD}.def; \
	export SRCARCH=${ARCH}; \
	export srctree=$(LINUX_SRCDIR); \
	$(LINUX_BUILDDIR)/scripts/kconfig/conf --defconfig=$${DEFCONFIG} Kconfig

linux-init: ##@linux initialize linux sources applying the soc defconfig
	$(MAKE) -s linux-init-s

linux-:     ##@linux_target use: "make linux-<target>" to build target in linux directory
linux-help: ##@linux_target get linux build help
linux-menuconfig: ##@linux_target enter menuconfig inside linux sources
linux-nconfig: ##@linux_target enter ncurses config inside linux sources
linux-xconfig: ##@linux_target enter xlib config inside linux sources
linux-gconfig: ##@linux_target enter gnome config inside linux sources
linux-savedefconfig: ##@linux_target save default configuration in linux builddir defconfig file
linux-kernelversion: ##@linux_target display the current kernel version
linux-kernelrelease: ##@linux_target display the current kernel release

.PHONY: linux-%
linux-nconfig linux-menuconfig linux-xconfig linux-gconfig: \
 $(LINUX_SRCDIR) $(LINUX_BUILDDIR) $(LINUX_BUILDDIR)/.config
	$(_set_export); \
	_target=$@; \
	$(MAKE) -C $< O=$$O $${_target//linux-/}


linux-updateconfig: ##@linux update the soc defconf in /conf/linux/...
linux-updateconfig: $(LINUX_SRCDIR) $(LINUX_BUILDDIR) $(LINUX_BUILDDIR)/.config
	$(_set_export); \
	KERNELVERSION=$$($(MAKE) -s -C $< kernelversion); \
	DEFCONFIG=${abs_top_srcdir}/conf/linux/$${KERNELVERSION}/${BOARD}.def; \
	$(MAKE) linux-savedefconfig && cp $(LINUX_BUILDDIR)/defconfig $${DEFCONFIG}

linux-%: $(LINUX_SRCDIR) $(LINUX_BUILDDIR)
	$(_set_export); \
	_target=$@; \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" $${_target//linux-/}

$(LINUX_BUILDDIR)/.config: $(LINUX_SRCDIR) $(LINUX_BUILDDIR)
	$(_set_export); \
	$(MAKE) $(AM_MAKEFLAGS) -C $< mrproper; \
	$(MAKE) -s $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" defconfig; \
	$(MAKE) -s linux-init;

$(LINUX_IMAGE): $(LINUX_SRCDIR) $(LINUX_BUILDDIR) $(LINUX_BUILDDIR)/.config
	$(_set_export); \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" \
		UIMAGE_LOADADDR=$(LINUX_UIMAGE_LOADADDR) $(LINUX_PACKAGE); \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" modules; \
	mkdir -p $(TMP)/lib/modules; \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" \
		INSTALL_MOD_PATH=$(TMP) modules_install; \
	cp $(LINUX_BUILDDIR)/arch/arm/boot/uImage $@

.PHONY: linux
linux: ##@linux build linux image
linux: $(LINUX_IMAGE)

## /////////////////////////////////////////////////////////////////////////////
## // DUMPS  ///////////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////

print-env: ##@micellaneous print environment used for crosscompiling linux
	@\
	$(_set_export); \
	echo ""; \
	echo "---[KERNEL BUILD]----------------------------------------------------------"; \
	echo " compiler: $${CROSS_COMPILE}${CC}"; \
	echo " arch    : ${ARCH}"; \
	echo " flags   : ${LINUX_CFLAGS}"; \
	echo " TOOLCH  : ${TOOLCHAIN_PATH}"; \
	echo " PATH    : $${PATH}"; \
	echo " builddir: $${O}"; \
	echo " "; \
	echo " LINUX_IMAGE    : ${LINUX_IMAGE}"; \
	echo " LINUX_DIR      : ${LINUX_DIR}"; \
	echo " LINUX_SRCDIR   : ${LINUX_SRCDIR}"; \
	echo " LINUX_BUILDDIR : ${LINUX_BUILDDIR}"; \
	echo " LINUX_GIT      : ${LINUX_GIT}"; \
	echo " "; \
	echo "---------------------------------------------------------------------------"; \
	echo ""



################################################################################
# U-Boot build provides: $(UBOOT)
################################################################################

ENVTOOLS_CFG    = $(INSTALL_DIR)/etc/fw_env.config

UBOOT_URL             ?= https://github.com/Xilinx/u-boot-xlnx/archive/xilinx-v2015.4.tar.gz

UBOOT_SCRIPT_BUILDROOT = patches/u-boot.script.buildroot
UBOOT_SCRIPT_DEBIAN    = patches/u-boot.script.debian
UBOOT_SCRIPT           = $(INSTALL_DIR)/u-boot.scr

.PHONY: u-boot

u-boot: $(UBOOT) $(UBOOT_SCRIPT) $(ENVTOOLS_CFG)

$(UBOOT_TAR): | $(DL)
	curl -L $(UBOOT_URL) -o $@

$(UBOOT_DIR): $(UBOOT_TAR)
	mkdir -p $@
	tar -zxf $< --strip-components=1 --directory=$@
	patch -d $@ -p 1 < patches/u-boot-xlnx-$(UBOOT_TAG).patch

$(UBOOT): $(UBOOT_DIR)
	mkdir -p $(@D)
	make -C $< arch=ARM zynq_red_pitaya_defconfig
	make -C $< arch=ARM CFLAGS=$(UBOOT_CFLAGS) all
	cp $</u-boot $@

$(UBOOT_SCRIPT): $(INSTALL_DIR) $(UBOOT_DIR) $(UBOOT_SCRIPT_BUILDROOT) $(UBOOT_SCRIPT_DEBIAN)
	$(UBOOT_DIR)/tools/mkimage -A ARM -O linux -T script -C none -a 0 -e 0 -n "boot Buildroot" -d $(UBOOT_SCRIPT_BUILDROOT) $@.buildroot
	$(UBOOT_DIR)/tools/mkimage -A ARM -O linux -T script -C none -a 0 -e 0 -n "boot Debian"    -d $(UBOOT_SCRIPT_DEBIAN)    $@.debian
	cp $@.debian $@

$(ENVTOOLS_CFG): $(UBOOT_DIR)
	mkdir -p $(INSTALL_DIR)/etc/
	cp $</tools/env/fw_env.config $(INSTALL_DIR)/etc



################################################################################
# Yocto download
################################################################################

YOCTO_DIR ?= yocto

yocto: ##@yocto download and prepare yocto poky build environment
yocto: $(YOCTO_DIR)

$(YOCTO_DIR):
	@ echo "Download Yocto sources"; \
	  mkdir -p $@;
if WITH_YOCTO_GIT
	@ echo "git clone -b ${YOCTO_VERSION} ${YOCTO_GIT} $@"; \
	  git clone -b ${YOCTO_VERSION} ${YOCTO_GIT} $@;
else
if WITH_YOCTO_TAR
	@ \
	  echo " getting Yocto from tar:  ${YOCTO_TAR}"; \
	  _tar=${DL}/$$(echo $(YOCTO_TAR) | sed -e 's|.*/||'); \
	  test -f $$_tar || curl -SL $(YOCTO_TAR) > $$_tar; \
	  _wcl=$$(tar -tjf $$_tar | sed -e 's|/.*||' | uniq | wc -l); \
	  if test $$_wcl = 1; then \
	  tar -xjf $$_tar -C $@ --strip 1; \
	  else \
	  tar -xjf $$_tar -C $@; \
	  fi
endif
endif

################################################################################
# Yocto meta-xilinx download
################################################################################

YOCTO_XILINX_DIR ?= ${YOCTO_DIR}/meta-xilinx

yocto_xilinx: ##@yocto download and prepare the meta-xilinx yocto layer
yocto_xilinx: $(YOCTO_XILINX_DIR)

$(YOCTO_XILINX_DIR): ${YOCTO_DIR}
	@ echo "Download Yocto meta-xilinx sources"; \
	  mkdir -p $@;
if WITH_YOCTO_XILINX_GIT
	@ echo "git clone ${YOCTO_XILINX_GIT} $@"; \
	  git clone ${YOCTO_XILINX_GIT} $@;
else
if WITH_YOCTO_XILINX_TAR
	@ \
	  echo " getting Yocto meta-xilinx from tar: ${YOCTO_XILINX_TAR}"; \
	  _tar=${DL}/$$(echo $(YOCTO_XILINX_TAR) | sed -e 's|.*/||'); \
	  test -f $$_tar || curl -SL $(YOCTO_XILINX_TAR) > $$_tar; \
	  _wcl=$$(tar -tzf $$_tar | sed -e 's|/.*||' | uniq | wc -l); \
	  if test $$_wcl = 1; then \
	  tar -xzf $$_tar -C $@ --strip 1; \
	  else \
	  tar -xzf $$_tar -C $@; \
	  fi
endif
endif



clean-local:
	-$(MAKE) -C $(LINUX_BUILDDIR) clean
	-rm -rf lib/modules

MOSTLYCLEANFILES = $(LINUX_IMAGE)

