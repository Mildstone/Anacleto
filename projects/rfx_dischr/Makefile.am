include $(top_srcdir)/Common.mk
include $(top_srcdir)/fpga/Common.mk

FPGA_REPO_DIR   += $(top_builddir)/fpga/lib/red-pitaya-notes
# FPGA_REPO_DIR   += $(top_builddir)/fpga/lib/rfx

VENDOR = rfx

vivado_CORES = trigger
trigger_SOURCES = src/trigger.cpp

vivado_PROJECTS       = dischr-prj
dischr_prj_SOURCES    = src/red_pitaya.xdc
dischr_prj_IP_SOURCES = trigger

dump:
	@ echo "$(NAME) -> $(SOURCES)"



