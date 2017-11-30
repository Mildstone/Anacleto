
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
					PRJCFG \
					IPCFG \
					BOARD_PART \
					BOARD_PRESET \
					COMPILE_ORDER

project_DEFAULT := $(lastword $(patsubst _, ,$(current_dir)))

vivado_PROJECTS_TARGETS = project write_project write_bitstream \
						  new_project open_project bitstream clean_project \
						  dts dtb
vivado_CORES_TARGETS    = core new_ip edit_ip clean_ip

FULL_NAME = $(if $(VENDOR),$(VENDOR)_)$(NAME)_$(VERSION)
ALL_NAMES = $(NAME) $(VENDOR)_$(NAME) $(NAME)_$(VERSION) $(FULL_NAME)


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
VIVADO       = vivado -nolog -journal $(NAME)_jou.tcl      -mode batch
VIVADO_SHELL = vivado -nolog -journal vivado_shell_jou.tcl $(if $(MODE),-mode $(MODE))
HSI          = hsi    -nolog -journal $(NAME)_hsi_jou.tcl  -mode batch
HSI_SHELL    = hsi    -nolog -journal hsi_shell_jou.tcl    $(if $(MODE),-mode $(MODE))
HLS          = vivado_hls -nosplash
HLS_SHELL    = vivado_hls -nosplash -i

vivado       = ${_envset}; $(VIVADO)       -source $(FPGA_DIR)/vivado_make.tcl $(if $1,-tclargs $1)
vivado_shell = ${_envset}; $(VIVADO_SHELL) -source $(FPGA_DIR)/vivado_make.tcl $(if $1,-tclargs $1)
hsi          = ${_envset}; $(HSI)       -source $(FPGA_DIR)/vivado_make.tcl $(if $1,-tclargs $1)
hsi_shell    = ${_envset}; $(HSI_SHELL) -source $(FPGA_DIR)/vivado_make.tcl $(if $1,-tclargs $1)
hls          = ${_envset}; $(HLS)       -f $(FPGA_DIR)/make_vivado_hls.tcl
hls_shell    = ${_envset}; $(HLS_SHELL) -f $(FPGA_DIR)/vivado_make.tcl

FPGA_DIR        = $(abs_top_srcdir)/fpga
FPGA_REPO_DIR   = $(abs_top_srcdir)/fpga/ip_repo
DTREE_DIR      ?= $(abs_top_builddir)/fpga/device-tree-xlnx-${VIVADO_VERSION}
VIVADO_VERSION ?= 2015.4
maxThreads     ?= 6
COMPILE_ORDER  ?= auto

VIVADO_SRCDIR ?= $(srcdir)/prj/$(BOARD)
VIVADO_PRJDIR ?= $(builddir)/edit/$(BOARD)
VIVADO_BITDIR ?= $(builddir)/edit/$(BOARD)/$(FULL_NAME).bit
VIVADO_SDKDIR ?= $(builddir)/edit/$(BOARD)/$(FULL_NAME).sdk
VIVADO_IPDIR  ?= $(builddir)/ip/vivado

FPGA_BIT    = $(VIVADO_BITDIR)/$(FULL_NAME).bit
FSBL_ELF    = $(VIVADO_SDKDIR)/fsbl/executable.elf
DTS         = $(VIVADO_SDKDIR)/dts/devicetree.dts
DTB         = $(VIVADO_SDKDIR)/dts/devicetree.dtb

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
	   VIVADO_SOC_PART \
	   FPGA_REPO_DIR \
	   COMPILE_ORDER

export NAME \
	   BOARD \
	   BOARD_PART \
	   BOARD_PRESET \
	   VENDOR \
	   LIBRARY \
	   VERSION \
	   SOURCES \
	   BD_SOURCES \
	   IP_SOURCES \
	   PRJCFG \
	   IPCFG

export VIVADO_SRCDIR \
	   VIVADO_PRJDIR \
	   VIVADO_BITDIR \
	   VIVADO_SDKDIR \
	   VIVADO_IPDIR


## ////////////////////////////////////////////////////////////////////////// ##
## ///  CORE BUILD      ///////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##


all-local: $(vivado_CORES) $(vivado_PROJECTS)



## ////////////////////////////////////////////////////////////////////////// ##
## ///  PROJECT DIRECTORIES  //////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

## HELP
projects:      ##@projects build all projects defined in vivado_PROJECTS variable
cores:         ##@cores build all cores defined in vivado_CORES variable

check_sources = $(SOURCES) \
				$(BD_SOURCES) \
				| $(filter-out $(ALL_NAMES),$(IP_SOURCES))

check_ip_componenents = $(foreach x,$(filter-out $(ALL_NAMES),$(IP_SOURCES)),$(VIVADO_IPDIR)/$x/component.xml)

check_prj_sources = $(shell $(FIND) $(VIVADO_SRCDIR)/$(FULL_NAME).{srcs,tcl} -printf "%p " 2>/dev/null || echo "") \
					$(shell $(FIND) $(VIVADO_PRJDIR)/$(FULL_NAME).srcs -printf "%p " 2>/dev/null || echo "")


