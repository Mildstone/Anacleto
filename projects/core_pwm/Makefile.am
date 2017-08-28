include $(top_srcdir)/Common.am
include $(top_srcdir)/fpga/FpgaCommon.am

BOARD ?= red_pitaya
VENDOR = rfx

FPGA_REPO_DIR   ?=
FPGA_REPO_DIR   += $(top_builddir)/fpga/lib/red-pitaya-notes
FPGA_REPO_DIR   += $(top_srcdir)/fpga/lib/rfx

vivado_PROJECTS = pwmgen
vivado_CORES    = rfx_pwm_1.0


pwmgen_VERSION = 1.0
pwmgen_VENDOR  = rfx
pwmgen_SOURCES = test_script.tcl
pwmgen_IP_SOURCES = rfx_pwm_1.0 \
					$(top_builddir)/fpga/lib/rfx/scc_52460/rfx_scc52460_1.0


rfx_pwm_SOURCES = rfx_pwmgen_v1_0_S00_AXI.vhd \
				  rfx_pwmgen_v1_0.vhd \
				  pwm.vhd



all:

clean:
	-rm -rf out .Xil .srcs sdk webtalk_* *jou*.tcl


