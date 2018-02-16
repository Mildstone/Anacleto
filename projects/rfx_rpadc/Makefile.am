include $(top_srcdir)/Common.mk
include $(top_srcdir)/fpga/Common.mk

FPGA_REPO_DIR   += $(top_builddir)/fpga/lib/red-pitaya-notes
FPGA_REPO_DIR   += $(top_builddir)/fpga/lib/rfx

VENDOR = rfx

## PROJECTS ##

# DMA #
vivado_PROJECTS = rpadc_dma


# FIFO #
vivado_PROJECTS += rpadc_fifo
rpadc_fifo_VERSION   = 1.0
rpadc_fifo_SOURCES   = red_pitaya.xdc

rpadc_fifo_ARCHIVE   = $(NAME)_archive.zip





