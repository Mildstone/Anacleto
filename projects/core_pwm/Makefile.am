include $(top_srcdir)/Common.am
include $(top_srcdir)/fpga/FpgaCommon.am

BOARD           ?= red_pitaya
VIVADO_VERSION  ?= 2015.4
VIVADO_SOC_PART ?= xc7z010clg400-1


FPGA_REPO_DIR   += $(top_builddir)/fpga/lib/red-pitaya-notes
FPGA_REPO_DIR   += $(top_srcdir)/fpga/lib/rfx



vivado_PROJECTS = rfx_pwmgen_1.0
rfx_pwmgen_1_0_SOURCES = test_script.tcl
rfx_pwmgen_1_0_IP_SOURCES = rfx_pwm_1.0 \
			    $(top_builddir)/fpga/lib/rfx/scc_52460/rfx_scc52460_1.0

vivado_CORES = rfx_pwm_1.0
rfx_pwm_1_0_SOURCES = rfx_pwmgen_v1_0_S00_AXI.vhd \
		      rfx_pwmgen_v1_0.vhd \
		      pwm.vhd

all:

clean:
	-rm -rf out .Xil .srcs sdk webtalk_*

