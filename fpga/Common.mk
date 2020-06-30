# ////////////////////////////////////////////////////////////////////////// //
#
# This file is part of the anacleto project.
# Copyright 2018 Andrea Rigoni Garola <andrea.rigoni@igi.cnr.it>.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# ////////////////////////////////////////////////////////////////////////// //



## ////////////////////////////////////////////////////////////////////////// ##
## ///  PROJECT HANDLE  ///////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

@PROJECT_VARIABLES@
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

project_LISTS = vivado_CORES \
				vivado_PROJECTS

project_VARIABLES = SOURCES \
					IP_SOURCES \
					BD_SOURCES \
					TB_SOURCES \
					PRJCFG \
					IPCFG \
					COMPILE_ORDER \
					DRV_LINUX \
					BSPDIR \
					ARCHIVE

project_DEFAULT := $(lastword $(patsubst _, ,$(current_dir)))

vivado_PROJECTS_TARGETS = project write_project write_bitstream \
						  new_project open_project bitstream clean_project \
						  dts dtb bsp
vivado_CORES_TARGETS    = core new_ip edit_ip clean_ip

FULL_NAME = $(if $(VENDOR),$(VENDOR)_)$(NAME)_$(VERSION)
ALL_NAMES = $(NAME) $(VENDOR)_$(NAME) $(NAME)_$(VERSION) $(FULL_NAME)

print: ##@debug print all names associated with this NAME
	@ echo " | NAMES   = $(ALL_NAMES)"; \
	  echo " | SOURCES = $(SOURCES)";   \
	  echo " | PRJCFG  = $(PRJCFG)";

## ////////////////////////////////////////////////////////////////////////// ##
## ///  CONFIGURATION   ///////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

define _envset
 . $(VIVADO_SETUP_SCRIPT); \
 . $(VIVADO_SDK_SETUP_SCRIPT)
endef

# Vivado from Xilinx provides IP handling, FPGA compilation hsi (hardware
# software interface) provides software integration both tools are run in batch
# mode with an option to save journal files
VIVADO       = vivado -nolog -journal $(NAME)_jou.tcl      $(if $(MODE),-mode $(MODE),-mode batch)
# VIVADO_SHELL = vivado -nolog -journal vivado_shell_jou.tcl $(if $(MODE),-mode $(MODE),-mode batch)
HSI          = hsi    -nolog -journal $(NAME)_hsi_jou.tcl  $(if $(MODE),-mode $(MODE),-mode batch)
# HSI_SHELL    = hsi    -nolog -journal hsi_shell_jou.tcl    $(if $(MODE),-mode $(MODE),-mode batch)
HLS          = vivado_hls -nosplash
# HLS_SHELL    = vivado_hls -nosplash
XSDK         = xsdk
# XSDK_SHELL   = xsdk -batch
# SDK_SHELL    = xsdk

vivado       = ${_envset}; $(VIVADO)       -source $(FPGA_DIR)/vivado_make.tcl $(if $1,-tclargs $1)
# vivado_shell = ${_envset}; $(VIVADO_SHELL) -source $(FPGA_DIR)/vivado_make.tcl $(if $1,-tclargs $1)
hsi          = ${_envset}; $(HSI)       -source $(FPGA_DIR)/vivado_make.tcl $(if $1,-tclargs $1)
# hsi_shell    = ${_envset}; $(HSI_SHELL) -source $(FPGA_DIR)/vivado_make.tcl $(if $1,-tclargs $1)
hls          = ${_envset}; $(HLS)       -f $(FPGA_DIR)/make_vivado_hls.tcl
# hls_shell    = ${_envset}; $(HLS_SHELL)
xsdk         = ${_envset}; $(XSDK)       $1
# xsdk_shell   = ${_envset}; $(XSDK_SHELL) $1
# sdk_shell    = ${_envset}; $(SDK_SHELL)

FPGA_DIR        = $(abs_top_srcdir)/fpga
FPGA_REPO_DIR   = $(abs_top_srcdir)/fpga/ip_repo
DTREE_DIR       = $(abs_top_builddir)/fpga/xlnx-devicetree
VIVADO_VERSION ?= 2015.4
maxThreads     ?= 6
COMPILE_ORDER  ?= auto

BOARD_PART      ?= $($(BOARD)_BOARD_PART)
BOARD_PRESET    ?= $($(BOARD)_BOARD_PRESET)
VIVADO_SOC_PART ?= $($(BOARD)_VIVADO_SOC_PART)

VIVADO_SRCDIR ?= $(srcdir)/prj/$(BOARD)
VIVADO_PRJDIR ?= $(builddir)/edit/$(BOARD)
VIVADO_BITDIR ?= $(builddir)/edit/$(BOARD)/$(FULL_NAME).bit
VIVADO_SDKDIR ?= $(builddir)/edit/$(BOARD)/$(FULL_NAME).sdk
VIVADO_IPDIR  ?= $(builddir)/ip/vivado

