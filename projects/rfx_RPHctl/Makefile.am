SUBDIRS = logic src

include $(top_srcdir)/Common.am


define _envset
. $(VIVADO_SETUP_SCRIPT); \
. $(VIVADO_SDK_SETUP_SCRIPT); \
. /opt/Xilinx/petalinux-v2015.4-final/settings.sh; \
export srcdir=$(srcdir); \
export top_srcdir=$(top_srcdir); \
export tmp=$(TMP); \
export FPGA_REPO_DIR=${FPGA_REPO_DIR}; \
export FPGA_DIR=${FPGA_DIR}; \
export SYSTEM=${SYSTEM}; \
export FPGA_SDC=${FPGA_SDC}; \
export FPGA_BIT=${FPGA_BIT}; \
export SOC_BOARD=${SOC_BOARD}; \
export VIVADO_VERSION=${VIVADO_VERSION}; \
export VIVADO_SOC_PART=${VIVADO_SOC_PART}; \
export RTL_SOURCES=${RTL_SOURCES}; \
export maxThreads=8
endef



## ////////////////////////////////////////////////////////////////////////// ##
## ///  TRY PETA  /////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

.PHONY: peta
peta:
	( ${_envset}; \
	  cd peta; petalinux-config; )


