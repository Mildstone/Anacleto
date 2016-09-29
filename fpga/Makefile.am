
.ONESHELL:
include $(top_srcdir)/Common.am

# build artefacts
FPGA_BIT=out/red_pitaya.bit
FSBL_ELF=sdk/fsbl/executable.elf
DEVICE_TREE=sdk/dts/system.dts

SYSTEM ?= system.tcl

if ENABLE_FPGA
define _envset 
. $(VIVADO_SETUP_SCRIPT); \
export srcdir=$(srcdir); \
export tmp=$(TMP); \
export maxThreads=8
endef
endif

# Vivado from Xilinx provides IP handling, FPGA compilation
# hsi (hardware software interface) provides software integration
# both tools are run in batch mode with an option to avoid log/journal files
VIVADO = vivado -nolog -nojournal -mode batch
HSI    = hsi    -nolog -nojournal -mode batch

.PHONY: all clean project fpga bit fsbl dts

all: $(FPGA_BIT) $(FSBL_ELF) $(DEVICE_TREE)

clean:
	-rm -rf out .Xil .srcs sdk
	
project:
	( ${_envset}; \
	export system=${SYSTEM}; \
	vivado -source $(srcdir)/red_pitaya_vivado_project.tcl )

project_rp:
	( ${_envset}; \
	export system=rp_original.tcl; \
	vivado -source $(srcdir)/red_pitaya_vivado_project.tcl )

project_pwm:
	( ${_envset}; \
	export system=system_pwm.tcl; \
	vivado -source $(srcdir)/red_pitaya_vivado_project.tcl )

project_video:
	( ${_envset}; \
	export system=system-video.tcl; \
	vivado -source $(srcdir)/red_pitaya_vivado_project.tcl )

clean_project:
	-rm -rf project  vivado.jou  vivado.log  vivado_*.backup.jou  vivado_*.backup.log  vivado_pid*.str

update_project:
	cp -a $(builddir)/project/system.tcl $(srcdir)/ip/system.tcl

fpga bit: $(FPGA_BIT)

$(FPGA_BIT):
	( ${_envset}; \
	export system=${SYSTEM}; \
	$(VIVADO) -source $(srcdir)/red_pitaya_vivado.tcl )

fsbl: $(FSBL_ELF)

$(FSBL_ELF):  $(FPGA_BIT)
	${_envset}; \
	$(HSI) -source $(srcdir)/red_pitaya_hsi_fsbl.tcl

dts: $(DEVICE_TREE)

$(DEVICE_TREE):  $(FPGA_BIT)
	( ${_envset}; \
	export system=${SYSTEM}; \
	$(HSI) -source $(srcdir)/red_pitaya_hsi_dts.tcl )



################################################################################
# device tree processing
################################################################################

DTREE_TAG     = xilinx-v${VIVADO_VERSION}
DTREE_DIR     = $(TMP)/device-tree-xlnx-$(DTREE_TAG)
DTREE_URL    ?= https://github.com/Xilinx/device-tree-xlnx/archive/$(DTREE_TAG).tar.gz
DTREE_TAR     = $(DL)/device-tree-xlnx-$(DTREE_TAG).tar.gz


$(DL):
	mkdir -p $@

xlnx-devicetree: $(DTREE_DIR)


$(DTREE_TAR): | $(DL)
	curl -L $(DTREE_URL) -o $@

$(DTREE_DIR): $(DTREE_TAR)
	mkdir -p $@
	tar -zxf $< --strip-components=1 --directory=$@


