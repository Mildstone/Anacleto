# ////////////////////////////////////////////////////////////////////////// //
#
# This file is part of the anacleto project.
# Copyright 2018 Andrea Rigoni Garola <andrea.rigoni@igi.cnr.it>.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# ////////////////////////////////////////////////////////////////////////// //



global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)

# package require Vivado 1.2014.1

namespace eval ::tclapp::socdev::listutils {
  namespace export is_local_to_project
  namespace export ls_properties
  namespace export ls_project
  namespace export ls_fileset_files
  namespace export ls_all_local_files_in_fileset
  namespace export ls_all_remote_files_in_fileset
  namespace export ls_all_local_files
  namespace export ls_all_remote_files
  namespace export ls_all_file_types
  namespace export ls_all_block_designs
  namespace export is_block_design
  namespace export ls_all_ip
  namespace export ls_find_bd_wrapper
  namespace export get_fileset_files
}

source -notrace $top_srcdir/fpga/vivado_socdev_env.tcl

## ////////////////////////////////////////////////////////////////////////// ##
## /// IS LOCAL     ///////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

namespace eval ::tclapp::socdev::listutils {
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


## ////////////////////////////////////////////////////////////////////////// ##
## /// Print Properties   /////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

proc ls_properties {tcl_object} {
  set props [list_property $tcl_object]
  foreach pp $props {
   puts " ... $pp = [get_property "$pp" $tcl_object]"
  }
}


## ////////////////////////////////////////////////////////////////////////// ##
## /// Print Project Properties  //////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

proc ls_project_properties { } {
  puts " -------------------------- "
  puts " PROJECT: [current_project]"
  puts " -------------------------- "
  ls_properties [current_project]
  puts " -------------------------- \n"
}


## ////////////////////////////////////////////////////////////////////////// ##
## /// Print Project Files  ///////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

proc ls_fileset_files { fileset } {
  set path_dir [get_property DIRECTORY [current_project]]
  set proj_name [get_property NAME [current_project]]  
  set fout [list]
  foreach file [get_files -norecurse -of_objects [get_filesets $fileset]] {
    if { [file extension $file] == ".xcix" } { continue }
    set path_dirs [split [string trim [file normalize [string map {\\ /} $file]]] "/"]
    set begin [lsearch -exact $path_dirs "$proj_name.srcs"]
    set src_file [join [lrange $path_dirs $begin+1 end] "/"]
    puts "src_file -> $src_file"
    set file_object [lindex [get_files -of_objects [get_filesets $fileset] [list $file]] 0]
    ls_properties $file_object
    # puts " --- is_local = [is_local_to_project $file]"
    # puts "\n"
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

proc ls_all_remote_files_in_fileset { fileset } {
  set file_out [list]
  if {[llength [get_files -quiet -of_objects [get_filesets $fileset]]] == 0 } { return }
  set path_dir [get_property DIRECTORY [current_project]]
  set proj_name [get_property NAME [current_project]]
  set fs_name [get_filesets $fileset]
  foreach file [get_files -norecurse -of_objects [get_filesets $fileset]] {
    if { [file extension $file] == ".xcix" } { continue }
    if { [is_local_to_project $file] } { continue }
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

proc ls_all_remote_files {} {
  set file_out [list]
  foreach fset [get_filesets] {
    lappend file_out {*}[ls_all_remote_files_in_fileset $fset]
  }
  return $file_out
}

proc ls_all_file_types { type_property } {
  set files_out [list]
  foreach file [get_files] {
    if { [get_property "FILE_TYPE" $file] eq $type_property } {
      lappend files_out $file
    }
  }
  return $files_out
}

proc ls_all_block_designs {} {
   return [ls_all_file_types "Block Designs"]
}

proc is_block_design { file } {
  if { [get_property "FILE_TYPE" $file] eq "Block Designs" } { return 1 }
  else { return 0 }
}

proc ls_all_ip {} {
   return [ls_all_file_types "IP"]
}

proc ls_find_bd_wrapper { list_bd } {
  set files_out [list]
  foreach file_bd $list_bd {
    set bd_name [file rootname [file tail $file_bd]]
    foreach file [get_files] {
      if { [regexp "(${bd_name}_wrapper).*" [string tolower $file]] == 1 } {
	lappend files_out $file
      }
    }
  }
  return $files_out
}

}
## END NAMESPACE
