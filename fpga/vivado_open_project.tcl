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


################################################################################
# OPEN PROJECT
################################################################################

open_project -part $make_env(VIVADO_SOC_PART) ./project/$make_env(soc_board).xpr


