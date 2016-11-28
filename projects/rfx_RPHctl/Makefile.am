SUBDIRS = logic src

include $(top_srcdir)/Common.am


define _envset
. $(VIVADO_SETUP_SCRIPT); \
. $(VIVADO_SDK_SETUP_SCRIPT); \
. /opt/Xilinx/petalinux-v2015.4-final/settings.sh; \
export PETALINUX=$${PETALINUX}; \
export srcdir=$(srcdir); \
export top_srcdir=$(top_srcdir); \
export SOC_BOARD=${SOC_BOARD}; \
export VIVADO_VERSION=${VIVADO_VERSION}; \
export VIVADO_SOC_PART=${VIVADO_SOC_PART}; \
export maxThreads=8
endef


## ////////////////////////////////////////////////////////////////////////// ##
## ///  TRY PETA  /////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

.PHONY: peta
peta:
	@ ( ${_envset}; \
	    cd peta; petalinux-config --get-hw-description=../logic/sdk; )


shell:
	( ${_envset}; bash -i; )
