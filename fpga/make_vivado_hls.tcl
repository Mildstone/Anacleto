
global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)


rename ::source ::theRealSource
proc ::source args {
	set new_args [list]
	foreach el [split $args " "] {
	  if { $el eq "-notrace" } { continue }
	  lappend new_args $el
	 }
	uplevel 1 ::theRealSource $new_args
}


# get files is missing in hls so we implemented a dummy one
#
rename ::add_file ::theRealAddFile
set s_project_files [list]
proc ::add_file args {
  global s_project_files
  lappend $args $s_project_files
  theRealAddFile $args
}
#
proc get_files {} {
  global s_project_files
  return $s_project_files
}

source $top_srcdir/fpga/vivado_make.tcl

make package_hls_ip
quit
