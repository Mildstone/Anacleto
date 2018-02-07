
include $(top_srcdir)/conf/scripts/build_common.mk
include $(top_srcdir)/conf/scripts/toolchain.mk


TMP          ?= $(abs_top_builddir)

## ////////////////////////////////////////////////////////////////////////// ##
## ///  LINUX  ////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

LINUX_CFLAGS    ?= "-O2 -mtune=cortex-a9 -mfpu=neon -mfloat-abi=hard"
LINUX_PACKAGE   ?= uImage
LINUX_IMAGE     ?= $(TMP)/$(LINUX_PACKAGE)
LINUX_DIR       ?= linux

if LINUX_DIR_IN_SRCTREE
 LINUX_SRCDIR    = $(abs_top_srcdir)/$(LINUX_DIR)
 LINUX_BUILDDIR  = $(abs_top_builddir)/$(LINUX_DIR)
 LINUX_BUILD_O   = $(LINUX_BUILDDIR)
else
 LINUX_SRCDIR    = $(abs_top_builddir)/$(LINUX_DIR)
 LINUX_BUILDDIR  = $(abs_top_builddir)/$(LINUX_DIR)
endif

ARCH                     = arm
WITH_TOOLCHAIN_DIR      ?= ${abs_top_builddir}/toolchain
TOOLCHAIN_PATH          ?= ${WITH_TOOLCHAIN_DIR}/bin
CROSS_COMPILE           ?= arm-linux-gnueabihf-


## ////////////////////////////////////////////////////////////////////////// ##
## /// ACTIVATE HELP TARGET ///////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

@TARGET_SELFHELP@

help: print_banner
print_banner:
	@ cat $(top_srcdir)/docs/logo.txt

## /////////////////////////////////////////////////////////////////////////////
## // DIRECTORIES //////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////

DL   ?= $(DOWNLOAD_DIR)
TMP  ?= $(abs_top_builddir)

${DL} ${TMP}:
	@$(MKDIR_P) $@

## /////////////////////////////////////////////////////////////////////////////
## // EXPORTS //////////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////

define _set_export
export ARCH=$(ARCH); \
export CROSS_COMPILE=${CROSS_COMPILE}; \
export PATH=$${PATH}:$(TOOLCHAIN_PATH); \
export O=${LINUX_BUILD_O}
endef


## /////////////////////////////////////////////////////////////////////////////
## // DOCKER  //////////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////

# docker build targets
@AX_DOCKER_BUILD_TARGETS@

NODOCKERBUILD = help reconfigure
export DOCKER_ENTRYPOINT ?=

locale-gen: USER = root
locale-gen:
	@ locale-gen

## /////////////////////////////////////////////////////////////////////////////
## // RECONFIGURE  /////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////

$(top_srcdir)/configure.ac: $(foreach x,$(CONFIG_SUBDIRS), $(top_srcdir)/$x/configure.ac)
	@ touch $@

.PHONY: reconfigure
reconfigure: $(top_srcdir)/configure.ac
reconfigure: ##@miscellaneous re-run configure with last passed arguments
	@ \
	echo " -- Reconfiguring build with following parameters: -----------"; \
	echo $(shell $(abs_top_builddir)/config.status --config);              \
	echo " -------------------------------------------------------------"; \
	echo ; \
	cd '$(abs_top_builddir)' && \
	$(abs_top_srcdir)/configure $(shell $(abs_top_builddir)/config.status --config);




