################################################################################
# Vivado tcl script for building RedPitaya FPGA in non project mode
#
# Usage:
# vivado -mode batch -source red_pitaya_vivado_project.tcl
################################################################################

################################################################################
# define paths
################################################################################

global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)

set SYSTEM           $env(SYSTEM)
set SOC_BOARD        $env(SOC_BOARD)
set FPGA_SDC         $env(FPGA_SDC)
set FPGA_BIT         $env(FPGA_BIT)
set VIVADO_VERSION   $env(VIVADO_VERSION)
set VIVADO_SOC_PART  $env(VIVADO_SOC_PART)
set FPGA_REPO_DIR    $env(FPGA_REPO_DIR)

set_param general.maxThreads $env(maxThreads)

# set path_rtl $srcdir
# set path_ip  $srcdir
# set path_sdc $srcdir

################################################################################
# setup an in memory project
################################################################################

create_project -part $VIVADO_SOC_PART -force $SOC_BOARD ./project

set_property  ip_repo_paths $FPGA_REPO_DIR [current_project]
update_ip_catalog

################################################################################
# create PS BD (processing system block design)
################################################################################

# create PS BD
source                            $srcdir/$SYSTEM.tcl

# generate SDK files
generate_target all [get_files    system.bd]

################################################################################
# read files:
# 1. RTL design sources
# 2. IP database files
# 3. constraints
################################################################################

read_verilog  ./project/$SOC_BOARD.srcs/sources_1/bd/system/hdl/system_wrapper.v

add_files -fileset constrs_1      $srcdir/$FPGA_SDC

import_files -force

update_compile_order -fileset sources_1

################################################################################
################################################################################

#start_gui
