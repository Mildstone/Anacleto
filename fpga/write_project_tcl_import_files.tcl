## overload imports ##
proc import_files { args } {
  set proj_name [current_project]
  set proj_dir [get_property directory [current_project]]
  for {set i 0} {$i < [llength $args]} {incr i} {
    set option [string trim [lindex $args $i]]
    switch -regexp -- $option {
      "-fileset"     { incr i; set fs_name  [lindex $args $i] }
      "-relative_to" { incr i; set relto [file normalize [lindex $args $i]] }
      "-flat"        { }
      "-norecurse"   { }
      default {
	if { [regexp {^-} $option] } {
	  send_msg_id Vivado-projutils-001 ERROR "Unknown option '$option'\n"
	  return
	}
	set files_in $option
      }
    }
  }
  foreach file_in $files_in {
    set path_dirs [split [string trim [file normalize [string map {\\ /} $file_in]]] "/"]
    set begin [lsearch -exact $path_dirs "$proj_name.srcs"]
    set src_file [join [lrange $path_dirs $begin+1 end] "/"]
    set file_out $proj_dir/$proj_name.srcs/$src_file
    file mkdir [file dirname $file_out]
    file copy -force $file_in $file_out
    puts "IMPORT: $file_out"
    add_files -force -fileset $fs_name $file_out
  }
}