GHDL_IPDIR ?=

FPGA_BIT    = $(VIVADO_BITDIR)/$(FULL_NAME).bit
FSBL_ELF    = $(VIVADO_SDKDIR)/fsbl/executable.elf
DTS         = $(VIVADO_SDKDIR)/dts/devicetree.dts
DTB         = $(VIVADO_SDKDIR)/dts/devicetree.dtb

PRJCFG = 
IPCFG  = 

export XILINX_TCLAPP_REPO = $(abs_top_builddir)/fpga/tclapp
export XILINX_LOCAL_USER_DATA = NO

export srcdir \
	   top_srcdir \
	   builddir \
	   top_builddir \
	   maxThreads

export FPGA_DIR \
	   FPGA_BIT \
	   DTREE_DIR \
	   VIVADO_VERSION \
	   FPGA_REPO_DIR \
	   COMPILE_ORDER

export NAME \
	   BOARD \
	   BOARD_PART \
	   BOARD_PRESET \
	   VIVADO_SOC_PART \
	   VENDOR \
	   LIBRARY \
	   VERSION \
	   SOURCES \
	   BD_SOURCES \
	   IP_SOURCES \
	   TB_SOURCES \
	   PRJCFG \
	   IPCFG \
	   DRV_LINUX \
	   BSPDIR \
	   ARCHIVE

export VIVADO_SRCDIR \
	   VIVADO_PRJDIR \
	   VIVADO_BITDIR \
	   VIVADO_SDKDIR \
	   VIVADO_IPDIR


## ////////////////////////////////////////////////////////////////////////// ##
## ///  CORE BUILD      ///////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

# all: ## all steps for current project toward bitstream (bit) and device_tree (dtb)
# all-local: dtb

## ////////////////////////////////////////////////////////////////////////// ##
## ///  PROJECT DIRECTORIES  //////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

## HELP
projects:      ##@projects build all projects defined in vivado_PROJECTS variable
cores:         ##@cores build all cores defined in vivado_CORES variable



check_sources = $(SOURCES) \
				$(BD_SOURCES) \
				| $(filter-out $(ALL_NAMES),$(IP_SOURCES))

check_ip_componenents = $(foreach x,$(IP_SOURCES),$(VIVADO_IPDIR)/$x/component.xml)

check_prj_sources = $(shell $(FIND) $(VIVADO_SRCDIR)/$(FULL_NAME).{srcs,tcl} -printf "%p " 2>/dev/null || echo "") \
					$(shell $(FIND) $(VIVADO_PRJDIR)/$(FULL_NAME).srcs -printf "%p " 2>/dev/null || echo "")


project: $(VIVADO_PRJDIR)/$(FULL_NAME).xpr
projects: $(vivado_PROJECTS)

$(vivado_PROJECTS):
	@ $(MAKE) project NAME=$@

#$(VIVADO_SRCDIR)/%: $(VIVADO_PRJDIR)/% $(check_sources)
#	@ $(call vivado, write_project)

$(VIVADO_PRJDIR)/%.xpr: $(check_ip_componenents) $(check_sources)
	@ $(call vivado, open_project)


_core:
	$(MAKE) $(VIVADO_IPDIR)/$(FULL_NAME)/component.xml BOARD="vivado"

core:  $(vivado_CORES)
cores: $(vivado_CORES)

$(vivado_CORES):
	@ $(MAKE) _core NAME=$@

$(filter-out $(vivado_CORES),$(IP_SOURCES)):
	@ $(MAKE) -C $(@D) $(@F)

$(VIVADO_IPDIR)/%/component.xml: $(SOURCES) #$(check_sources) < not supported
	@ $(if $(filter %.cpp,${SOURCES}),\
		   $(call hls, package_hls_ip),\
		   $(call vivado, package_ip))



## ////////////////////////////////////////////////////////////////////////// ##
## ///  PROJECT LIST  /////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

NODOCKERBUILD += list print_banner board_info

list: ##@projects list all projects defined in vivado_PROJECTS variable
list: ##@cores list all projects defined in vivado_PROJECTS variable
list : _item = $(foreach x,$($1),$(info |  - $x))
list: print_banner
	@ \
	$(info ,-----------------------------------------------------------------) \
	$(info | projects and cores defined ) \
	$(info |) \
	$(info | CORES: ) \
	$(call _item,vivado_CORES) \
	$(info |) \
	$(info | PROJECTS: ) \
	$(call _item,vivado_PROJECTS) \
	$(info |) \
	$(info | ENABLED_BOARDS: ) \
	$(call _item,ENABLED_BOARDS) \
	$(info |) \
	$(info | CURRENT: $(NAME)   [on $(BOARD)]) \
	$(info |) \
	$(info `-----------------------------------------------------------------) :


board_info: ##@miscellaneous show board information
board_info: print_banner
	@ \
	$(info ,-----------------------------------------------------------------) \
	$(info | Board: $(BOARD) ) \
	$(info |) \
	$(info | BOARD_PART: $(BOARD_PART) ) \
	$(info | BOARD_PRESET: $(BOARD_PRESET) ) \
	$(info | VIVADO_SOC_PART: $(VIVADO_SOC_PART) ) \
	$(info |) \
	$(info `-----------------------------------------------------------------) :


