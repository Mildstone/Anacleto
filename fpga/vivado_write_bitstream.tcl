global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)

source -notrace $top_srcdir/fpga/vivado_socdev_utils.tcl

package require makeutils 1.0

namespace import ::tclapp::socdev::makeutils::*
make_open_project

set prj_name [get_property NAME [current_project]]


################################################################################
# generate a bitstream
################################################################################

proc get_major { code } {
 return [lindex [split $code '.'] 0]
}

delete_runs auto_impl_1
delete_runs auto_synth_1
set flow "Vivado Synthesis [get_major $make_env(VIVADO_VERSION)]"
create_run -flow $flow auto_synth_1
set flow "Vivado Implementation [get_major $make_env(VIVADO_VERSION)]"
create_run auto_impl_1 -parent_run auto_synth_1 -flow $flow

## START SYNTH ##
reset_run auto_synth_1
launch_runs auto_impl_1 -jobs $make_env(maxThreads)
wait_on_run auto_synth_1

open_run auto_synth_1
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

## customize directory output for run ##
# file mkdir out_synth
# file mkdir out_impl
# set_property DIRECTOYRY ./out_synth [get_runs auto_synth_1]
# set_property DIRECTOYRY ./out_impl  [get_runs auto_impl_1 ]

## START IMPLEMENTATION ##
reset_run auto_impl_1
launch_runs auto_impl_1 -to_step write_bitstream -jobs $make_env(maxThreads)
wait_on_run auto_impl_1

################################################################################
# generate system definition
################################################################################

set path_out out
set path_sdk sdk
file mkdir $path_out
file mkdir $path_sdk

set  synth_dir [get_property DIRECTORY [get_runs auto_synth_1]]
set  impl_dir  [get_property DIRECTORY [get_runs auto_impl_1 ]]
set  top_name  [get_property TOP [current_design]]
file  copy -force  $impl_dir/${top_name}.hwdef $path_sdk/$prj_name.hwdef
file  copy -force  $impl_dir/${top_name}.bit   $env(FPGA_BIT)

write_sysdef    -force   -hwdef   $path_sdk/$prj_name.hwdef \
			 -bitfile $env(FPGA_BIT) \
			 -file    $path_sdk/$prj_name.sysdef



