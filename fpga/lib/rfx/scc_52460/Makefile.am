include $(top_srcdir)/Common.mk
include $(top_srcdir)/fpga/Common.mk

FPGA_REPO_DIR   += $(top_builddir)/fpga/lib/red-pitaya-notes
FPGA_REPO_DIR   += $(top_builddir)/fpga/lib/rfx

VENDOR  = rfx

vivado_CORES = scc52460_1.0 \
			   scc52460_2.0

# AXI LITE interface only #
scc52460_1_0_SOURCES    = src/axi_SCC52460.vhd \
			      src/axi_SCC52460_S00_AXI.vhd \
			      src/AD7641_serial_slave.vhd


# AXI LITE and STREAM #
scc52460_2_0_SOURCES = src_2.0/axi_SCC52460.vhd \
					   src_2.0/axi_SCC52460_S00_AXI.vhd \
					   src_2.0/AD7641_serial_slave.vhd

vivado_PROJECTS = scc52460_axi4
scc52460_axi4_VERSION     = 2.0
scc52460_axi4_IP_SOURCES  = scc52460_2.0