project: $(VIVADO_PRJDIR)/$(FULL_NAME).xpr
projects: $(vivado_PROJECTS)


print:
	@ echo $(BOARD_PRESET) $(BOARD_PART)

$(vivado_PROJECTS):
	@ $(MAKE) project NAME=$@

#$(VIVADO_SRCDIR)/%: $(VIVADO_PRJDIR)/% $(check_sources)
#	@ $(call vivado, write_project)

$(VIVADO_PRJDIR)/%.xpr: $(check_ip_componenents) $(check_sources)
	@ $(call vivado, open_project)


core:
	$(MAKE) $(VIVADO_IPDIR)/$(FULL_NAME)/component.xml BOARD="vivado"

cores: $(vivado_CORES)

$(vivado_CORES):
	@ $(MAKE) core NAME=$@

$(filter-out $(vivado_CORES),$(IP_SOURCES)):
	@ $(MAKE) -C $(@D) $(@F)

$(VIVADO_IPDIR)/%/component.xml: $(check_sources)
	@ $(if $(filter %.cpp,${SOURCES}),\
		   $(call hls, package_hls_ip),\
		   $(call vivado, package_ip))



## ////////////////////////////////////////////////////////////////////////// ##
## ///  PROJECT LIST  /////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

NODOCKERBUILD += list_cores list_projects list

list_cores:
	@ for i in $(vivado_CORES); do \
		echo "|     $$i"; \
	  done

list_projects:
	@ \
	for i in $(vivado_PROJECTS); do \
	   echo "|     $$i"; \
	done

#	 test -f $(VIVADO_SRCDIR)/$(FULL_NAME).tcl -o\
#		  -f $(VIVADO_PRJDIR)/$(FULL_NAME).xpr -o\
#		  -f $(VIVADO_SRCDIR)/${NAME}_${VERSION}.tcl -o\
#		  -f $(VIVADO_PRJDIR)/${NAME}_${VERSION}.xpr \
#			&& echo "|     ${NAME}";

list: ##@projects list all projects defined in vivado_PROJECTS variable
list: ##@cores list all projects defined in vivado_PROJECTS variable
list: print_banner
	@ \
	echo ",-----------------------------------------------------------------"; \
	echo "| projects and cores defined "; \
	echo "|"; \
	echo "| CORES: "; \
	$(MAKE) -s list_cores 2>/dev/null; \
	echo "|";\
	echo "| PROJECTS: "; \
	$(MAKE) -s list_projects 2>/dev/null; \
	echo "|";\
	echo "\`-----------------------------------------------------------------";


## ////////////////////////////////////////////////////////////////////////// ##
## ///  VIVADO SHELL    ///////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

.PHONY: vivado_shell hsi_shell
vivado_shell:##@vivado open a vivado shell with configured env
hsi_shell:   ##@vivado open hsi shell with configured env
hls_shell:   ##@vivado open hls shell with configured env

vivado vivado_shell hsi hsi_shell hls hls_shell:
	@ $(call $@,${TCL_ARGS})


## ////////////////////////////////////////////////////////////////////////// ##
## ///  VIVADO PROJECT  ///////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

new_project:   print_banner ##@projects Create a new vivado project
open_project:  print_banner ##@projects Open the current project
write_project:   print_banner ##@projects Store the current project
bitstream: print_banner ##@projects generate bitstream

package_ip:   ##@cores create a new pheripheral project for edit.
edit_ip:  ##@cores open project ip or edit existing project as a new ip.

new_project write_project write_bitstream package_ip: $(check_sources)
	@ $(call vivado,$@)

.PHONY: open_project edit_ip
open_project: $(check_sources)
	@ $(call vivado_shell,$@)

edit_ip: $(check_sources)
	@ $(if $(filter %.cpp,${SOURCES}),\
		   ${_envset}; $(HLS) -p $(VIVADO_PRJDIR)/$(FULL_NAME),\
		   $(call vivado_shell,$@))


## ////////////////////////////////////////////////////////////////////////// ##
## ///  BITSTREAM  ////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

bitstream: $(FPGA_BIT)

$(FPGA_BIT): $(check_prj_sources) $(check_sources)
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

$(DTS): $(VIVADO_SDKDIR)/dts/$(SYSTEM_DTS) $(LINUX_IMAGE)
	$(LINUX_BUILDDIR)/scripts/dtc/dtc -I dts -O dts -o $@ -i sdk/dts/ $<

$(DTB):  $(DTS) $(LINUX_IMAGE)
	$(LINUX_BUILDDIR)/scripts/dtc/dtc -I dts -O dtb -o $@ -i sdk/dts/ $<



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

bash:
	@ ${_envset}; \
	  /bin/bash


## ////////////////////////////////////////////////////////////////////////// ##
## ///  CLEAN  ////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

clean-local:
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


clean-all: ##@miscellaneous perform all clean operations (ip, project, general)
clean-all: clean-local clean_project clean_ip
	@- $(foreach x,$(vivado_PROJECTS),$(info clean in project: $x)$(MAKE) clean_project NAME=$x;)
	@- $(foreach x,$(vivado_CORES),$(info clean in core: $x)$(MAKE) clean_ip NAME=$x;)

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


