
include $(top_srcdir)/Common.am
include $(top_srcdir)/fpga/FpgaCommon.am

SOC_BOARD       ?= red_pitaya
VIVADO_VERSION  ?= 2015.4
VIVADO_SOC_PART ?= xc7z010clg400-1

#FPGA_BIT  ?= out/${SOC_BOARD}.bit
#FSBL_ELF  ?= sdk/fsbl/executable.elf
#DTS       ?= sdk/dts/devicetree.dts
#DTB       ?= sdk/dts/devicetree.dtb


SOURCES = \
 rtl/axi_master.v         rtl/red_pitaya_asg_ch.v    rtl/red_pitaya_dfilt1.v     rtl/red_pitaya_scope.v \
 rtl/axi_slave.v          rtl/red_pitaya_asg.v       rtl/red_pitaya_hk.v         rtl/red_pitaya_top.v \
 rtl/bus_clk_bridge.v     rtl/red_pitaya_daisy_rx.v  rtl/red_pitaya_pid_block.v \
 rtl/red_pitaya_ams.v     rtl/red_pitaya_daisy_tx.v  rtl/red_pitaya_pid.v \
 rtl/red_pitaya_analog.v  rtl/red_pitaya_daisy.v     rtl/red_pitaya_ps.v \
 \
 sdc/red_pitaya_top.xdc \
 sdc/red_pitaya2015_4.xdc \
 \
 ip/system.bd

BD_SOURCES =
# ip/system_bd.tcl

## NOTE: the ip name must be foprmatted as: [ip_path]/[ipname]_[major.minor]
IP_SOURCES = 


all: $(FPGA_BIT) $(DTB) ##@all Write bitstream and devicetree

clean:
	-rm -rf out .Xil .srcs sdk webtalk_*
	
