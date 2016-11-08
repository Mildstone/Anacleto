global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)

source -notrace $top_srcdir/fpga/vivado_socdev_utils.tcl

package require makeutils 1.0

namespace import ::tclapp::socdev::makeutils::*
make_write_project

