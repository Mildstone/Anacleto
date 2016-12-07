
global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)



catch {
  source -notrace $top_srcdir/fpga/vivado_socdev_listutils.tcl
  namespace import ::tclapp::socdev::listutils::*
}

catch {
  source  $top_srcdir/fpga/vivado_socdev_makeutils.tcl
  namespace import ::tclapp::socdev::makeutils::*
}

# overload import
source -notrace $top_srcdir/fpga/write_project_tcl_import_files.tcl



proc get_abs_path { file } {
  return [string trim [file normalize [string map {\\ /} $file]]]
}

# Get relative path to target file from current path
# First argument is a file name, second a directory name (not checked)
proc get_rel_path {file currentpath} {
  set cc [file split [file normalize $currentpath]]
  set tt [file split [file normalize $file]]
  if {![string equal [lindex $cc 0] [lindex $tt 0]]} {
      # not on *n*x then
      return -code error "$file not on same volume as $currentpath"
  }
  while {[string equal [lindex $cc 0] [lindex $tt 0]] && [llength $cc] > 0} {
      # discard matching components from the front
      set cc [lreplace $cc 0 0]
      set tt [lreplace $tt 0 0]
  }
  set prefix ""
  if {[llength $cc] == 0} {
      # just the file name, so file is lower down (or in same place)
      set prefix "."
  }
  # step up the tree
  for {set i 0} {$i < [llength $cc]} {incr i} {
      append prefix " .."
  }
  # stick it all together (the eval is to flatten the file list)
  return [eval file join $prefix $tt]
}