## ////////////////////////////////////////////////////////////////////////// ##
## ///  VIVADO SHELL    ///////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

.PHONY: vivado_shell hsi_shell xsdk_shell
vivado_shell:##@@xilinx open a vivado shell with configured env
hsi_shell:   ##@@xilinx open hsi shell with configured env
hls_shell:   ##@@xilinx open hls shell with configured env
xsdk_shell:  ##@@xilinx open xsdk shell with configured env
sdk_shell:   ##@@xilinx open sdk shell with configured env

%_shell: export MODE = tcl
vivado vivado_shell hsi hsi_shell hls hls_shell xsdk_shell sdk_shell: 
vivado vivado_shell hsi hsi_shell hls hls_shell xsdk_shell sdk_shell:
	@ $(call $@,${TCL_ARGS})


## ////////////////////////////////////////////////////////////////////////// ##
## ///  VIVADO PROJECT  ///////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

new_project:   print_banner ##@projects Create a new vivado project
open_project:  print_banner ##@projects Open the current project
write_project: print_banner ##@projects Store the current project
bitstream:     print_banner ##@projects generate bitstream

package_ip:   ##@cores create a new pheripheral project for edit.
edit_ip:      ##@cores open project ip or edit existing project as a new ip.

write_project write_bitstream package_ip: $(check_sources)
	@ $(call vivado,$@)

.PHONY: open_project edit_ip
new_project open_project: export MODE = gui
new_project open_project: $(check_sources)
	@ $(call vivado,$@)

edit_ip: export MODE = gui
edit_ip: $(check_sources)
	@ $(if $(filter %.cpp,${SOURCES}),\
		   ${_envset}; $(HLS) -p $(VIVADO_PRJDIR)/$(FULL_NAME),\
		   $(call vivado,$@))


## ////////////////////////////////////////////////////////////////////////// ##
## ///  BITSTREAM  ////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

bitstream: $(FPGA_BIT)

$(FPGA_BIT): $(check_prj_sources) $(check_ip_componenents) $(check_sources)
	$(MAKE) write_bitstream


## ////////////////////////////////////////////////////////////////////////// ##
## ///  FSBL  /////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

.PHONY: fsbl
fsbl: $(FSBL_ELF)

$(FSBL_ELF): $(FPGA_BIT)
	@ $(call hsi,write_fsbl)


## ////////////////////////////////////////////////////////////////////////// ##
## ///  DEVICE TREEE  /////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

.PHONY: dts dtb
dts: ##@hsi compile device tree source file
	$(MAKE) $(DTS)
dtb: ##@hsi compile device tree binary
	$(MAKE) $(DTB)


$(VIVADO_SDKDIR)/dts/$(SYSTEM_DTS):  $(FPGA_BIT)
	@ $(MAKE) -C $(top_builddir)/fpga xlnx-devicetree; \
	  $(call hsi,write_devicetree)

$(LINUX_IMAGE):
	$(MAKE) $(AM_MAKEFLAGS) -C $(top_builddir) $@

$(DTS): $(VIVADO_SDKDIR)/dts/$(SYSTEM_DTS) $(LINUX_IMAGE)
	$(LINUX_BUILDDIR)/scripts/dtc/dtc -I dts -O dts -o $@ -i $(<D) $<

$(DTB):  $(DTS) $(LINUX_IMAGE)
	$(LINUX_BUILDDIR)/scripts/dtc/dtc -I dts -O dtb -o $@ -i $(<D) $<

bsp: ##@hsi write linux drivers template (MEN AT WORK HERE !!)
bsp: # dts
	@ $(call hsi,write_linux_bsp)


## ////////////////////////////////////////////////////////////////////////// ##
## ///  TEST     //////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

print_name:
	@ echo "nam=$(NAME) ven=$(VENDOR) ver=$(VERSION) ful=$(FULL_NAME)"; echo ""

autotest_name:
	$(MAKE) print_name
	NAME=$(lastword $(vivado_CORES))    $(MAKE) print_name
	NAME=$(lastword $(vivado_PROJECTS)) $(MAKE) print_name
	VENDOR=pven NAME=pnam VERSION=5.55  $(MAKE) print_name
	VENDOR=pven NAME=pnam pnam_VERSION=5.55      $(MAKE) print_name
	VENDOR=pven NAME=pnam pven_pnam_VERSION=5.55 $(MAKE) print_name
	VENDOR=pven NAME=pven_pnam       $(MAKE) print_name
	VENDOR=pven NAME=pven_pnam_5.55  $(MAKE) print_name

