################################################################################
# Vivado tcl script for building RedPitaya FPGA in non project mode
#
# Usage:
# vivado -mode tcl -source red_pitaya_vivado.tcl
################################################################################

################################################################################
# define paths
################################################################################

global env
set srcdir   $env(srcdir)
set top_srcdir   $env(top_srcdir)

set SYSTEM           $env(SYSTEM)
set SOC_BOARD        $env(SOC_BOARD)
set FPGA_SDC         $env(FPGA_SDC)
set FPGA_BIT         $env(FPGA_BIT)
set VIVADO_VERSION   $env(VIVADO_VERSION)
set VIVADO_SOC_PART  $env(VIVADO_SOC_PART)
set FPGA_REPO_DIR    $env(FPGA_REPO_DIR)

set_param general.maxThreads $env(maxThreads)

# set path_rtl rtl
# set path_ip  ip
# set path_sdc sdc

set path_out out
set path_sdk sdk

file mkdir $path_out
file mkdir $path_sdk

################################################################################
# setup an in memory project
################################################################################

create_project -in_memory -part $VIVADO_SOC_PART

set_property  ip_repo_paths $FPGA_REPO_DIR [current_project]
update_ip_catalog

# experimental attempts to avoid a warning
#get_projects
#get_designs
#list_property  [current_project]
#set_property FAMILY 7SERIES [current_project]
#set_property SIM_DEVICE 7SERIES [current_project]

################################################################################
# create PS BD (processing system block design)
################################################################################

# file was created from GUI using "write_bd_tcl -force ip/system_bd.tcl"
# create PS BD
source                            $srcdir/$SYSTEM.tcl

# generate SDK files
generate_target all [get_files    system.bd]
write_hwdef        -force         $path_sdk/$SYSTEM.hwdef

################################################################################
# read files:
# 1. RTL design sources
# 2. IP database files
# 3. constraints
################################################################################


# template
#read_verilog                      $path_rtl/...

# sources
read_verilog                      .srcs/sources_1/bd/system/hdl/system_wrapper.v

# constraints
#add_files -fileset constrs_1      $srcdir/$FPGA_SDC
read_xdc                          $srcdir/$FPGA_SDC

################################################################################
# run synthesis
# report utilization and timing estimates
# write checkpoint design
################################################################################

#synth_design -top red_pitaya_top
synth_design -top system_wrapper -flatten_hierarchy none -bufg 16 -keep_equivalent_registers

write_checkpoint         -force   $path_out/post_synth
report_timing_summary    -file    $path_out/post_synth_timing_summary.rpt
report_power             -file    $path_out/post_synth_power.rpt

################################################################################
# run placement and logic optimization
# report utilization and timing estimates
# write checkpoint design
################################################################################

opt_design
power_opt_design
place_design
phys_opt_design
write_checkpoint         -force   $path_out/post_place
report_timing_summary    -file    $path_out/post_place_timing_summary.rpt
#write_hwdef              -file    $path_sdk/red_pitaya.hwdef

################################################################################
# run router
# report actual utilization and timing,
# write checkpoint design
# run drc, write verilog and xdc out
################################################################################

route_design
write_checkpoint         -force   $path_out/post_route
report_timing_summary    -file    $path_out/post_route_timing_summary.rpt
report_timing            -file    $path_out/post_route_timing.rpt -sort_by group -max_paths 100 -path_type summary
report_clock_utilization -file    $path_out/clock_util.rpt
report_utilization       -file    $path_out/post_route_util.rpt
report_power             -file    $path_out/post_route_power.rpt
report_drc               -file    $path_out/post_imp_drc.rpt
#write_verilog            -force   $path_out/bft_impl_netlist.v
#write_xdc -no_fixed_only -force   $path_out/bft_impl.xdc

################################################################################
# generate a bitstream
################################################################################

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

write_bitstream -force $FPGA_BIT

################################################################################
# generate system definition
################################################################################

write_sysdef    -force   -hwdef   $path_sdk/$SYSTEM.hwdef \
			 -bitfile $FPGA_BIT \
			 -file    $path_sdk/$SYSTEM.sysdef

exit
