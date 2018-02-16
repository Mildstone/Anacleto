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



package provide makeutils 1.0


## INCLUDES ##
catch {
  source -notrace $top_srcdir/fpga/vivado_socdev_utils.tcl
  source -notrace $top_srcdir/fpga/vivado_socdev_env.tcl
  source -notrace $top_srcdir/fpga/vivado_socdev_listutils.tcl
}


namespace eval tclapp::socdev::makeutils {

## ////////////////////////////////////////////////////////////////////////// ##
## //  PIMPL   ////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

namespace eval v {
 # environment from makefile
 upvar 1 make_env    me
 upvar 1 project_env pe
 upvar 1 core_env    ce

 # utils
 proc fid {} { get_funid [namespace parent] [lindex [info level 1] 0] }
 proc mid {} { get_msgid [namespace parent] [lindex [info level 1] 0] }
 proc dir {f} { return [string map {\\ /} $f]}
 proc abs {f} { return [file normalize [dir $f]]}

 # argument options
 variable opts

 # set fileset types
 variable fileset_types
 set fileset_types {
   {{DesignSrcs}     {srcset}}
   {{BlockSrcs}      {blockset}}
   {{Constrs}        {constrset}}
   {{SimulationSrcs} {simset}}
 }

 # file handlers
 variable fh
 set fh(out)     0
 set fh(dump)    0
 set fh(default) 0
 set fh(log)     0
 proc dump { str } { variable fh; if { $fh(dump) > 0 } {puts $fh(dump) $str} }
 proc ddef { str } { variable fh; if { $fh(default) > 0 } {puts $fh(default) $str } }
 proc log { str } { variable fh; if { $fh(log) > 0 } {
  puts $fh(log) "[clock format [clock seconds] -format {%b%d %H:%M:%S}] \
		 [get_funid [namespace parent] [lindex [info level 1] 0] ] \] \
		 $str" } }
}

namespace eval l {
 set head [list]
 set data [list]
 set foot [list]
 proc reset {} {
   variable head; set head [list]
   variable data; set data [list]
   variable foot; set foot [list]
 }
 proc head { str } { variable head; lappend head $str }
 proc data { str } { variable data; lappend data $str }
 proc foot { str } { variable foot; lappend foot $str }
}




proc write_anacleto_tcl {args} {
  # Summary:
  # Export Tcl script for re-creating the current project

  # Argument Usage:
  # [-target_proj_dir <arg>  = Target project directory path]:
  # [-target_proj_name <arg> = Target project name]:
  #   Directory where the project needs to be restored
  # [-force]: Overwrite existing tcl script file
  # [-all_properties]: Write all properties (default & non-default)
  # [-dump_project_info]: Write object values
  # file: Name of the tcl script file to generate

  # Return Value:
  # true (0) if success, false (1) otherwise

  set_compatible_with Vivado

  # reset global variables
  variable v::opts
  set v::opts(b_arg_force)           0
  set v::opts(b_arg_all_props)       1
  set v::opts(b_arg_dump_proj_info)  1
  set v::opts(s_srctcl)             $v::pe(dir_src)/$v::pe(project_name).tcl
  set v::opts(s_srcdir)             $v::pe(dir_src)
  set v::opts(s_project_name)       $v::pe(project_name)

  # process options
  for {set i 0} {$i < [llength $args]} {incr i} {
    set option [string trim [lindex $args $i]]
    switch -regexp -- $option {
      "-target_proj_dir"      { incr i;
				set v::opts(s_srcdir) \
				[lindex $args $i] }
      "-target_proj_name"      { incr i;
				 set v::opts(s_project_name) \
				 [lindex $args $i] }
      "-force"                { set v::opts(b_arg_force) 1 }
      "-all_properties"       { set v::opts(b_arg_all_props) 1 }
      "-dump_project_info"    { set v::opts(b_arg_dump_proj_info) 1 }
      default {
	# is incorrect arg?
	if { [regexp {^-} $option] } {
	     send_msg_id [v::mid]-001 ERROR "Unknown option '$option'\n"
	     return }
	set v::opts(s_srctcl) $option
      }
    }
  }

  # script file is a must
  if { [string equal $v::opts(s_srctcl) ""] |
       [file isdirectory $v::opts(s_srctcl)] } {
    send_msg_id [v::mid]-002 ERROR \
    "Missing value for option 'file', \
     please type 'write_anacleto_tcl -help' for usage info.\n"
    return
  }

  # check extension
  if { [file extension $v::opts(s_srctcl)] != ".tcl" } {
    set v::opts(s_srctcl) $v::opts(s_srctcl).tcl }
  set v::opts(s_srctcl) [file normalize $v::opts(s_srctcl)]

  # error if file directory path does not exist
  set file_path [file dirname $v::opts(s_srctcl)]
  if { ! [file exists $file_path] } {
    set s_srctclname [file tail $v::opts(s_srctcl)]
    send_msg_id [v::mid]-003 ERROR \
    "Directory in which file ${s_srctclname} is to be written \
     does not exist \[$v::opts(s_srctcl)\]\n"
    return
  }

  # recommend -force if file exists
  if { [file exists $v::opts(s_srctcl)] && !$v::opts(b_arg_force) } {
    send_msg_id [v::mid]-004 ERROR \
    "Tcl Script '$v::opts(s_srctcl)' already exist. \
     Use -force option to overwrite.\n"
    return
  }

  # set script file directory path
  set v::opts(s_path_to_script_dir) [file normalize $file_path]
  puts "write_tcl correctly overridden"
  puts "WRITING in $v::opts(s_srctcl)"

  # now write
  if {[write_anacleto_tcl_script]} { return }
}
}






