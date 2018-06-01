include $(top_srcdir)/Common.mk
include $(top_srcdir)/fpga/Common.mk

VENDOR = w7x


## CORES ##
vivado_CORES   = timing_1.0
timing_1_0_SOURCES = \
					 src/w7x_timing_v1_0_S00_AXI.vhd \
					 src/w7x_timing_v1_0.vhd \
					 src/w7x_timing.vhd \
					 src/TestTiming.vhd

timing_1_0_IPCFG = src/w7x_timing_setup.tcl

## PROJECTS ##
vivado_PROJECTS = timing_brd
timing_brd_IP_SOURCES = timing_1.0
timing_brd_SOURCES = timing_1.0 \
                     src/red_pitaya.xdc
# timing_brd_PRJCFG = logic/vivado_src/system_2016.4.tcl






