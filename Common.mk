## ////////////////////////////////////////////////////////////////////////// //
##
## This file is part of the autoconf-bootstrap project.
## Copyright 2018 Andrea Rigoni Garola <andrea.rigoni@igi.cnr.it>.
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
## ////////////////////////////////////////////////////////////////////////// //

include $(top_srcdir)/conf/kscripts/build_common.mk
include $(top_srcdir)/conf/kscripts/toolchain.mk
include $(top_srcdir)/conf/kscripts/docker.mk


## ////////////////////////////////////////////////////////////////////////// ##
## /// ACTIVATE HELP TARGET ///////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

@TARGET_SELFHELP@

help: print_banner
print_banner:
	@ cat $(top_srcdir)/doc/logo.txt

## /////////////////////////////////////////////////////////////////////////////
## // DIRECTORIES //////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////

kscripts = $(top_srcdir)/conf/kscripts

DL   ?= $(DOWNLOAD_DIR)
TMP  ?= $(abs_top_builddir)

${DL} ${TMP}:
	@$(MKDIR_P) $@

## /////////////////////////////////////////////////////////////////////////////
## // DOCKER  //////////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////

locale-gen: USER = root
locale-gen:
	@ locale-gen $${LANG}

## /////////////////////////////////////////////////////////////////////////////
## // RECONFIGURE  /////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////

$(top_srcdir)/configure.ac: $(foreach x,$(CONFIG_SUBDIRS), $(top_srcdir)/$x/configure.ac)
	@ touch $@

.PHONY: reconfigure
reconfigure: ##@miscellaneous re-run configure with last passed arguments
	@ \
	echo " -- Reconfiguring build with following parameters: -----------"; \
	echo $(shell $(abs_top_builddir)/config.status --config);              \
	echo " -------------------------------------------------------------"; \
	echo ; \
	cd '$(abs_top_builddir)' && \
	$(abs_top_srcdir)/configure $(shell $(abs_top_builddir)/config.status --config);
	


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
 LINUX_BUILD_O   = $(filter-out $(LINUX_SRCDIR),$(LINUX_BUILDDIR))
else
 LINUX_SRCDIR    = $(abs_top_builddir)/$(LINUX_DIR)
 LINUX_BUILDDIR  = $(abs_top_builddir)/$(LINUX_DIR)
endif

ARCH                     = arm
WITH_TOOLCHAIN_DIR      ?= ${abs_top_builddir}/toolchain
TOOLCHAIN_PATH          ?= ${WITH_TOOLCHAIN_DIR}/bin
CROSS_COMPILE           ?= arm-linux-gnueabihf-



define _set_export
export ARCH=$(ARCH); \
export CROSS_COMPILE=${CROSS_COMPILE}; \
export PATH=$${PATH}:$(TOOLCHAIN_PATH); \
export O=${LINUX_BUILD_O}
endef
