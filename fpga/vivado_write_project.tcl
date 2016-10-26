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

write_project_tcl -force -target_proj_dir project $srcdir/$make_env(soc_board).tcl

#puts " WRITING ALL LOCAL FILES in $srcdir "
#puts [ls_all_local_files]
#copy_all_local_files $srcdir/project_src/$make_env(soc_board).srcs


