include $(top_srcdir)/Common.am


# Vivado from Xilinx provides IP handling, FPGA compilation
# hsi (hardware software interface) provides software integration
# both tools are run in batch mode with an option to avoid log/journal files
VIVADO = vivado -nolog -nojournal -mode batch
VIVADO_SHELL = vivado -nolog -nojournal -mode tcl
HSI    = hsi    -nolog -nojournal -mode batch
HSI_SHELL    = hsi    -nolog -nojournal -mode tcl


SOC_BOARD       ?= red_pitaya
VIVADO_VERSION  ?= 2015.4
VIVADO_SOC_PART ?= xc7z010clg400-1



# . /opt/Xilinx/petalinux-v2015.4-final/settings.sh;

define _envset
. $(VIVADO_SETUP_SCRIPT); \
. $(VIVADO_SDK_SETUP_SCRIPT); \
export srcdir=$(srcdir); \
export top_srcdir=$(top_srcdir); \
export tmp=$(TMP); \
export FPGA_REPO_DIR=${FPGA_REPO_DIR}; \
export FPGA_DIR=${FPGA_DIR}; \
export SOC_BOARD=${SOC_BOARD}; \
export VIVADO_VERSION=${VIVADO_VERSION}; \
export VIVADO_SOC_PART=${VIVADO_SOC_PART}; \
export maxThreads=8
endef


## ////////////////////////////////////////////////////////////////////////// ##
## ///  VIVADO PROJECT  ///////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

project:
	( ${_envset}; \
	  vivado -source $(FPGA_DIR)/red_pitaya_vivado_project.tcl -mode tcl )
