
global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)


catch {
  source -notrace $top_srcdir/fpga/vivado_socdev_listutils.tcl
  namespace import ::tclapp::socdev::listutils::*
}

catch {
  source -notrace $top_srcdir/fpga/vivado_socdev_makeutils.tcl
  namespace import ::tclapp::socdev::makeutils::*
}

# overload import
source -notrace $top_srcdir/fpga/write_project_tcl_import_files.tcl

