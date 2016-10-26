################################################################################
# define paths
################################################################################


global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)

source $top_srcdir/fpga/set_make_env.tcl
source $top_srcdir/fpga/list_project_files.tcl
source $top_srcdir/fpga/write_project_tcl.tcl
source $top_srcdir/fpga/write_project_tcl_devel.tcl

open_project -part $make_env(VIVADO_SOC_PART) ./project/$make_env(soc_board).xpr
if {[catch {current_project}]} {
 error "Could not open project try to restore first" }

set prj_name [get_property NAME [current_project]]


# force load common repository
set_property  ip_repo_paths $make_env(ip_repo) [current_project]
update_ip_catalog


reset_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run synth_1

################################################################################
# generate a bitstream
################################################################################

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
write_bitstream -force $env(FPGA_BIT)



################################################################################
# generate system definition
################################################################################

set path_out out
set path_sdk sdk
file mkdir $path_out
file mkdir $path_sdk

write_sysdef    -force   -hwdef   $path_sdk/$prj_name.hwdef \
			 -bitfile $env(FPGA_BIT) \
			 -file    $path_sdk/$prj_name.sysdef
