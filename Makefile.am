include Common.am

AM_MAKEFLAGS = -j$(MAKE_PROCESS)


all: $(top_builddir)/toolchain $(LINUX_IMAGE)

################################################################################
# LINARO
################################################################################

# TODO: remove this and put it to configure
# TODO: identify file type
if TOOLCHAIN_LINARO_BIN
$(top_builddir)/toolchain:
	@ \
	  mkdir -p ${DL} $@; \
	  echo "getting linaro from tar: ${LINARO_BIN_TAR}"; \
	  _tar=${DL}/$$(echo $(LINARO_BIN_TAR) | sed -e 's|.*/||'); \
	  test -f $$_tar || curl -SL $(LINARO_BIN_TAR) > $$_tar; \
	  _wcl=$$(tar -tJf $$_tar | sed -e 's|/.*||' | uniq | wc -l); \
	  if test $$_wcl = 1; then \
	  tar -xJf $$_tar -C $@ --strip 1; \
	  else \
	  tar -xJf $$_tar -C $@; \
	  fi
else
$(top_builddir)/toolchain:
endif

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

nconfig menuconfig xconfig gconfig: $(LINUX_SRCDIR) $(LINUX_BUILDDIR)
	$(MAKE) -C $< $@

.PHONY: linux-init linux-init-s
linux-init-s: $(LINUX_SRCDIR) $(LINUX_BUILDDIR) print-env
	$(_set_export); \
	cd $(LINUX_BUILDDIR); \
	export LS=$$(ls); \
	export KERNELVERSION=$$($(MAKE) -s -C $< kernelversion); \
	export DEFCONFIG=${abs_top_srcdir}/conf/linux/$${KERNELVERSION}/${SOC_BOARD}.def; \
	export SRCARCH=${ARCH}; \
	export srctree=$(LINUX_SRCDIR); \
	$(LINUX_BUILDDIR)/scripts/kconfig/conf --defconfig=$${DEFCONFIG} Kconfig

linux-init:
	$(MAKE) -s linux-init-s

.PHONY: kernelversion kernelrelease
kernelversion kernelrelease: $(LINUX_SRCDIR) $(LINUX_BUILDDIR)
	@ $(_set_export); \
	  $(MAKE) -s $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" $@

.PHONY: savedefconfig
savedefconfig: $(LINUX_SRCDIR) $(LINUX_BUILDDIR) print-env
	$(_set_export); \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" $@

$(LINUX_BUILDDIR)/.config: $(LINUX_SRCDIR) $(LINUX_BUILDDIR)
	$(_set_export); \
	$(MAKE) -s $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" defconfig; \
	$(MAKE) -s linux-init;

$(LINUX_IMAGE): $(LINUX_SRCDIR) $(LINUX_BUILDDIR) $(LINUX_BUILDDIR)/.config
	$(_set_export); \
	$(MAKE) $(AM_MAKEFLAGS) -C $< mrproper; \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" \
		UIMAGE_LOADADDR=$(LINUX_UIMAGE_LOADADDR) $(LINUX_PACKAGE); \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" modules; \
	mkdir -p $(TMP)/lib/modules; \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" \
		INSTALL_MOD_PATH=$(TMP) modules_install; \
	cp $(LINUX_BUILDDIR)/arch/arm/boot/uImage $@

.PHONY: linux
linux: $(LINUX_IMAGE)



################################################################################
# Yocto download
################################################################################

YOCTO_DIR ?= yocto

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

