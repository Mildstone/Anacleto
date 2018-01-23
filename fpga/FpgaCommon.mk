

##
##  __     __   __   __       ___              ___  __
## |  \ | /__` /  ` /  \ |\ |  |  | |\ | |  | |__  |  \
## |__/ | .__/ \__, \__/ | \|  |  | | \| \__/ |___ |__/
##
##
# $(error "This Makefile include has been discontinued, use fpga/Common.mk")


mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
default_project_name := $(lastword $(patsubst _, ,$(current_dir)))
NAME ?= $(or $(if $(filter $(IP_TARGETS),$(MAKECMDGOALS)),$(lastword $(vivado_CORES))),\
			 $(if $(filter $(PRJ_TARGETS),$(MAKECMDGOALS)),$(lastword $(vivado_PROJECTS))),\
			 $(default_project_name))

PRJ_TARGETS = write_project write_bitstream new_project open_project bitstream
IP_TARGETS  = new_ip edit_ip


# Vivado from Xilinx provides IP handling, FPGA compilation
# hsi (hardware software interface) provides software integration
# both tools are run in batch mode with an option to avoid log/journal files
VIVADO       = vivado -nolog -journal $(NAME)_jou.tcl      -mode batch
VIVADO_SHELL = vivado -nolog -journal vivado_shell_jou.tcl -mode tcl
HSI          = hsi    -nolog -journal $(NAME)_hsi_jou.tcl  -mode batch
HSI_SHELL    = hsi    -nolog -journal hsi_shell_jou.tcl    -mode tcl
HLS          = vivado_hls -nosplash
HLS_SHELL    = vivado_hls -nosplash -i
XSDK         = xsdk
XSDK_SHELL   = xsdk -batch

vivado       = $(VIVADO)       -source $(FPGA_DIR)/vivado_make.tcl $(if $1,-tclargs $1)
vivado_shell = $(VIVADO_SHELL) -source $(FPGA_DIR)/vivado_make.tcl $(if $1,-tclargs $1)
hsi          = $(HSI)       -source $(FPGA_DIR)/vivado_make.tcl $(if $1,-tclargs $1)
hsi_shell    = $(HSI_SHELL) -source $(FPGA_DIR)/vivado_make.tcl $(if $1,-tclargs $1)
hls          = $(HLS)       -f $(FPGA_DIR)/vivado_make.tcl  $(if $1,-tclargs $1)
hls_shell    = $(HLS_SHELL) -f $(FPGA_DIR)/vivado_make.tcl  $(if $1,-tclargs $1)
xsdk         = $(XSDK)       $(if $1,-tclargs $1)
xsdk_shell   = $(XSDK_SHELL) -batch $(if $1,-tclargs $1)

FPGA_DIR        = $(abs_top_srcdir)/fpga
FPGA_REPO_DIR   = $(abs_top_srcdir)/fpga/ip_repo
DTREE_DIR      ?= $(abs_top_builddir)/fpga/device-tree-xlnx-${VIVADO_VERSION}
VIVADO_VERSION ?= 2015.4
maxThreads     ?= 6

## NOT USED YET
COMPILE_ORDER  ?= auto

define _envset
 . $(VIVADO_SETUP_SCRIPT); \
 . $(VIVADO_SDK_SETUP_SCRIPT)
endef

export srcdir \
	   top_srcdir \
	   builddir \
	   top_builddir \
	   maxThreads

export FPGA_DIR \
	   FPGA_BIT \
	   DTREE_DIR \
	   VIVADO_VERSION \
	   VIVADO_SOC_PART \
	   FPGA_REPO_DIR \
	   COMPILE_ORDER

export NAME \
	   BOARD \
	   VENDOR \
	   LIBRARY \
	   VERSION \
	   SOURCES \
	   BD_SOURCES \
	   IP_SOURCES

bash:
	@ ${_envset}; \
	  /bin/bash


## ////////////////////////////////////////////////////////////////////////// ##
## ///  CORE BUILD      ///////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

VIVADO_SRCDIR ?= $(srcdir)/prj/$(BOARD)
VIVADO_PRJDIR ?= $(builddir)/edit/$(BOARD)
VIVADO_BITDIR ?= $(builddir)/edit/$(BOARD)/$(call _ful,$(NAME)).bit
VIVADO_SDKDIR ?= $(builddir)/edit/$(BOARD)/$(call _ful,$(NAME)).sdk
VIVADO_IPDIR  ?= $(builddir)/ip/vivado

export VIVADO_SRCDIR \
	   VIVADO_PRJDIR \
	   VIVADO_BITDIR \
	   VIVADO_SDKDIR \
	   VIVADO_IPDIR

FPGA_BIT    = $(VIVADO_BITDIR)/$(call _ful,$(NAME)).bit
FSBL_ELF    = $(VIVADO_SDKDIR)/fsbl/executable.elf
DTS         = $(VIVADO_SDKDIR)/dts/devicetree.dts
DTB         = $(VIVADO_SDKDIR)/dts/devicetree.dtb

_flt = $(subst ' ',_,$(subst .,_,$1))

