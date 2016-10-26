

proc is_local_to_project { file } {
  # Summary: check if file is local to the project directory structure
  # This helper command is used to script help.
  # Argument Usage:
  # Return Value:
  # true (1), if file is local to the project (inside project directory structure)
  # false (0), if file is outside the project directory structure

  set dir [get_property directory [current_project]]
  set proj_comps [split [string trim [file normalize [string map {\\ /} $dir]]] "/"]
  set file_comps [split [string trim [file normalize [string map {\\ /} $file]]] "/"]
  set is_local 1
  for {set i 1} {$i < [llength $proj_comps]} {incr i} {
    if { [lindex $proj_comps $i] != [lindex $file_comps $i] } {
      set is_local 0;break
    }
  }

  return $is_local
}

## Print Properties
##
proc ls_properties {tcl_object} {
  set props [list_property $tcl_object]
  foreach pp $props {
   puts " ... $pp = [get_property "$pp" $tcl_object]"
  }
}

## Print Project propetries
##
proc ls_project { } {
  puts " -------------------------- "
  puts " PROJECT: [current_project]"
  puts " -------------------------- "
  ls_properties [current_project]
  puts " -------------------------- \n"
}

## Print filesets
##
proc ls_filesets { proj_dir proj_name } { get_filesets }

## Print all files in a fileset with their properties
##
proc ls_fileset_files { fileset } {

  set path_dir [get_property DIRECTORY [current_project]]
  set proj_name [get_property NAME [current_project]]

  set fs_name [get_filesets $fileset]
  set import_coln [list]
  set add_file_coln [list]

  foreach file [get_files -norecurse -of_objects [get_filesets $fileset]] {
    if { [file extension $file] == ".xcix" } { continue }
    set path_dirs [split [string trim [file normalize [string map {\\ /} $file]]] "/"]
    set begin [lsearch -exact $path_dirs "$proj_name.srcs"]
    set src_file [join [lrange $path_dirs $begin+1 end] "/"]
    puts "src_file -> $src_file"
    set file_object [lindex [get_files -of_objects [get_filesets $fs_name] [list $file]] 0]
    ls_properties $file_object
   puts " --- is_local = [is_local_to_project $file]"
   puts "\n"
  }

}




proc ls_all_local_files_in_fileset { fileset } {
  set file_out [list]
  if {[llength [get_files -quiet -of_objects [get_filesets $fileset]]] == 0 } { return }
  set path_dir [get_property DIRECTORY [current_project]]
  set proj_name [get_property NAME [current_project]]
  set fs_name [get_filesets $fileset]
  foreach file [get_files -norecurse -of_objects [get_filesets $fileset]] {
    if { [file extension $file] == ".xcix" } { continue }
    if { ![is_local_to_project $file] } { continue }
    set path_dirs [split [string trim [file normalize [string map {\\ /} $file]]] "/"]
    set begin [lsearch -exact $path_dirs "$proj_name.srcs"]
    set src_file [join [lrange $path_dirs $begin+1 end] "/"]
    lappend file_out $src_file
  }
  return $file_out
}


proc ls_all_local_files {} {
  set file_out [list]
  foreach fset [get_filesets] {
    lappend file_out {*}[ls_all_local_files_in_fileset $fset]
  }
  return $file_out
}


proc copy_all_local_files { dir } {
  set path_dir [get_property DIRECTORY [current_project]]
  set proj_name [get_property NAME [current_project]]
  set src_dir "$path_dir/$proj_name.srcs"
  foreach file [ls_all_local_files] {
    file mkdir $dir/[file dirname $file]
    file copy -force $src_dir/$file $dir/[file dirname $file]
  }
}
