# ////////////////////////////////////////////////////////////////////////// //
#
# This file is part of the anacleto project.
# Copyright 2018 Andrea Rigoni Garola <andrea.rigoni@igi.cnr.it>.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# ////////////////////////////////////////////////////////////////////////// //

include Common.mk
include $(top_srcdir)/conf/kscripts/linux.mk
include $(top_srcdir)/conf/kscripts/yocto.mk


AM_MAKEFLAGS = -j$(MAKE_PROCESS)
ACLOCAL_AMFLAGS = -I conf/m4

all: ##@all download and build the selected toolchain and the linux image
all: toolchain $(LINUX_IMAGE)


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
	echo " MAKE           : $${MAKE}"; \
	echo " "; \
	echo "---------------------------------------------------------------------------"; \
	echo ""



################################################################################
# U-Boot build provides: $(UBOOT)
################################################################################

INSTALL_DIR ?= tmp
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
# Yocto meta-xilinx download
################################################################################

YOCTO_XILINX_DIR ?= ${YOCTO_DIR}/meta-xilinx

DOWNLOADS += oe-core meta-xilinx

oe-core: ##@yocto download and prepare the oe-core yocto layer
oe_core_DIR = ${YOCTO_DIR}/oe-core
oe_core_URL = https://github.com/openembedded/openembedded-core.git
oe_core_BRANCH = $(YOCTO_GIT_BRANCH)

meta-xilinx: ##@yocto download and prepare the meta-xilinx yocto layer
meta_xilinx_DIR = $(YOCTO_XILINX_DIR)
meta_xilinx_URL = $(YOCTO_XILINX_URL)
meta_xilinx_BRANCH = master


oe-shell: ##@yocto enter oe-init-build-env
oe-shell: PATH := $(abs_top_builddir)/$(YOCTO_PYBIN_PATH):$(abs_top_builddir)/$(YOCTO_BITBAKE_BINDIR):$(PATH)
oe-shell: yocto-py2-link
	@ cd $(oe_core_DIR); source ./oe-init-build-env; \
	  bitbake




clean-local:
	-$(MAKE) -C $(LINUX_BUILDDIR) clean
	-rm -rf lib/modules

MOSTLYCLEANFILES = $(LINUX_IMAGE)


hello.log: ##@log write hello.log file
hello.log:
	@ echo "hello bootstrap" > $@


print-hello: EXAMPLE_STRING_VAR = not set
print-hello:
	@ echo "this is the var: $(EXAMPLE_STRING_VAR)"