vivado-bash: ##@@xilinx vivado env bash
	@ ${_envset}; \
	  /bin/bash


## ////////////////////////////////////////////////////////////////////////// ##
## ///  CLEAN  ////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

clean-local::
	-rm -rf .Xil .srcs webtalk_* *jou*.tcl \
	 vivado.jou  vivado.log  \
	 vivado_*.backup.jou  vivado_*.backup.log  vivado_pid*.str \
	 webtalk.jou  webtalk.log  \
	 webtalk_*.backup.jou  webtalk_*.backup.log vivado_hls.log

.PHONY: clean_project
clean_project: ##@projects Clean all build project files from disk
	@- rm -rf $(VIVADO_PRJDIR)/$(FULL_NAME){.,_}*

.PHONY: clean_ip
clean_ip: ##@cores Clean all built core files from disk
	@- rm -rf $(VIVADO_IPDIR)/${FULL_NAME} \
			  $(VIVADO_PRJDIR)/$(FULL_NAME){.,_}*


clean-all: ## perform all clean operations (ip, project, general)
clean-all: clean-local clean_project clean_ip
	@- $(foreach x,$(vivado_PROJECTS),$(info clean in project: $x)$(MAKE) clean_project NAME=$x;)
	@- $(foreach x,$(vivado_CORES),$(info clean in core: $x)$(MAKE) clean_ip NAME=$x;)

## ////////////////////////////////////////////////////////////////////////// ##
## ///  DEPLOY  ///////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

.PHONY: deploy
deploy: ##@projects Copy all files to target device
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
deploy_fpga: ##@projects Start generated bitstream in target device
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



## ////////////////////////////////////////////////////////////////////////////////
## //  GHDL  //////////////////////////////////////////////////////////////////////
## ////////////////////////////////////////////////////////////////////////////////


GHDL_BINARY  = ghdl
GHDL_WORK   ?= work
GHDL_FLAGS   = --ieee=synopsys --warn-no-vital-generic
GHDL_STOP_TIME ?= 100us

define _rename =
$(info overriding with $(1))
override SOURCES = $$($(1)_SOURCES)
override TB_SOURCES = $$($(1)_TB_SOURCES)
override GHDL_WORK = $(1)_ghdl
endef


VHDL_OBJECTS = $(SOURCES:.vhdl=.o) $(SOURCES:.vhd=.o) \
               $(TB_SOURCES:.vhdl=.o) $(TB_SOURCES:.vhd=.o)

.vhd.o .vhdl.o:
	@ $(GHDL_BINARY) -a $(GHDL_FLAGS) --workdir=$(builddir) --work=$(GHDL_WORK) $<

ghdl-%: GHDL_WORK=$(NAME)_ghdl
ghdl-%: SOURCES:=$(filter %.vhdl %.vhd,$(SOURCES)) \
        TB_SOURCES:=$(filter %.vhdl %.vhd,$(TB_SOURCES))

ghdl-core: ##@@ghdl compile core in NAME identified by UNIT
ghdl-core: $(VHDL_OBJECTS)
	@ $(GHDL_BINARY) -m $(GHDL_FLAGS) --workdir=$(builddir) --work=$(GHDL_WORK) \
	  $(UNIT) $(ARCHITECTURE)

ghdl-list: ##@@ghdl list ghdl defined modules
ghdl-list: $(VHDL_OBJECTS)
	@ $(GHDL_BINARY) -d $(GHDL_FLAGS) --workdir=$(builddir) --work=$(GHDL_WORK)


ghdl-wave: ##@@ghdl show ghdl wave
ghdl-wave: $(UNIT).vcd
	@ gtkwave $^

.PHONY: $(UNIT).vcd
$(UNIT).vcd: $(UNIT)
	@ $(GHDL_BINARY) -r $(GHDL_FLAGS) --workdir=$(builddir) --work=$(GHDL_WORK) \
	  $(UNIT) $(ARCHITECTURE) --vcd=$(UNIT).vcd \
		$(if $(GHDL_STOP_TIME),--stop-time=$(GHDL_STOP_TIME))

ghdl-run: ##@@ghdl run ghdl compiled code
ghdl-run: $(UNIT).vcd



$($(NAME)_UNITS):
	@ $(MAKE) ghdl-core UNIT=$@

ghdl-clean:: ##@@ghdl clean ghdl files
ghdl-clean::
	@ ghdl --clean --workdir=$(builddir) --work=$(GHDL_WORK)
	@ ghdl --remove --workdir=$(builddir) --work=$(GHDL_WORK)




























