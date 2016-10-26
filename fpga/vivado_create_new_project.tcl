################################################################################
# define paths
################################################################################

global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)

source $top_srcdir/fpga/set_make_env.tcl
source $top_srcdir/fpga/list_project_files.tcl
source $top_srcdir/fpga/write_project_tcl.tcl

################################################################################
# setup an in memory project
################################################################################

create_project -part $make_env(VIVADO_SOC_PART) -force $make_env(soc_board) ./project

set_property  ip_repo_paths $make_env(ip_repo) [current_project]
update_ip_catalog

################################################################################
# create PS BD (processing system block design)
################################################################################

# create PS BD
# source                            $srcdir/$SYSTEM.tcl

# generate SDK files
# generate_target all [get_files    system.bd]

################################################################################
# read files:
# 1. RTL design sources
# 2. IP database files
# 3. constraints
################################################################################

# read_verilog  ./project/$SOC_BOARD.srcs/sources_1/bd/system/hdl/system_wrapper.v

# add_files -fileset constrs_1      $srcdir/$FPGA_SDC

# import_files -force

# update_compile_order -fileset sources_1

################################################################################


write_project_tcl -force -no_copy_sources -target_proj_dir project $srcdir/$make_env(soc_board).tcl

puts " WRITING ALL LOCAL FILES to $srcdir "
foreach file [ls_all_local_files] { puts " $file" }
copy_all_local_files $srcdir/project_src/$make_env(soc_board).srcs

