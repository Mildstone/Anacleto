include $(top_srcdir)/Common.mk
include $(top_srcdir)/fpga/Common.mk

FPGA_REPO_DIR   += $(top_builddir)/fpga/lib/red-pitaya-notes
FPGA_REPO_DIR   += $(top_builddir)/fpga/lib/rfx

VENDOR = rfx

## CORES ##
vivado_CORES = tmstp
tmstp_SOURCES = src/tmstp.cpp

## PROJECTS ##
vivado_PROJECTS = spdgauss
spdgauss_SOURCES = red_pitaya.xdc
spdgauss_IP_SOURCES = tmstp
