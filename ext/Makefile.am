include $(top_srcdir)/Common.mk
include $(top_srcdir)/conf/kscripts/python.mk
# include $(top_srcdir)/conf/kscripts/ext_ccStickers.mk
# include $(top_srcdir)/conf/kscripts/ext_libjit.mk
# include $(top_srcdir)/conf/kscripts/ext_llvm.mk
# include $(top_srcdir)/conf/kscripts/ext_nodejs_node.mk
# include $(top_srcdir)/conf/kscripts/ext_mdsplus.mk

define _ext_bootstrap
$(eval
$1/configure: | $1
	@ cd $1; ./bootstrap
)
endef

define _ext_autogen_sh
$(eval
$1/configure: | $1
	@ cd $1; ./autogen.sh
)
endef

define _ext_configure
$(eval
$1/config.log: $1/configure
	@ cd $1; ./configure $($(subst -,_,$(subst ' ',_,$(subst .,_,$1)))_CONFIGURE_ARGS)
$1/Makefile: $1/config.log
	@ $(MAKE) $(AM_MAKEFLAGS) -C $1 Makefile
)
endef


define _ext_cmake
$(eval
.PHONY: $1/CMakeCache.txt
$1/CMakeLists.txt: | $1
$1/CMakeCache.txt: $1/CMakeLists.txt
        @ cd $1; cmake $($(subst -,_,$(subst ' ',_,$(subst .,_,$1)))_CMAKE_ARGS) .
$1/Makefile: $1/CMakeCache.txt
)
endef


define _ext_cmake_offsrc
$(eval
.PHONY: $3/CMakeCache.txt
$2/CMakeLists.txt: | $2
$3/CMakeCache.txt: $2/CMakeLists.txt | $3
        @ cd $3; cmake $($(subst -,_,$(subst ' ',_,$(subst .,_,$1)))_CMAKE_ARGS) $(abspath $2)
$2/Makefile: $3/CMakeCache.txt
)
endef



ext-: ##@ext enter ext module with $TARGET
ext-%: %/Makefile
	@ $(MAKE) $(AM_MAKEFLAGS) -C $(subst ext-,,$@) $(TARGET)

all: TARGET = all
all: $(EXT_MODULES)

# clean: TARGET = clean
# clean: ext-libjit


