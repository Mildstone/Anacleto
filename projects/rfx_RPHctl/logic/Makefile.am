
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
	  rtl/axi_master.v  rtl/axi_wr_fifo.v  rtl/red_pitaya_ams.v     \
	  rtl/red_pitaya_asg.v     rtl/red_pitaya_hk.v  rtl/red_pitaya_pid.v  \
	  rtl/red_pitaya_ps.v    rtl/red_pitaya_scope.v \
	  rtl/axi_slave.v    rtl/red_pitaya_asg_ch.v  \
	  rtl/red_pitaya_dfilt1.v  rtl/red_pitaya_pid_block.v  \
	  rtl/red_pitaya_pll.sv  rtl/red_pitaya_pwm.sv  rtl/red_pitaya_top.v \
	  sdc/red_pitaya.xdc

BD_SOURCES =
#ip/system_bd.tcl

## NOTE: the ip name must be foprmatted as: [ip_path]/[ipname]_[major.minor]
IP_SOURCES = ip/myip_1.0 ip/myip2_1.0


all: $(FPGA_BIT) $(DTB) ##@all Write bitstream and devicetree

clean:
	-rm -rf out .Xil .srcs sdk webtalk_*
	