_ven = $(or ${VENDOR},\
			${$(call _flt,$1)_VENDOR})

_ver = $(or $(filter-out ${PACKAGE_VERSION},${VERSION}),\
			${$(call _ven,$1)_$(call _flt,$1)_VERSION},\
			${$(call _flt,$1)_VERSION},\
			${$(subst $(call _ven,$1)_,,$1)_VERSION},\
			$(shell echo $(lastword $(subst _, ,$1)) | \
			  $(SED) 's/[^0-9.]*\([0-9.]*\).*/\1/'),\
			${VERSION})

_nam = $(subst $(call _ven,$1)_,,$(subst _$(call _ver,$1),,$1))
_ful = $(call _ven,$1)_$(call _nam,$1)_$(call _ver,$1)
_var = $(or $($(call _flt,$(call _ven,$1)_$(call _nam,$1)_$(call _ver,$1)_$2)),\
			$($(call _flt,$(call _nam,$1)_$(call _ver,$1)_$2)),\
			$($(call _flt,$(call _ven,$1)_$(call _nam,$1)_$2)),\
			$($(call _flt,$(call _nam,$1)_$2)))

_p_set = $(if $1, NAME="$(call _nam,$1)" \
				  VENDOR="$(call _ven,$1)" \
				  VERSION="$(call _ver,$1)" \
				  SOURCES="$(call _var,$1,SOURCES)" \
				  BD_SOURCES="$(call _var,$1,BD_SOURCES)" \
				  IP_SOURCES="$(call _var,$1,IP_SOURCES)" \
				  DRV_LINUX="$(call _var,$1,DRV_LINUX)"   \
				  CMPILE_ORDER="$(call _var,$1,COMPILE_ORDER)"  \
				  , $(if $2,$(call _p_set,$2), NAME="$(default_project_name)") )


## ////// TEST NAMES //////////////////////////////////////////////////////// ##
print_name:
	@ echo "$(call _p_set,${NAME})"; echo ""

autotest_name:
	$(MAKE) -e print_name
	NAME=$(lastword $(vivado_CORES)) $(MAKE) -e print_name
	NAME=$(lastword $(vivado_PROJECTS)) $(MAKE) -e print_name
	VENDOR=pven NAME=pnam VERSION=5.55 $(MAKE) -e print_name
	VENDOR=pven NAME=pnam pnam_VERSION=5.55 $(MAKE) -e print_name
	VENDOR=pven NAME=pnam pven_pnam_VERSION=5.55 $(MAKE) -e print_name
	VENDOR=pven NAME=pven_pnam       $(MAKE) -e print_name
	VENDOR=pven NAME=pven_pnam_5.55  $(MAKE) -e print_name


## ////////////////////////////////////////////////////////////////////////// ##
## ///  TARGET DIRECTORIES  ///////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

all-local: $(vivado_CORES)

## HELP
projects:      ##@projects build all projects defined in vivado_PROJECTS variable
cores:         ##@cores build all cores defined in vivado_CORES variable
list_projects: ##@projects list all projects defined in vivado_PROJECTS variable
list_cores:    ##@cores list all projects defined in vivado_PROJECTS variable

check_sources: print_banner $(SOURCES) $(BD_SOURCES) $(IP_SOURCES)

$(vivado_PROJECTS):
	@ $(MAKE) $(VIVADO_PRJDIR)/$(call _ful,$@).xpr $(call _p_set,$@)

$(VIVADO_SRCDIR)/%: $(VIVADO_PRJDIR)/% $(SOURCES) $(BD_SOURCES) $(IP_SOURCES)
	@ ${_envset}; \
	  $(call vivado, write_project)

$(VIVADO_PRJDIR)/%.xpr: $(SOURCES) $(BD_SOURCES) $(IP_SOURCES)
	@ ${_envset}; \
	  $(call vivado, open_project)

projects: $(vivado_PROJECTS)

list_projects:
	@ \
	 $(call _p_set,${NAME}) \
	 test -f $(VIVADO_SRCDIR)/$${VENDOR}_$${NAME}_$${VERSION}.tcl -o\
		  -f $(VIVADO_PRJDIR)/$${VENDOR}_$${NAME}_$${VERSION}.xpr -o\
		  -f $(VIVADO_SRCDIR)/$${NAME}_$${VERSION}.tcl -o\
		  -f $(VIVADO_PRJDIR)/$${NAME}_$${VERSION}.xpr \
			&& echo $${NAME}; \
	 echo $(vivado_PROJECTS)


$(vivado_CORES):
	@ $(MAKE) $(VIVADO_IPDIR)/$(call _ful,$@)/component.xml \
	  BOARD="vivado" $(call _p_set,$@)

$(filter-out $(vivado_CORES),$(IP_SOURCES)):
	@ $(MAKE) -C $(@D) $(@F)

$(VIVADO_IPDIR)/%/component.xml: $(SOURCES) $(BD_SOURCES) $(IP_SOURCES)
	@ ${_envset}; \
	  $(call vivado, package_ip)

cores: $(vivado_CORES)

list_cores:
	@ echo $(vivado_CORES)


