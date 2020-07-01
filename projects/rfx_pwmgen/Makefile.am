include $(top_srcdir)/Common.mk
include $(top_srcdir)/fpga/Common.mk
include $(top_srcdir)/conf/kscripts/yocto.mk

VENDOR = rfx


## CORES ##
vivado_CORES    = rfx_pwm_1.0
pwm_SOURCES = src/rfx_pwm_v1_0.vhd \
			  src/rfx_pwm_v1_0_S00_AXI.vhd \
			  src/pwm.vhd



pwm_DRV_LINUX = linux/data/pwm_1.0.mdd \
				linux/data/pwm_1.0.tcl \
				linux/src/Kbuild.in \
				linux/src/rfx_pwmgen.c \
				linux/src/rfx_pwmgen.h


## PROJECTS ##
vivado_PROJECTS = pwmgen
pwmgen_VERSION = 1.0
pwmgen_SOURCES = src/test_script.tcl \
				 red_pitaya.xdc

pwmgen_IP_SOURCES = rfx_pwm_1.0

# pwmgen_PRJCFG = gen_script.tcl

yocto-%: DOCKER_CONTAINER = yocto-build
yocto-%: DOCKER_DEVICES = /dev/net/tun
yocto-%: DOCKER_IMAGE = yocto-build
yocto-%: DOCKER_URL = $(top_srcdir)/docker/yocto-build
#yocto-%: DOCKER_IMAGE = gmacario/build-yocto
## yocto-%: DOCKER_IMAGE = crops/yocto:ubuntu-18.04-builder

# yocto-%: BBPATH = $(srcdir)/yocto

# enable take env from external
export BB_ENV_EXTRAWHITE = BBLAYERS DISTRO MACHINE PACKAGE_CLASSES

export BBLAYERS = \
  $(abs_top_builddir)/yocto/meta \
  $(abs_top_builddir)/yocto/meta-poky  \
  $(abs_top_builddir)/yocto/meta-xilinx/meta-xilinx-bsp \
  $(abs_top_builddir)/yocto/meta-xilinx/meta-xilinx-standalone \
  $(abs_top_builddir)/yocto/meta-xilinx/meta-xilinx-contrib 
  
export DISTRO          = poky
export PACKAGE_CLASSES = package_rpm
export MACHINE         = qemu-zynq7


DOWNLOADS += meta-xilinx

meta-xilinx: ##@yocto download and prepare the meta-xilinx yocto layer
meta_xilinx_URL = https://github.com/Xilinx/meta-xilinx.git
meta_xilinx_BRANCH = pyro
meta_xilinx_DIR = ./yocto-build/meta-Xilinx