list: ##@ext list defined ext modules
list : _item = $(info | $1: ) $(foreach x,$($1),$(info |  - $x))
list:
	@ \
	$(info ,-----------------------------------------------------------------) \
	$(info | ext modules defined ) \
	$(info |) \
	$(call _item,EXT_MODULES) \
	$(info |) \
	$(info |) \
	$(info `-----------------------------------------------------------------) :



# /////////////////////////////////////////////////////////////////////////// //
# //  EXT MODULES  ////////////////////////////////////////////////////////// //
# /////////////////////////////////////////////////////////////////////////// //

DOWNLOADS  = $(EXT_MODULES)

ccStickers: ##@ext download ccStickers sources
ccStickers_URL = $(CCSTICKERS_URL)
$(call _ext_bootstrap,ccStickers)
$(call _ext_configure,ccStickers)

libjit: ##@ext download libjit sources
libjit_URL = $(LIBJIT_URL)
$(call _ext_bootstrap,libjit)
$(call _ext_configure,libjit)

llvm:   ##@ext download llvm sources
llvm_URL   = $(LLVM_URL)

ext-nodejs-node: AM_MAKEFLAGS += -j$(MAKE_PROCESS)
nodejs-node:
nodejs_node_URL = $(NODEJS_NODE_URL)
nodejs_node_CONFIGURE_ARGS = --shared
$(call _ext_configure,nodejs-node)


EXT_MDSPLUS_URL    ?= https://github.com/mdsplus/mdsplus.git
EXT_MDSPLUS_BRANCH ?= alpha
ext-mdsplus: AM_MAKEFLAGS += -j1
mdsplus: ##@ext mdsplus
mdsplus_URL    = $(EXT_MDSPLUS_URL)
mdsplus_BRANCH = $(EXT_MDSPLUS_BRANCH)
mdsplus_CONFIGURE_ARGS = --enable-debug=$(ENABLE_DEBUG)
$(call _ext_bootstrap,mdsplus)
$(call _ext_configure,mdsplus)

unexport DOCKER_CONTAINER
unexport DOCKER_IMAGE
unexport DOCKER_URL

DOWNLOADS += koheron
koheron:
koheron_URL = https://github.com/Koheron/koheron-sdk.git
koheron_BRANCH = master


gnuradio: PYTHON_PACKAGES = PyBOMBS
# DOWNLOADS += gnuradio
gnuradio: ##@ext download and install gnuradio
gnuradio: pip-install
	@ \
	  pybombs recipes add gr-recipes https://github.com/gnuradio/gr-recipes.git; \
	  pybombs recipes add gr-etcetera https://github.com/gnuradio/gr-etcetera.git; \
	  pybombs prefix init gnuradio-install; \
	  pybombs install gnuradio

gnuradio-companion: gnuradio
	@ \
	  pybombs run gnuradio



DOWNLOADS += aws-fpga
aws-fpga: ##@ext aws FPGA examples and tutorials
aws_fpga_URL = https://github.com/aws/aws-fpga.git
aws_fpga_BRANCH = master




DOWNLOADS += finn
finn: ##@NN finn FPGA code
finn_URL = https://github.com/Xilinx/FINN.git
finn_BRANCH = master
finn_DIR = FINN

DOWNLOADS += hwgq
hwgq: ##@NN Half Wave Gaussian Quantization
hwgq_URL = https://github.com/zhaoweicai/hwgq.git
hwgq_BRANCH = master


hwgq_prepare: USER = root
hwgq_prepare: DEB_PACKAGES = cmake cmake-qt-gui libboost-all-dev \
                             libprotobuf-dev protobuf-compiler \
							 libhdf5-dev \
							 liblmdb-dev libleveldb-dev \
							 libsnappy-dev \
							 libopencv-dev
hwgq_prepare:
	@ apt -y install $(DEB_PACKAGES)





################################################################################
# UBOOT
################################################################################
DOWNLOADS += u-boot

UBOOT_TAG   = redpitaya-v2016.4
u_boot_DIR  = u-boot-xlnx-$(UBOOT_TAG)
u_boot_URL    ?= https://github.com/RedPitaya/u-boot-xlnx/archive/$(UBOOT_TAG).tar.gz
## u_boot_CFLAGS  = "-O2 -mtune=cortex-a9 -mfpu=neon -mfloat-abi=hard"


################################################################################
# U-Boot build provides: $(UBOOT)
################################################################################

UBOOT           = $(TMP)/u-boot.elf
UBOOT_SCRIPT    = $(TMP)/u-boot.scr

.PHONY: ext-u-boot
ext-u-boot: $(UBOOT) $(UBOOT_SCRIPT)


$(UBOOT): | $(u_boot_DIR) $(TMP)
	make -C $< arch=ARM zynq_red_pitaya_defconfig
	make -C $< arch=ARM CFLAGS=$(UBOOT_CFLAGS)
	cp $(UBOOT_DIR)/u-boot $@

$(UBOOT_SCRIPT): $(INSTALL_DIR) $(UBOOT_DIR) $(UBOOT)
	$(UBOOT_DIR)/tools/mkimage -A ARM -O linux -T script -C none -a 0 -e 0 -n "boot Debian" -d patches/u-boot/u-boot.script $@










# /////////////////////////////////////////////////////////////////////////// //
# //  DOCKER RPM BUILDER  /////////////////////////////////////////////////// //
# /////////////////////////////////////////////////////////////////////////// //

DOWNLOADS += docker-rpm-builder
docker-rpm-builder: ##@@rpm docker-rpm-builder download code
docker_rpm_builder_URL = https://github.com/docker-rpm-builder/docker-rpm-builder.git
docker_rpm_builder_BRANCH = 1.42

docker-rpm-builder-install: ##@rpm install local docker-rpm-builder package
docker-rpm-builder-install: | docker-rpm-builder
	@ cd docker-rpm-builder; python2 setup.py install --user





# // PYNQ //

DOWNLOADS += pynq

pynq: ##@pynq download
pynq_URL = https://github.com/Xilinx/PYNQ.git
pynq_BRANCH = master


define _envset
 . $(VIVADO_SETUP_SCRIPT); \
 . $(VIVADO_SDK_SETUP_SCRIPT)
endef

pynq-build: ##@pynq build
	$(_envset); cd pynq; ./build.sh