## ////////////////////////////////////////////////////////////////////////// ##
## ///  VIVADO SHELL    ///////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

.PHONY: vivado_shell hsi_shell
vivado_shell:##@xilinx open a vivado shell with configured env
hsi_shell:   ##@xilinx open hsi shell with configured env
hls_shell:   ##@xilinx open hls shell with configured env
xsdk_shell:  ##@xilinx open xsdk shell with configured env

vivado hsi vivado_shell hsi_shell hls hls_shell:
	@ ${_envset}; $(call $@,${TCL_ARGS})


## ////////////////////////////////////////////////////////////////////////// ##
## ///  VIVADO PROJECT  ///////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

new_project:   ##@projects Create a new vivado project
open_project:  ##@projects Open the current project
write_project: ##@projects Store the current project
write_bitstream:  ##@projects generate bitstream

package_ip:   ##@cores create a new pheripheral project for edit.
edit_ip:  ##@cores open all module pheripherals projects for edit.

new_project write_project write_bitstream package_ip:
	@ ${_envset}; \
	  $(MAKE) check_sources vivado TCL_ARGS=$@ $(call _p_set,$(NAME))

.PHONY: open_project edit_ip

open_project edit_ip: $(NAME)
	@ ${_envset}; \
	  $(MAKE) check_sources vivado_shell TCL_ARGS=$@ $(call _p_set,$(NAME))


## ////////////////////////////////////////////////////////////////////////// ##
## ///  BITSTREAM  ////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

.PHONY: bitstream
bitstream: $(FPGA_BIT)

$(FPGA_BIT): $(NAME) check_sources
	$(MAKE) write_bitstream $(call _p_set,$(NAME))



## ////////////////////////////////////////////////////////////////////////// ##
## ///  FSBL  /////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

.PHONY: fsbl
fsbl: $(FSBL_ELF)

$(FSBL_ELF):  $(FPGA_BIT)
	@ ${_envset}; \
	  $(call _p_set,$(NAME)) \
	  $(HSI) -source $(FPGA_DIR)/vivado_make.tcl -tclargs write_fsbl



## ////////////////////////////////////////////////////////////////////////// ##
## ///  DEVICE TREEE  /////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

.PHONY: dts dtb
dts: ##@hsi compile device tree source file
	$(MAKE) $(DTS) $(call _p_set,$(NAME))
dtb: ##@hsi compile device tree binary
	$(MAKE) $(DTB) $(call _p_set,$(NAME))


$(VIVADO_SDKDIR)/dts/$(SYSTEM_DTS):  $(FPGA_BIT)
	@ $(MAKE) -C $(top_builddir)/fpga xlnx-devicetree; \
	  ${_envset}; \
	  $(HSI) -source $(FPGA_DIR)/vivado_make.tcl -tclargs write_devicetree

$(DTS): $(VIVADO_SDKDIR)/dts/$(SYSTEM_DTS) $(LINUX_IMAGE)
	$(LINUX_BUILDDIR)/scripts/dtc/dtc -I dts -O dts -o $@ -i sdk/dts/ $<

$(DTB):  $(DTS) $(LINUX_IMAGE)
	$(LINUX_BUILDDIR)/scripts/dtc/dtc -I dts -O dtb -o $@ -i sdk/dts/ $<




## ////////////////////////////////////////////////////////////////////////// ##
## ///  CLEAN  ////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

.PHONY: clean_project
clean_project: ##@projects Clean all build project files from disk (make write_project before this)
	@- ${_envset}; \
	  $(call _p_set,$(NAME)) \
	  rm -rf $(VIVADO_IPDIR)/${NAME} \
			 $(VIVADO_PRJDIR)/$(NAME).* \
			 vivado.jou  vivado.log  \
			 vivado_*.backup.jou  vivado_*.backup.log  vivado_pid*.str \
			 webtalk.jou  webtalk.log  \
			 webtalk_*.backup.jou  webtalk_*.backup.log


## ////////////////////////////////////////////////////////////////////////// ##
## ///  DEPLOY  ///////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

.PHONY: deploy
deploy: ##@miscellaneous Copy all files to target device
deploy: $(FPGA_BIT) $(LINUX_IMAGE) $(DTB)
if WITH_DEVICE_SSHKEY
	@ echo " --- deploying to target device: ${DEVICE_NAME} using key ---";
	scp -i $(DEVICE_SSHKEY) $^ \
	  $(DEVICE_USER)@$(DEVICE_IP):$(DEVICE_BOOT_DIR);
else
if WITH_DEVICE_SSHPASSWD
	@ echo " --- deploying to target device: ${DEVICE_NAME} using passwd ---";
	sshpass -p ${DEVICE_PASSWD} scp $^ \
	  $(DEVICE_USER)@$(DEVICE_IP):$(DEVICE_BOOT_DIR);
else
	@ echo "none of sshpass command or configured ssh key was found"
endif
endif

.PHONY: deploy_fpga
deploy_fpga: ##@miscellaneous Start generated bitstream in target device
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
else
	@ echo "none of sshpass command or configured ssh key was found"
endif
endif

