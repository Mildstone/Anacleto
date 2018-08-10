include $(top_srcdir)/Common.mk
include $(top_srcdir)/fpga/Common.mk

VENDOR = rfx
FPGA_REPO_DIR   += $(top_builddir)/fpga/lib/red-pitaya-notes

vivado_CORES = suart
suart_VERSION = 1.0
suart_SOURCES = rtl


vivado_CORES += axis_8b10b
axis_8b10b_VERSION = 1.0
axis_8b10b_SOURCES = \
                     8b10b_encdec/8b10b_IO.vhd \
                     8b10b_encdec/8b10_enc.vhd \
					 8b10b_encdec/8b10_dec.vhd
axis_8b10b_TB_SOURCES = \
                        8b10b_encdec/IO_TB.vhd

vhdl_CORES = axis_8b10b
axis_8b10b_UNITS = IO_TB

## PROJECTS ##
vivado_PROJECTS = spalk
spalk_VERSION = 1.0
spalk_SOURCES =  \
				 red_pitaya.xdc

spalk_IP_SOURCES = suart



#DOWNLOADS += vuart
#vuart_URL = https://github.com/alexforencich/verilog-uart.git
#vuart_BRANCH = master
#vuart_dir = vuart


NODOCKERBUILD = ghdl_% ghdl-% $(hello_UNITS)
vhdl_CORES   += hello
hello_SOURCES = hello_world/hello.vhdl \
                hello_world/adder.vhdl \
				hello_world/adder_tb.vhdl

hello_UNITS = hello_world adder_tb




## ////////////////////////////////////////////////////////////////////////////////
## //  IDE  ///////////////////////////////////////////////////////////////////////
## ////////////////////////////////////////////////////////////////////////////////

NODOCKERBUILD += $(targets_IDE) $(axis_8b10b_UNITS) $(hello_UNITS)

ATOM_PACKAGES += language-vhdl \
                 linter-vhdl \
				 vhdl-entity-converter \
				 busy-signal build


