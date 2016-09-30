SUBDIRS =

include Common.am

AM_MAKEFLAGS = -j$(MAKE_PROCESS)



################################################################################
# Linux build provides: $(LINUX)
################################################################################

all: $(LINUX_IMAGE)


$(LINUX_SRCDIR):
	@ echo "Download linux sources";
if WITH_LINUX_GIT
	mkdir -p $@;
	echo "git clone ${LINUX_GIT} $@";
	git clone ${LINUX_GIT} $@;
endif

if LINUX_DIR_IN_SRCTREE
$(LINUX_BUILDDIR):
	mkdir -p $@;
endif

nconfig menuconfig xconfig gconfig: $(LINUX_SRCDIR) $(LINUX_BUILDDIR)
	$(MAKE) -C $< $@

.PHONY: linux-init
linux-init: $(LINUX_SRCDIR) $(LINUX_BUILDDIR) print-env
	$(_set_export); \
	$(MAKE) $(AM_MAKEFLAGS) -C $< mrproper; \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" \
		$(LINUX_DEF_CONFIG);


$(LINUX_IMAGE): $(LINUX_SRCDIR) $(LINUX_BUILDDIR) linux-init
	$(_set_export); \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" \
		UIMAGE_LOADADDR=$(LINUX_UIMAGE_LOADADDR) $(LINUX_PACKAGE); \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" modules; \
	mkdir -p $(TMP)/lib/modules; \
	$(MAKE) $(AM_MAKEFLAGS) -C $< O=$$O CFLAGS="$(LINUX_CFLAGS)" \
		INSTALL_MOD_PATH=$(TMP) modules_install; \
	cp $(LINUX_BUILDDIR)/arch/arm/boot/uImage $@

.PHONY: linux
linux: $(LINUX_IMAGE)


if TOOLCHAIN_LINARO_BIN
$(top_builddir)/toolchain:
	mkdir -p $@;
	curl -SL $(WITH_LINARO_BIN_TAR) | tar -xJv -C $@
else
$(top_builddir)/toolchain:
endif


clean-local:
	-$(MAKE) -C $(LINUX_BUILDDIR) clean
	-rm -rf lib/modules

MOSTLYCLEANFILES = $(LINUX_IMAGE)
                   