namespace eval ::tclapp::socdev::makeutils {
## ////////////////////////////////////////////////////////////////////////// ##
## /// MAIN WRITE ANACLETO TCL SCRIPT  ////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

proc write_anacleto_tcl_script {} {
  #
  set target_dir   $v::opts(s_srcdir)
  set target_name  $v::opts(s_project_name)

  # get project details /////////////
  set project   [current_project]
  set proj_dir  [get_property directory [current_project]]
  set proj_name [file tail [get_property name [current_project]]]
  set part_name [get_property part [current_project]]

  # OPEN output file script
  set fname $v::opts(s_srctcl)
  if {[catch {open $fname w} v::fh(out)]} {
    send_msg_id [v::mid]-001 ERROR "failed to open file for write ($fname)\n"
    return 1
  }

  # dump project in canonical form
  if { $v::opts(b_arg_dump_proj_info) } {
    set fname [file normalize [file join $target_dir ${target_name}_dump.txt]]
    if {[catch {open $fname w} v::fh(dump)]} {
      send_msg_id [v::mid]-002 ERROR "failed to open file for write ($fname)\n"
      return 1
    }

    # default value output file script handle
    set fname [file normalize [file join $target_dir ${target_name}_def_val.txt]]
    if {[catch {open $fname w} v::fh(default)]} {
      send_msg_id [v::mid]-003 ERROR "failed to open file for write ($fname)\n"
      return 1
    }

    # log output file script handle
    set fname [file normalize [file join $target_dir ${target_name}_write_log.txt]]
    if {[catch {open $fname w} v::fh(log)]} {
    send_msg_id [v::mid]-003 ERROR "failed to open file for write ($fname)\n"
    return 1
    }
  }

  # explicitly update the compile order for current source/simset
  if { {All} == [get_property source_mgmt_mode [current_project]] &&
       {0}   == [get_property is_readonly [current_project]] &&
       {RTL} == [get_property design_mode [current_fileset]] } {


    # re-parse source fileset compile order for the current top
    if {[llength [get_files -compile_order sources -used_in synthesis]] > 1} {
      update_compile_order -fileset [current_fileset] -quiet
    }

    # re-parse simlulation fileset compile order for the current top
    if {[llength [get_files -compile_order sources -used_in simulation]] > 1} {
      update_compile_order -fileset [current_fileset -simset] -quiet
    }
  }

  # reset lists
  l::reset

  # writer helpers
  wr_header $proj_dir $proj_name $part_name
  wr_create_project $proj_dir $proj_name $part_name
  wr_project_properties $proj_dir $proj_name
  wr_filesets $proj_dir $proj_name
  wr_runs $proj_dir $proj_name
  wr_proj_info $proj_name


  # write_header
  foreach line $l::head { puts $v::fh(out) $line }

  # write_script_data
  foreach line $l::data { puts $v::fh(out) $line }

  # write_script_footer
  foreach line $l::foot { puts $v::fh(out) $line }

  # close files
  close $v::fh(out)
  if { $v::opts(b_arg_dump_proj_info) } {
   close $v::fh(dump)
   close $v::fh(default)
   close $v::fh(log)
  }

  return 0
}














## ////////////////////////////////////////////////////////////////////////// ##
## /// WR /////////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

proc wr_header {proj_dir proj_name part_name} {
  # ADD MAKE_ENV
  l::head ""
  l::head "## ////////////////////////////////////////////////////////////////////////// ##"
  l::head "## /// MAKE ENV  //////////////////////////////////////////////////////////// ##"
  l::head "## ////////////////////////////////////////////////////////////////////////// ##"
  l::head ""
  lappend l::head {*}$v::me(self)
  l::head ""
  l::head ""
}

proc wr_create_project {proj_dir name part} {
  #
  # create project
  l::data "## ////////////////////////////////////////////////////////////////////////// ##"
  l::data "## /// CREATE PROJ ////////////////////////////////////////////////////////// ##"
  l::data "## ////////////////////////////////////////////////////////////////////////// ##"

  v::log " project_name=$name"
  v::log " proj_dir=$proj_dir"
  v::log " part=$part"

  puts "proj_dir: $proj_dir "
  set tcl_cmd "create_project $name \
	      \"\$make_env[get_path_relative_to (builddir) $proj_dir]\" \
	      -part $part"

  # project is an IP managed
  if { [get_property managed_ip [current_project]] } { set tcl_cmd "$tcl_cmd -ip" }

  v::dump "project_name=$name"
  l::data " "
  l::data " $tcl_cmd"
  l::data " "
  l::data " # Set the directory path for the new project"
  l::data " set proj_dir \[get_property directory \[current_project\]\]"


  l::data " "
  l::data " # Reconstruct message rules"
  set msg_control_rules [ debug::get_msg_control_rules -as_tcl ]
  if { [string length $msg_control_rules] > 0 } {
    l::data " ${msg_control_rules}"
  } else {
    l::data " # None"
  }
  l::data " "
}


proc wr_filesets { proj_dir proj_name } {
  #
  # create project
  l::data "## ////////////////////////////////////////////////////////////////////////// ##"
  l::data "## /// FILESETS    ////////////////////////////////////////////////////////// ##"
  l::data "## ////////////////////////////////////////////////////////////////////////// ##"
  l::data ""

  v::log "writing filesets:"
  foreach {fs_data} $v::fileset_types { v::log " - [lindex $fs_data 0]" }
  v::log ""
  foreach {fs_data} $v::fileset_types {
    set filesets [get_filesets -filter FILESET_TYPE==[lindex $fs_data 0]]
    write_specified_fileset $proj_dir $proj_name $filesets
  }
}

## ////////////////////////////////////////////////////////////////////////// ##
## /// STUBS  /////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##


proc wr_project_properties {args} {}
proc wr_runs {args} {}
proc wr_proj_info {args} {}





## ////////////////////////////////////////////////////////////////////////// ##
## /// WRITE_FILESET  /////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

proc test_is_makefile_repo { path } {
  set path_list [list \
	{*}[split $v::pe(IP_SOURCES) " "] \
	{*}[split $v::pe(ip_repo) " "] \
	{*}$v::me(builddir) ]
  foreach repo $path_list {
	if { [file normalize $path] eq [file normalize $repo] } { return true }
	if { [file normalize $path] eq [file normalize [file dirname $repo]] } { return true }
  }
  return false
}

proc write_specified_fileset { proj_dir proj_name filesets } {}
proc write_specified_fileset { proj_dir proj_name filesets } {
  set type "file"
  foreach tcl_obj $filesets {
    # Is this a IP block fileset for a proxy IP that is owned by another
    # composite file? If so, we don't want to write it out as an independent
    # file. The parent will take care of it.
    if { [is_proxy_ip_fileset $tcl_obj] } { continue }

	set fs_type [get_property fileset_type [get_filesets $tcl_obj]]

	l::data " # /////////////////////////////////////////////////////////////  "
	l::data " # // $tcl_obj                                                    "
	l::data " # /////////////////////////////////////////////////////////////  "
	l::data " # "

    # is this a IP block fileset? if yes, do not create block fileset, but
    # create for a pure HDL based fileset (no IP's)
    if { [is_ip_fileset $tcl_obj] } {
      # do not create block fileset
    } else {
      v::log  "create fileset: $filesets "
      l::data " # Create '$tcl_obj' fileset (if not found)"
      l::data " if \{\[string equal \[get_filesets -quiet $tcl_obj\] \"\"\]\} \{"

      set fs_sw_type [get_fileset_type_switch $fs_type]
      l::data "   create_fileset $fs_sw_type $tcl_obj"
	  l::data " \}"
	  l::data " # "
    }

    set get_what_fs "get_filesets"
	# //// REPO_PATHS /////////////////////////////////////////////////////// ##
	# set IP REPO PATHS (if any) for filesets of type "DesignSrcs" or "BlockSrcs"
	if { (({DesignSrcs} == $fs_type) || ({BlockSrcs} == $fs_type)) } {
	  if { ({RTL} == [get_property design_mode [get_filesets $tcl_obj]]) } {
		set all_repo_paths [get_ip_repo_paths $tcl_obj]
		set local_repo_paths [list]
		foreach path $all_repo_paths {
		 if { ![test_is_makefile_repo $path]} { lappend local_repo_paths $path }
		}
		l::data " # Set IP repository paths"
		if { [llength $local_repo_paths] > 0 } {
		  l::data " set obj \[get_filesets $tcl_obj\]"
		  set path_list [list]
		  foreach path $local_repo_paths {
			 lappend path_list "\"\$make_env[get_path_relative_to (srcdir) $path]\""
		  }
		  #
		  # list addition
		  l::data " set repo_path_str \[list \\"
		  foreach repo_el $local_repo_paths { l::data "  $repo_el\\" }
		  l::data " \]"
		  l::data " set_property \"ip_repo_paths\" \${repo_path_str} \$obj"
		  #
		  l::data " # "
		  l::data " # Rebuild user ip_repo's index before adding any source files"
		  l::data " update_ip_catalog -rebuild"
		  l::data " # "
		} else {
		  l::data " # No local ip repos found for $tcl_obj ... "
		  l::data " # "
		}
	  }
	}

    # is this a IP block fileset? if yes, then set the current srcset object
    # (IP's will be added to current source fileset)
    if { [is_ip_fileset $tcl_obj] } {
      # IP
      set srcset [current_fileset -srcset]
      l::data " # Set '$srcset' fileset object"
      l::data " set obj \[$get_what_fs $srcset\]"
    } else {
      # NOT IP
      l::data " # Set '$tcl_obj' fileset object"
      l::data " set obj \[$get_what_fs $tcl_obj\]"
    }

	write_files $proj_dir $proj_name $tcl_obj $fs_type
	#    if { {Constrs} == $fs_type } {
	#      #### WRITE_CONSTRAINTS ->
	#      write_constrs $proj_dir $proj_name $tcl_obj $type
	#    } else {
	#      #### WRITE_FILES ->
	#      write_files $proj_dir $proj_name $tcl_obj $type
	#    }

	#
	#    # is this a IP block fileset? if yes, do not write block fileset properties
	#    # (block fileset doesnot exist in new project)
	#    if { [is_ip_fileset $tcl_obj] } {
	#      # do not write ip fileset properties
	#    } else {
	#      l::data " # Set '$tcl_obj' fileset properties"
	#      l::data " set obj \[$get_what_fs $tcl_obj\]"
	#      write_props $proj_dir $proj_name $get_what_fs $tcl_obj "fileset"
	#    }
	l::data " # "
	l::data " # "
	v::log  ""
  }
}



## //// WRITE FILES ////////////////////////////////////////////////////////////
proc write_files { proj_dir proj_name tcl_obj type } {
  #
  v::log "writing files for filesset: $tcl_obj"

  # return if empty fileset
  if {[llength [get_files -quiet -of_objects [get_filesets $tcl_obj]]] == 0 } {
	l::data " # Empty (no sources present)\n"
	v::log  " - Empty fileset"
    return
  }
  set fs_name [get_filesets $tcl_obj]
  set import_coln   [list]
  set copy_coln   [list]
  set add_file_coln [list]
  set l_remote_file_list [list]
  set l_local_file_list  [list]


  foreach file [get_files -norecurse -of_objects [get_filesets $tcl_obj]] {
    if { [file extension $file] == ".xcix" } { continue }
    set file_object [lindex [get_files -of_objects [get_filesets $fs_name] [list $file]] 0]
	set file_type   [get_property "FILE_TYPE" $file_object]
	set file_props  [list_property $file_object]
	if { $file_type eq "IP-XACT" } { continue }
    if { [lsearch $file_props "IMPORTED_FROM"] != -1 } {
	  ###          ###
	  ### IMPORTED ###
	  ###          ###
	  # TODO: for now imported are treated like local
	  set file   [get_path_relative_to . $file]/[file tail $file]
	  set srcdir $v::pe(dir_src)/[get_path_relative_to $v::pe(dir_prj) $file]
	  v::log "-> imported: file copy -force $file $srcdir"
	  file mkdir $srcdir
	  file copy -force $file $srcdir
	  # add to the import collection
	  set src_relfile [get_path_relative_to (dir_src) $srcdir]/[file tail $file]
	  lappend import_coln "\"\[file normalize \$project_env$src_relfile\]\""
	  lappend l_local_file_list $file
	} else {
	  if { [is_local_to_project $file] } {
		###          ###
		### LOCAL    ###
		###          ###
		v::dump "\$PSRCDIR/$file"
		set file   [get_path_relative_to . $file]/[file tail $file]
		set srcdir $v::pe(dir_src)/[get_path_relative_to $v::pe(dir_prj) $file]
		v::log "-> local: file copy -force $file $srcdir"
		file mkdir $srcdir
		file copy -force $file $srcdir
		if { $file_type eq "Block Designs" } {
		 set bdtcl $srcdir/[file tail $file]_$v::pe(VIVADO_VERSION).tcl
		 v::log "-> local: writing tcl script [file tail $bdtcl]"
		 open_bd_design $file
		 validate_bd_design
		 write_bd_tcl -force $bdtcl
		}
		# add to the import collection
		#  set src_relfile [get_path_relative_to (dir_src) $srcdir]/[file tail $file]
		#  lappend import_coln "\"\$project_env$src_relfile\""
		set prj_relfile [get_path_relative_to $v::pe(dir_prj) $file]/[file tail $file]
		lappend copy_coln "$prj_relfile"
		lappend add_file_coln "\$project_env(dir_prj)/$prj_relfile"
		lappend l_local_file_list $file
	  } else {
		###          ###
		### REMOTE   ###
		###          ###
		v::log "-> remote: $file"
		lappend l_remote_file_list $file
		set rel_file_path [get_path_relative_to (srcdir) $file]/[file tail $file]
		lappend add_file_coln "\$make_env$rel_file_path"
		# TODO: add_file_coln should be used if a remote isn't handled by SOURCES
	  }
	}
  }
  #   end foreach file
  ###
  ### COPY LOCALS
  if { [llength $copy_coln] > 0 } {
	foreach ifile $copy_coln {
	 l::data " file mkdir \"\$project_env(dir_prj)/[file dirname $ifile]\""
	 l::data " file copy -force \"\$project_env(dir_src)/$ifile\" \\\n    \"\$project_env(dir_prj)/$ifile\""
	}
  }
  ###
  ### IMPORTS
  if { [llength $import_coln] > 0 } {
	l::data " set files \[list \\"
	foreach ifile $import_coln { l::data "  $ifile\\" }
	l::data " \]"
	# is this a IP block fileset? if yes, import files into current source fileset
	if { [is_ip_fileset $tcl_obj] } {
	  l::data " set imported_files \[import_files -fileset [current_fileset -srcset] \$files\]"
	} else {
	  l::data " set imported_files \[import_files -fileset $tcl_obj \$files\]"
	}
  }
  ###
  ### ADD REMOTES
  if {[llength $add_file_coln]>0} {
	l::data " set files \[list \\"
	foreach file $add_file_coln { l::data "  \"\[file normalize $file\]\"\\" }
	l::data " \]"
	l::data " add_files -norecurse -fileset \$obj \$files"
  }
  l::data " # "
  ###
  ### PROPERTIES
  # write fileset file properties for remote files (added sources)
  write_fileset_file_properties $tcl_obj $fs_name $proj_dir $l_remote_file_list "remote"
  # write fileset file properties for local files (imported sources)
  write_fileset_file_properties $tcl_obj $fs_name $proj_dir $l_local_file_list "local"
}



proc is_ip_readonly_prop { name } {
  if { [regexp -nocase {synth_checkpoint_mode}     $name] ||
	   [regexp -nocase {is_locked}                 $name] ||
	   [regexp -nocase {generate_synth_checkpoint} $name] } {
	return true
  }
  return false
}

## //// WRITE PROPERTIES ///////////////////////////////////////////////////////
proc write_properties { prop_info_list get_what tcl_obj } {
  if {[llength $prop_info_list] > 0} {
	set b_add_closing_brace 0
	foreach x $prop_info_list {
	  set elem [split $x "#"]
	  set name [lindex $elem 0]
	  set value [lindex $elem 1]
	  if { [regexp "more options" $name] } {
		set cmd_str "  set_property -quiet -name {$name} -value {$value} -objects"
	  } elseif { ([is_ip_readonly_prop $name]) && ([string equal $get_what "get_files"]) } {
		set cmd_str "  if \{ !\[get_property \"is_locked\" \$file_obj\] \} \{"
		l::data "$cmd_str"
		set cmd_str "    set_property -quiet \"$name\" \"$value\""
		set b_add_closing_brace 1
	  } else {
		set cmd_str "  set_property -quiet \"$name\" \"$value\""
	  }
	  if { [string equal $get_what "get_files"] } {
		l::data "$cmd_str \$file_obj"
		if { $b_add_closing_brace } {
		  l::data "  \}"
		  set b_add_closing_brace 0
		}
	  } else {
		# comment "is_readonly" project property
		if { [string equal $get_what "get_projects"] && [string equal "$name" "is_readonly"] } {
		  if { ! $v::opts(b_arg_all_props) } {
			send_msg_id [v::mid]-001 INFO "The current project is in 'read_only' state."
		  }
		  continue
		}
		l::data "$cmd_str \$obj"
	  }
	}
  }
  l::data " # "
}

## //// WRITE FILE PROPS ///////////////////////////////////////////////////////
proc write_fileset_file_properties { tcl_obj fs_name proj_dir l_file_list file_category } {

  set file_prop_count 0
  foreach file $l_file_list {
	set file_object [lindex [get_files -of_objects [get_filesets $fs_name] [list $file]] 0]
	set file_props  [list_property $file_object]
	set prop_info_list [list]
	set prop_count 0

	foreach file_prop $file_props {
	  set is_readonly [get_property is_readonly [rdi::get_attr_specs $file_prop -object $file_object]]
	  if { [string equal $is_readonly "1"] } { continue }
	  v::log " --> file_prop: $file_prop"

	  set prop_type [get_property type [rdi::get_attr_specs $file_prop -object $file_object]]
	  set def_val [list_property_value -default $file_prop $file_object]
	  set cur_val [get_property $file_prop $file_object]
	  # filter special properties
	  if { [filter $file_prop $cur_val $file] } { continue }

	  # re-align values
	  set cur_val [get_target_bool_val $def_val $cur_val]

	  set dump_prop_name [string tolower ${fs_name}_file_${file_prop}]
	  set prop_entry "[string tolower $file_prop]#[get_property $file_prop $file_object]"

	  if { $v::opts(b_arg_all_props) } {
		lappend prop_info_list $prop_entry
		incr prop_count
	  } else {
		if { $def_val != $cur_val } {
		  lappend prop_info_list $prop_entry
		  incr prop_count
		}
	  }
	  #	  if { $v::opts(b_arg_dump_proj_info) } {
	  #	  puts $v::opts(def_val_fh)
	  # "[file tail $file]=$file_prop `($prop_type) :DEFAULT_VALUE ($def_val)==CURRENT_VALUE ($cur_val)"
	  #	puts $v::opts(dp_fh) "$dump_prop_name=$cur_val"
	  #	  }
	}

	# write properties now
	if { $prop_count>0 } {
	  l::data " # Properties for [file tail $file]"
	  if { {remote} == $file_category } {
		  l::data "  set file \"\$project_env[get_path_relative_to (dir_src) $file]/[file tail $file]\""
		  l::data "  set file \[file normalize \$file\]"
	  } else {
		l::data "  set file \"\$project_env[get_path_relative_to (dir_prj) $file]/[file tail $file]\""
	  }
	  # is this a IP block fileset? if yes, get files from current source fileset
	  if { [is_ip_fileset $tcl_obj] } {
		l::data "  set file_obj \[get_files -of_objects \[get_filesets [current_fileset -srcset]\] \[list \"\$file\"\]\]"
	  } else {
		l::data "  set file_obj \[get_files -of_objects \[get_filesets $tcl_obj\] \[list \"\$file\"\]\]"
	  }
	  set get_what "get_files"
	  write_properties $prop_info_list $get_what $tcl_obj
	  incr file_prop_count
	}
  }

  if { $file_prop_count == 0 } {
	l::data " # No properties for [file tail $tcl_obj]"
  }
}






## //// WRITE CONSTRS //////////////////////////////////////////////////////////
proc write_constrs { proj_dir proj_name tcl_obj type } {
  v::log "writing constrs for fileset: $tcl_obj"
  write_files $proj_dir $proj_name $tcl_obj $type
}


## //// WRITE PROPS ////////////////////////////////////////////////////////////
proc write_props { proj_dir proj_name get_what tcl_obj type } {
  v::log "writing props for: $tcl_obj"
}













## ////////////////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##
## //  UTILS   ////////////////////////////////////////////////////////////// ##

proc get_path_relative_to { relative_to filename } {
  set env_path true
  switch $relative_to {
    "(srcdir)"           { set rto [srcdir] }
    "(top_srcdir)"       { set rto [top_srcdir] }
    "(builddir)"         { set rto [builddir] }
    "(top_builddir)"     { set rto [top_builddir] }
	"(dir_prj)"          { set rto $v::pe(dir_prj) }
	"(dir_src)"          { set rto $v::pe(dir_src) }
    default { set env_path false; set rto $relative_to }
  }

  set src [file normalize [string map {\\ /} $filename ]]
  set rto [file normalize [string map {\\ /} $rto ]]
  if {![file isdirectory $src]} { set src [file dirname $src] }
  if {![file isdirectory $rto]} { set rto [file dirname $rto] }

  set src [file split $src]
  set rto [file split $rto]
  # WINDOWS COMPARISON #
  #  if {![string equal [lindex $src 0] [lindex $rto 0]]} {
  #    send_msg_id [v::mid]-1 ERROR "$filename not on same volume as $relative_to"
  #    return -code error "error on relative path"
  #  }
  while {[string equal [lindex $src 0] [lindex $rto 0]] && [llength $src] > 0} {
      set src [lreplace $src 0 0]
      set rto [lreplace $rto 0 0]
  }
  set prefix ""
  if {[llength $rto] == 0} {
      if { !$env_path } { set prefix "." }
  }
  for {set i 0} {$i < [llength $rto]} {incr i} {
      append prefix " .."
  }
  if { $prefix == "" && $src == "" } {
	set resolved_path "."
  } else {
	set resolved_path [eval file join $prefix $src]
  }
  if { $env_path } { return $relative_to/$resolved_path }
  if { ![string equal $relative_to "."] && [string first "./" $resolved_path] == 0 } {
	set resolved_path [string trimleft $resolved_path "./"] }
  return $resolved_path
}

proc is_ip_fileset { fileset } {

  # Summary: Find IP's if any from the specified fileset and return true if
  #          'generate_synth_checkpoint' is set to 1
  # Argument Usage:
  # fileset: fileset name
  # Return Value:
  # true (1) if success, false (0) otherwise

  # make sure fileset is block fileset type
  if { {BlockSrcs} != [get_property fileset_type [get_filesets $fileset]] } {
    return false
  }

  set ip_filter "FILE_TYPE == \"IP\" || FILE_TYPE==\"Block Designs\""
  set ips [get_files -all -quiet -of_objects [get_filesets $fileset] -filter $ip_filter]
  set b_found false
  foreach ip $ips {
    if { [get_property generate_synth_checkpoint [lindex [get_files -all $ip] 0]] } {
      set b_found true
      break
    }
  }

  if { $b_found } {
    return true
  }
  return false
}

proc is_proxy_ip_fileset { fileset } {
  # Summary: Determine if the fileset is an OOC run for a proxy IP that has a
  #          parent composite
  # Argument Usage:
  # fileset: fileset name
  # Return Value:
  # true (1) if the fileset contains an IP at its root with a parent composite,
  # false (0) otherwise

  # make sure fileset is block fileset type
  if { {BlockSrcs} != [get_property fileset_type [get_filesets $fileset]] } {
    return false
  }

  set ip_with_parent_filter "FILE_TYPE == IP && PARENT_COMPOSITE_FILE != \"\""
  if {[llength [get_files -norecurse -quiet -of_objects \
     [get_filesets $fileset] -filter $ip_with_parent_filter]] == 1} {
    return true
  }

  return false
}


proc is_ip_run { run } {
  # Summary: Find IP's if any from the fileset linked with the block fileset run
  # Argument Usage:
  # run: run name
  # Return Value:
  # true (1) if success, false (0) otherwise

  set fileset [get_property srcset [get_runs $run]]
  return [is_ip_fileset $fileset]
}

proc get_fileset_type_switch { fileset_type } {
  # Summary: Return the fileset type switch for a given fileset
  # Argument Usage:
  # Return Value:
  # Fileset type switch name

  set fs_switch ""
  foreach {fs_data} $v::fileset_types {
    set fs_type [lindex $fs_data 0]
    if { [string equal -nocase $fileset_type $fs_type] } {
      set fs_switch [lindex $fs_data 1]
      set fs_switch "-$fs_switch"
      break
    }
  }
  return $fs_switch
}

proc get_target_bool_val { def_val cur_val } {
  # Summary: Resolve current boolean property value wrt its default value
  # Argument Usage:
  # Return Value:
  # Resolved boolean value

  set target_val $cur_val

  if { [string equal $def_val "false"] && [string equal $cur_val "0"] } { set target_val "false" } \
  elseif { [string equal $def_val "true"]  && [string equal $cur_val "1"] } { set target_val "true"  } \
  elseif { [string equal $def_val "false"] && [string equal $cur_val "1"] } { set target_val "true"  } \
  elseif { [string equal $def_val "true"]  && [string equal $cur_val "0"] } { set target_val "false" } \
  elseif { [string equal $def_val "{}"]    && [string equal $cur_val ""]  } { set target_val "{}" }

  return $target_val
}

proc get_ip_repo_paths { tcl_obj } {
  # Summary:
  # Iterate over the fileset properties and get the ip_repo_paths (if set)
  # Argument Usage:
  # tcl_obj : fileset
  # Return Value:
  # List of repo paths

  set repo_path_list [list]
  foreach path [get_property ip_repo_paths [get_filesets $tcl_obj]] {
    lappend repo_path_list $path
  }
  return $repo_path_list
}

## ////////////////////////////////////////////////////////////////////////// ##
## //  FILTER  ////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

# set file types to filter
variable l_filetype_filter [list]
set      l_filetype_filter [list "ip" "ipx" "embedded design sources" "elf" \
								 "coefficient files" "configuration files" \
								 "block diagrams" "block designs" \
								 "dsp design sources" "text" \
								 "design checkpoint" \
								 "waveform configuration file" ]
# ip file extension types
variable l_valid_ip_extns [list]
set l_valid_ip_extns      [list ".xci" ".bd" ".slx"]

proc filter { prop val { file {} } } {
  # Summary: filter special properties
  # This helper command is used to script help.
  # Argument Usage:
  # Return Value:
  # true (1) if found, false (1) otherwise
  variable l_filetype_filter
  variable l_valid_ip_extns
  set prop [string toupper $prop]
  if { [expr { $prop == "BOARD" } || \
			 { $prop == "IS_HD" } || \
			 { $prop == "IS_PARTIAL_RECONFIG" } || \
			 { $prop == "ADD_STEP" }]} {
	return 1
  }
  if { [string equal type "project"] } {
	if { [expr { $prop == "DIRECTORY" }] } {
	  return 1
	}
  }
  # error reported if file_type is set
  # e.g ERROR: [Vivado 12-563] The file type 'IP' is not user settable.
  set val  [string tolower $val]
  if { [string equal $prop "FILE_TYPE"] } {
	if { [lsearch $l_filetype_filter $val] != -1 } {
	  return 1
	}
  }
  # filter readonly is_managed property for ip
  if { [string equal $prop "IS_MANAGED"] } {
	if { [lsearch -exact $l_valid_ip_extns [string tolower [file extension $file]]] >= 0 } {
	  return 1
	}
  }
  # filter ip_repo_paths (ip_repo_paths is set before adding sources)
  if { [string equal -nocase $prop {ip_repo_paths}] } {
	return 1
  }
  return 0
}


}
## NAMESPACE
