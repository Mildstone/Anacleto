
include $(top_srcdir)/Common.am




# Vivado from Xilinx provides IP handling, FPGA compilation
# hsi (hardware software interface) provides software integration
# both tools are run in batch mode with an option to avoid log/journal files
VIVADO = vivado -nolog -nojournal -mode batch
HSI    = hsi    -nolog -nojournal -mode batch



SOC_BOARD       ?= red_pitaya
VIVADO_VERSION  ?= 2015.4
VIVADO_SOC_PART ?= xc7z010clg400-1


SYSTEM    ?= ${SOC_BOARD}_${VIVADO_VERSION}
FPGA_SDC  ?= ${SYSTEM}.xdc
FPGA_BIT  ?= out/${SYSTEM}.bit

FSBL_ELF   = sdk/fsbl/executable.elf
DTS        = sdk/dts/devicetree.dts
DTB        = sdk/dts/devicetree.dtb


define _envset
. $(VIVADO_SETUP_SCRIPT); \
export srcdir=$(srcdir); \
export top_srcdir=$(top_srcdir); \
export tmp=$(TMP); \
export FPGA_REPO_DIR=${FPGA_REPO_DIR}; \
export SYSTEM=${SYSTEM}; \
export FPGA_SDC=${FPGA_SDC}; \
export FPGA_BIT=${FPGA_BIT}; \
export SOC_BOARD=${SOC_BOARD}; \
export VIVADO_VERSION=${VIVADO_VERSION}; \
export VIVADO_SOC_PART=${VIVADO_SOC_PART}; \
export maxThreads=8
endef


.PHONY: all clean project fpga bit fsbl dts dtb

all: $(FPGA_BIT) $(DTB)

clean:
	-rm -rf out .Xil .srcs sdk
	

## ////////////////////////////////////////////////////////////////////////// ##
## ///  VIVADO PROJECT  ///////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

project:
	( ${_envset}; \
	vivado -source $(FPGA_DIR)/red_pitaya_vivado_project.tcl )

clean_project:
	-rm -rf project  vivado.jou  vivado.log  \
		vivado_*.backup.jou  vivado_*.backup.log  vivado_pid*.str \
		webtalk.jou  webtalk.log  \
		webtalk_*.backup.jou  webtalk_*.backup.log

update_project:
	cp -a $(builddir)/project/system.tcl $(srcdir)/${SYSTEM}.tcl



## ////////////////////////////////////////////////////////////////////////// ##
## ///  BITSTREAM  ////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

fpga bit: $(FPGA_BIT)

$(FPGA_BIT):
	( ${_envset}; \
	  $(VIVADO) -source $(FPGA_DIR)/red_pitaya_vivado.tcl )


## ////////////////////////////////////////////////////////////////////////// ##
## ///  FSBL  /////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

fsbl: $(FSBL_ELF)

$(FSBL_ELF):  $(FPGA_BIT)
	${_envset}; \
	$(HSI) -source $(FPGA_DIR)/red_pitaya_hsi_fsbl.tcl



## ////////////////////////////////////////////////////////////////////////// ##
## ///  DEVICE TREEE  /////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

dts: $(DTS)
dtb: $(DTB)

xlnx-devicetree:
	$(MAKE) -C $(top_builddir) xlnx-devicetree

sdk/dts/system.dts:  $(FPGA_BIT) xlnx-devicetree
	( ${_envset}; \
	  $(HSI) -source $(FPGA_DIR)/red_pitaya_hsi_dts.tcl )

$(DTS): sdk/dts/system.dts $(LINUX_IMAGE)
	$(LINUX_BUILDDIR)/scripts/dtc/dtc -i sdk/dts/ sdk/dts/system.dts > $@

$(DTB):  $(DTS) $(LINUX_IMAGE)
	$(LINUX_BUILDDIR)/scripts/dtc/dtc -I dts -O dtb -o $@ -i sdk/dts/ $<



## ////////////////////////////////////////////////////////////////////////// ##
## ///  DEPLOY  ///////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

.PHONY: deploy
deploy: $(FPGA_BIT) $(LINUX_IMAGE) $(DTB)
if WITH_DEVICE_SSHKEY
	@ echo " --- deploying to target device: ${DEVICE_NAME} using key ---";
	scp -i $(DEVICE_SSHKEY) $^ \
	  $(DEVICE_USER)@$(DEVICE_IP):$(DEVICE_INSTALL_DIR);
else
if WITH_DEVICE_SSHPASSWD
	@ echo " --- deploying to target device: ${DEVICE_NAME} using passwd ---";
	sshpass -p ${DEVICE_PASSWD} scp $^ \
	  $(DEVICE_USER)@$(DEVICE_IP):$(DEVICE_INSTALL_DIR);
endif
endif

.PHONY: deploy_fpga
deploy_fpga: $(FPGA_BIT)
	@ echo ""; \
	  echo " WARNING: This will reprogram fpga without setting devicetree and kernel "
if WITH_DEVICE_SSHKEY
	@ echo " --- deploying to target device: ${DEVICE_NAME} using key ---";
	scp -i $(DEVICE_SSHKEY) $^ \
	  $(DEVICE_USER)@$(DEVICE_IP):/tmp/fpga.bit; \
	ssh -i $(DEVICE_SSHKEY) $(DEVICE_USER)@$(DEVICE_IP) "cat /tmp/fpga.bit > /dev/xdevcfg";
else
if WITH_DEVICE_SSHPASSWD
	@ echo " --- deploying to target device: ${DEVICE_NAME} using passwd ---";
	sshpass -p ${DEVICE_PASSWD} scp $^ \
	  $(DEVICE_USER)@$(DEVICE_IP):/tmp; \
	sshpass -p ${DEVICE_PASSWD} \
	  ssh $(DEVICE_USER)@$(DEVICE_IP) "cat /tmp/fpga.bit > /dev/xdevcfg";
endif
endif



