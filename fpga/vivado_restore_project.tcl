################################################################################
# define paths
################################################################################

global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)

source $top_srcdir/fpga/set_make_env.tcl
source $top_srcdir/fpga/list_project_files.tcl
source $top_srcdir/fpga/write_project_tcl.tcl


set origin_dir_loc $srcdir
set orig_proj_dir_loc $srcdir
source  $srcdir/$make_env(soc_board).tcl

