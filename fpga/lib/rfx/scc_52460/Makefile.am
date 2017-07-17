include $(top_srcdir)/Common.am
include $(top_srcdir)/fpga/FpgaCommon.am


FPGA_REPO_DIR   += $(top_builddir)/fpga/lib/red-pitaya-notes
FPGA_REPO_DIR   += $(top_srcdir)/fpga/lib/rfx



vivado_CORES = rfx_scc52460_1.0 \
	       rfx_scc52460_2.0

rfx_scc52460_1_0_SOURCES    = src/axi_SCC52460.vhd \
			      src/axi_SCC52460_S00_AXI.vhd \
			      src/AD7641_serial_slave.vhd
rfx_scc52460_1_0_DRV_LINUX  =

rfx_scc52460_2_0_SOURCES    = src_2.0/axi_SCC52460.vhd \
			      src_2.0/axi_SCC52460_S00_AXI.vhd \
			      src_2.0/AD7641_serial_slave.vhd


vivado_PROJECTS = rfx_scc52460_example_1.0 \
		  rfx_scc52460_example_2.0

rfx_scc52460_example_1_0_IP_SOURCES = rfx_scc52460_1.0
rfx_scc52460_example_2_0_IP_SOURCES = rfx_scc52460_2.0


all: projects

clean:
	-rm -rf core



