
# include top level script
source $top_srcdir/fpga/write_project_tcl.tcl


namespace eval ::tclapp::xilinx::projutils {
  variable make_env
  variable project_set
  variable project_env

  namespace export make_import_file
}



## DEVEL OVERRIDE SECTION ######################################################
##
##

namespace eval ::tclapp::xilinx::projutils {
proc write_project_tcl {args} {
  # Summary:
  # Export Tcl script for re-creating the current project

  # Argument Usage:
  # [-paths_relative_to <arg> = Script output directory path]: Override the reference directory variable for source file relative paths
  # [-target_proj_dir <arg> = Current project directory path]: Directory where the project needs to be restored
  # [-force]: Overwrite existing tcl script file
  # [-all_properties]: Write all properties (default & non-default) for the project object(s)
  # [-no_copy_sources]: Do not import sources even if they were local in the original project
  # [-absolute_path]: Make all file paths absolute wrt the original project directory
  # [-dump_project_info]: Write object values
  # file: Name of the tcl script file to generate

  # Return Value:
  # true (0) if success, false (1) otherwise

  # reset global variables
  variable a_global_vars
  reset_global_vars


  # process options
  for {set i 0} {$i < [llength $args]} {incr i} {
    set option [string trim [lindex $args $i]]
    switch -regexp -- $option {
      "-paths_relative_to"    { incr i;set a_global_vars(s_relative_to) [file normalize [lindex $args $i]] }
      "-target_proj_dir"      { incr i;set a_global_vars(s_target_proj_dir) [lindex $args $i] }
      "-force"                { set a_global_vars(b_arg_force) 1 }
      "-all_properties"       { set a_global_vars(b_arg_all_props) 1 }
      "-no_copy_sources"      { set a_global_vars(b_arg_no_copy_srcs) 1 }
      "-absolute_path"        { set a_global_vars(b_absolute_path) 1 }
      "-dump_project_info"    { set a_global_vars(b_arg_dump_proj_info) 1 }
      default {
	# is incorrect switch specified?
	if { [regexp {^-} $option] } {
	  send_msg_id Vivado-projutils-001 ERROR "Unknown option '$option', please type 'write_project_tcl -help' for usage info.\n"
	  return
	}
	set a_global_vars(script_file) $option
      }
    }
  }

  # script file is a must
  if { [string equal $a_global_vars(script_file) ""] } {
    send_msg_id Vivado-projutils-002 ERROR \
    "Missing value for option 'file', please type 'write_project_tcl -help' for usage info.\n"
    return
  }

  # should not be a directory
  if { [file isdirectory $a_global_vars(script_file)] } {
    send_msg_id Vivado-projutils-003 ERROR \
    "The specified filename is a directory ($a_global_vars(script_file)), please type 'write_project_tcl -help' for usage info.\n"
    return
  }

  # check extension
  if { [file extension $a_global_vars(script_file)] != ".tcl" } {
    set a_global_vars(script_file) $a_global_vars(script_file).tcl
  }
  set a_global_vars(script_file) [file normalize $a_global_vars(script_file)]

  # error if file directory path does not exist
  set file_path [file dirname $a_global_vars(script_file)]
  if { ! [file exists $file_path] } {
    set script_filename [file tail $a_global_vars(script_file)]
    send_msg_id Vivado-projutils-013 ERROR \
    "Directory in which file ${script_filename} is to be written does not exist \[$a_global_vars(script_file)\]\n"
    return
  }

  # recommend -force if file exists
  if { [file exists $a_global_vars(script_file)] && !$a_global_vars(b_arg_force) } {
    send_msg_id Vivado-projutils-004 ERROR \
    "Tcl Script '$a_global_vars(script_file)' already exist. Use -force option to overwrite.\n"
    return
  }

  # set script file directory path
  set a_global_vars(s_path_to_script_dir) [file normalize $file_path]


  puts "write_tcl correctly overridden"
  puts "WRITING in $a_global_vars(script_file)"


  # now write
  if {[write_project_tcl_script]} { return }

#  puts " WRITING ALL LOCAL FILES in $::srcdir "
#  ::ls_all_local_files
#  ::copy_all_local_files $::srcdir/project_src/$::make_env(soc_board).srcs

}
}


namespace eval ::tclapp::xilinx::projutils {



proc wr_create_project { proj_dir name part_name } {
  # Summary: write create project command
  # This helper command is used to script help.
  # Argument Usage:
  # proj_dir: project directory path
  # name: project name
  # Return Value:
  # none

  variable a_global_vars
  variable l_script_data
  variable make_env
  variable project_env
  variable project_set


  # ADD MAKE_ENV
  lappend l_script_data ""
  lappend l_script_data " ## MAKE_ENV ## "
  lappend l_script_data {*}$make_env(self)
  lappend l_script_data ""
  lappend l_script_data ""

  lappend l_script_data "# Set the reference directory for source file relative paths (by default the value is script directory path)"
##  lappend l_script_data "set origin_dir \"$a_global_vars(s_relative_to)\""
  lappend l_script_data "set origin_dir \"\$make_env(srcdir)\""

  lappend l_script_data ""
  set var_name "origin_dir_loc"
  lappend l_script_data "# Use origin directory path location variable, if specified in the tcl shell"
  lappend l_script_data "if \{ \[info exists ::$var_name\] \} \{"
  lappend l_script_data "  set origin_dir \$::$var_name"
  lappend l_script_data "\}"

  lappend l_script_data ""

  lappend l_script_data "variable script_file"
  lappend l_script_data "set script_file \"[file tail $a_global_vars(script_file)]\"\n"
  lappend l_script_data "# Help information for this script"
  lappend l_script_data "proc help \{\} \{"
  lappend l_script_data "  variable script_file"
  lappend l_script_data "  puts \"\\nDescription:\""
  lappend l_script_data "  puts \"Recreate a Vivado project from this script. The created project will be\""
  lappend l_script_data "  puts \"functionally equivalent to the original project for which this script was\""
  lappend l_script_data "  puts \"generated. The script contains commands for creating a project, filesets,\""
  lappend l_script_data "  puts \"runs, adding/importing sources and setting properties on various objects.\\n\""
  lappend l_script_data "  puts \"Syntax:\""
  lappend l_script_data "  puts \"\$script_file\""
  lappend l_script_data "  puts \"\$script_file -tclargs \\\[--origin_dir <path>\\\]\""
  lappend l_script_data "  puts \"\$script_file -tclargs \\\[--help\\\]\\n\""
  lappend l_script_data "  puts \"Usage:\""
  lappend l_script_data "  puts \"Name                   Description\""
  lappend l_script_data "  puts \"-------------------------------------------------------------------------\""
  lappend l_script_data "  puts \"\\\[--origin_dir <path>\\\]  Determine source file paths wrt this path. Default\""
  lappend l_script_data "  puts \"                       origin_dir path value is \\\".\\\", otherwise, the value\""
  lappend l_script_data "  puts \"                       that was set with the \\\"-paths_relative_to\\\" switch\""
  lappend l_script_data "  puts \"                       when this script was generated.\\n\""
  lappend l_script_data "  puts \"\\\[--help\\\]               Print help information for this script\""
  lappend l_script_data "  puts \"-------------------------------------------------------------------------\\n\""
  lappend l_script_data "  exit 0"
  lappend l_script_data "\}\n"
  lappend l_script_data "if \{ \$::argc > 0 \} \{"
  lappend l_script_data "  for \{set i 0\} \{\$i < \[llength \$::argc\]\} \{incr i\} \{"
  lappend l_script_data "    set option \[string trim \[lindex \$::argv \$i\]\]"
  lappend l_script_data "    switch -regexp -- \$option \{"
  lappend l_script_data "      \"--origin_dir\" \{ incr i; set origin_dir \[lindex \$::argv \$i\] \}"
  lappend l_script_data "      \"--help\"       \{ help \}"
  lappend l_script_data "      default \{"
  lappend l_script_data "        if \{ \[regexp \{^-\} \$option\] \} \{"
  lappend l_script_data "          puts \"ERROR: Unknown option '\$option' specified, please type '\$script_file -tclargs --help' for usage info.\\n\""
  lappend l_script_data "          return 1"
  lappend l_script_data "        \}"
  lappend l_script_data "      \}"
  lappend l_script_data "    \}"
  lappend l_script_data "  \}"
  lappend l_script_data "\}\n"

  lappend l_script_data "# Set the directory path for the original project from where this script was exported"
  if { $a_global_vars(b_absolute_path) } {
    lappend l_script_data "set orig_proj_dir \"$proj_dir\""
  } else {
    set rel_file_path "[get_relative_file_path_for_source $proj_dir [get_script_execution_dir]]"
    set path "\[file normalize \"\$origin_dir/$rel_file_path\"\]"
    lappend l_script_data "set orig_proj_dir \"$path\""
  }
  lappend l_script_data ""


  # create project
  lappend l_script_data "# Create project"

  set tcl_cmd ""
  # set target project directory path if specified. If not, create project dir in current dir.
  set target_dir $a_global_vars(s_target_proj_dir)
  if { {} == $target_dir } {
    set tcl_cmd "create_project $name ./$name -part $part_name"
  } else {
    # is specified target proj dir == current dir?
    set cwd [file normalize [string map {\\ /} [pwd]]]
    set dir [file normalize [string map {\\ /} $target_dir]]
    if { [string equal $cwd $dir] } {
      set tcl_cmd "create_project $name -part $part_name"
    } else {
      set tcl_cmd "create_project $name \"$target_dir\" -part $part_name"
    }
  }

  if { [get_property managed_ip [current_project]] } {
    set tcl_cmd "$tcl_cmd -ip"
  }
  lappend l_script_data $tcl_cmd

  if { $a_global_vars(b_arg_dump_proj_info) } {
    puts $a_global_vars(dp_fh) "project_name=$name"
  }

  lappend l_script_data ""
  lappend l_script_data "# Set the directory path for the new project"
  lappend l_script_data "set proj_dir \[get_property directory \[current_project\]\]"

  lappend l_script_data ""
  lappend l_script_data "# Reconstruct message rules"

  set msg_control_rules [ debug::get_msg_control_rules -as_tcl ]
  if { [string length $msg_control_rules] > 0 } {
    lappend l_script_data "${msg_control_rules}"
  } else {
    lappend l_script_data "# None"
  }
  lappend l_script_data ""
}




## ////////////////////////////////////////////////////////////////////////// ##
## ///  WRITE FILESET  ////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

proc write_specified_fileset { proj_dir proj_name filesets } {
  # Summary: write fileset properties and sources
  # This helper command is used to script help.
  # Argument Usage:
  # proj_name: project name
  # filesets: list of filesets
  # Return Value:
  # None

  variable a_global_vars
  variable l_script_data
  variable a_fileset_types
  variable make_env

  # write filesets
  set type "file"
  foreach tcl_obj $filesets {

    # Is this a IP block fileset for a proxy IP that is owned by another composite file?
    # If so, we don't want to write it out as an independent file. The parent will take care of it.
    if { [is_proxy_ip_fileset $tcl_obj] } {
      continue
    }

    set fs_type [get_property fileset_type [get_filesets $tcl_obj]]

    # is this a IP block fileset? if yes, do not create block fileset, but create for a pure HDL based fileset (no IP's)
    if { [is_ip_fileset $tcl_obj] } {
      # do not create block fileset
    } else {
      lappend l_script_data "# Create '$tcl_obj' fileset (if not found)"
      lappend l_script_data "if \{\[string equal \[get_filesets -quiet $tcl_obj\] \"\"\]\} \{"

      set fs_sw_type [get_fileset_type_switch $fs_type]
      lappend l_script_data "  create_fileset $fs_sw_type $tcl_obj"
      lappend l_script_data "\}\n"
    }

    set get_what_fs "get_filesets"

    # set IP REPO PATHS (if any) for filesets of type "DesignSrcs" or "BlockSrcs"
    if { (({DesignSrcs} == $fs_type) || ({BlockSrcs} == $fs_type)) } {
      if { ({RTL} == [get_property design_mode [get_filesets $tcl_obj]]) } {
	set repo_paths [get_ip_repo_paths $tcl_obj]
	if { [llength $repo_paths] > 0 } {
	  lappend l_script_data "# Set IP repository paths"
	  lappend l_script_data "set obj \[get_filesets $tcl_obj\]"
	  set path_list [list]
	  foreach path $repo_paths {
	    if { $a_global_vars(b_absolute_path) } {
	      lappend path_list $path
	    } else {
	      set rel_file_path "[get_relative_file_path_for_source $path $make_env(srcdir)]"
	      set path "\[file normalize \"\$origin_dir/$rel_file_path\"\]"
	      lappend path_list $path
	    }
	  }
	  set repo_path_str [join $path_list " "]
	  lappend l_script_data "set_property \"ip_repo_paths\" \"${repo_path_str}\" \$obj"
	  lappend l_script_data ""
	  lappend l_script_data "# Rebuild user ip_repo's index before adding any source files"
	  lappend l_script_data "update_ip_catalog -rebuild"
	  lappend l_script_data ""
	}
      }
    }

    # is this a IP block fileset? if yes, then set the current srcset object (IP's will be added to current source fileset)
    if { [is_ip_fileset $tcl_obj] } {
      # IP
      set srcset [current_fileset -srcset]
      lappend l_script_data "# Set '$srcset' fileset object"
      lappend l_script_data "set obj \[$get_what_fs $srcset\]"
    } else {
      # NOT IP
      lappend l_script_data "# Set '$tcl_obj' fileset object"
      lappend l_script_data "set obj \[$get_what_fs $tcl_obj\]"
    }
    if { {Constrs} == $fs_type } {
      lappend l_script_data ""
      #### WRITE_CONSTRAINTS ->
      write_constrs $proj_dir $proj_name $tcl_obj $type
    } else {
      #### WRITE_FILES ->
      write_files $proj_dir $proj_name $tcl_obj $type
    }

    # is this a IP block fileset? if yes, do not write block fileset properties (block fileset doesnot exist in new project)
    if { [is_ip_fileset $tcl_obj] } {
      # do not write ip fileset properties
    } else {
      lappend l_script_data "# Set '$tcl_obj' fileset properties"
      lappend l_script_data "set obj \[$get_what_fs $tcl_obj\]"
      write_props $proj_dir $proj_name $get_what_fs $tcl_obj "fileset"
    }
  }
}




## ////////////////////////////////////////////////////////////////////////// ##
## ///  WRITE FILES  //////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##


proc write_files { proj_dir proj_name tcl_obj type } {
  # Summary: write file and file properties
  # This helper command is used to script help.
  # Argument Usage:
  # Return Value:
  # none

  variable a_global_vars
  variable l_script_data
  variable make_env
  variable project_env
  variable project_set

  set l_local_file_list [list]
  set l_remote_file_list [list]

  # return if empty fileset
  if {[llength [get_files -quiet -of_objects [get_filesets $tcl_obj]]] == 0 } {
    lappend l_script_data "# Empty (no sources present)\n"
    return
  }
  set fs_name [get_filesets $tcl_obj]
  set import_coln [list]
  set add_file_coln [list]

  foreach file [get_files -norecurse -of_objects [get_filesets $tcl_obj]] {
    if { [file extension $file] == ".xcix" } { continue }
    set path_dirs [split [string trim [file normalize [string map {\\ /} $file]]] "/"]
    set begin [lsearch -exact $path_dirs "$proj_name.srcs"]
    set src_file [join [lrange $path_dirs $begin+1 end] "/"]
    set file_no_quotes [string trim $file "\""]
    set src_file_path "$project_set(dir_src)/$src_file"
    set file_object [lindex [get_files -of_objects [get_filesets $fs_name] [list $file]] 0]
    set file_props [list_property $file_object]
    if { [lsearch $file_props "IMPORTED_FROM"] != -1 } {
      ###          ###
      ### IMPORTED ###
      ###          ###
      set imported_path [get_property "imported_from" $file]
      set rel_file_path [get_relative_file_path_for_source $file [get_script_execution_dir]]
      set proj_file_path "\$origin_dir/$rel_file_path"
      set file "\"[file normalize $proj_dir/${proj_name}.srcs/$src_file]\""

      if { $a_global_vars(b_arg_no_copy_srcs) } {
	# add to the local collection
	lappend l_remote_file_list $file
	if { $a_global_vars(b_absolute_path) } {
	  lappend add_file_coln "$file"
	} else {
	  lappend add_file_coln "\"\[file normalize \"$proj_file_path\"\]\""
	}
      } else {
	# add to the import collection
	lappend l_local_file_list $file
	if { $a_global_vars(b_absolute_path) } {
	  lappend import_coln "$file"
	} else {
	  puts " loc -> import_location: $src_file"
	  file mkdir [file dirname $imported_path]
	  # TODO: discriminare local sources
	  ## COPY ##
	  puts "cpimp $file_no_quotes $src_file_path"
	  file copy -force $file_no_quotes $imported_path
	  lappend import_coln "\"\[file normalize \"$imported_path\"\]\""
	}
      }
    } else {
      if { !$a_global_vars(b_arg_no_copy_srcs) && [is_local_to_project $file] } {
	###          ###
	### LOCAL    ###
	###          ###
	puts "-> local: $src_file"
	if { $a_global_vars(b_arg_dump_proj_info) } {
	  set src_file "\$PSRCDIR/$src_file"
	}
	## COPY ##
	file mkdir [file dirname [subst $src_file_path]]
	file copy -force $file_no_quotes [subst $src_file_path]
	if { [get_property "FILE_TYPE" $file_object] eq "Block Designs" } {
	  puts "WRITING BD in TCL"
	  open_bd_design $file_no_quotes
	  validate_bd_design
	  write_bd_tcl -force [file root [subst $src_file_path]]_$project_env(VIVADO_VERSION).tcl
	}
	#	set src_file_path [copy_file_to_srcdir $file_no_quotes $fs_name]
	# add to the import collection
	lappend import_coln "\"\[file normalize \"$src_file_path\"\]\""
	lappend l_local_file_list $file
      } else {
	###          ###
	### REMOTE   ###
	###          ###
	puts "-> remote: $src_file"
	lappend l_remote_file_list $file
	lappend add_file_coln "$file"
      }
      # set flag that local sources were found and print warning at the end
      if { !$a_global_vars(b_local_sources) } {
	set a_global_vars(b_local_sources) 1
      }
    }
  }
  ###
  ### IMPORT LOCALS
  ###
  if { ! $a_global_vars(b_arg_no_copy_srcs)} {
    if { [llength $import_coln] > 0 } {
      lappend l_script_data "# Import local files from the original project"
      lappend l_script_data "set files \[list \\"
      foreach ifile $import_coln {
	lappend l_script_data " $ifile\\"
      }
      lappend l_script_data "\]"
      # is this a IP block fileset? if yes, import files into current source fileset
      if { [is_ip_fileset $tcl_obj] } {
	lappend l_script_data "set imported_files \[import_files -fileset [current_fileset -srcset] \$files\]"
      } else {
	lappend l_script_data "set imported_files \[import_files -fileset $tcl_obj \$files\]"
      }
      lappend l_script_data ""
    }
  }
  ###
  ### ADD FILES
  ###
  if {[llength $add_file_coln]>0} {
    lappend l_script_data "set files \[list \\"
    foreach file $add_file_coln {
      if { $a_global_vars(b_absolute_path) } {
	lappend l_script_data " $file\\"
      } else {
	if { $a_global_vars(b_arg_no_copy_srcs) } {
	  lappend l_script_data " $file\\"
	} else {
	  set file_no_quotes [string trim $file "\""]
	  set rel_file_path [get_relative_file_path_for_source $file_no_quotes [get_script_execution_dir]]
	  lappend l_script_data " \"\[file normalize \"\$origin_dir/$rel_file_path\"\]\"\\"
	}
      }
    }
    lappend l_script_data "\]"
    lappend l_script_data "add_files -norecurse -fileset \$obj \$files"
    lappend l_script_data ""
  }

  # write fileset file properties for remote files (added sources)
  write_fileset_file_properties $tcl_obj $fs_name $proj_dir $l_remote_file_list "remote"
  # write fileset file properties for local files (imported sources)
  write_fileset_file_properties $tcl_obj $fs_name $proj_dir $l_local_file_list "local"
}





## ////////////////////////////////////////////////////////////////////////// ##
## ///  WRITE CONSTRAINTS  ////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##


proc write_constrs { proj_dir proj_name tcl_obj type } {
  # Summary: write constrs fileset files and properties
  # Argument Usage:
  # Return Value:
  # none

  variable a_global_vars
  variable l_script_data
  variable make_env
  variable project_env
  variable project_set


  set fs_name [get_filesets $tcl_obj]

  # return if empty fileset
  if {[llength [get_files -quiet -of_objects [get_filesets $tcl_obj]]] == 0 } {
    lappend l_script_data "# Empty (no sources present)\n"
    return
  }


  foreach file [get_files -norecurse -of_objects [get_filesets $tcl_obj]] {
    lappend l_script_data "# Add/Import constrs file and set constrs file properties"
    set constrs_file  {}
    set file_category {}
    set path_dirs     [split [string trim [file normalize [string map {\\ /} $file]]] "/"]
    set begin         [lsearch -exact $path_dirs "$proj_name.srcs"]
    set src_file      [join [lrange $path_dirs $begin+1 end] "/"]
    set file_no_quotes [string trim $file "\""]
    set src_file_path "\$origin_dir/$src_file"
    set file_object   [lindex [get_files -of_objects [get_filesets $fs_name] [list $file]] 0]
    set file_props    [list_property $file_object]

    # constrs sources imported?
    if { [lsearch $file_props "IMPORTED_FROM"] != -1 } {
      set imported_path  [get_property "imported_from" $file]
      set rel_file_path  [get_relative_file_path_for_source $file $make_env(srcdir)]
      set proj_file_path "$project_set(dir_src)/$rel_file_path"
      set file           "\"[file normalize $proj_dir/${proj_name}.srcs/$src_file]\""
      # donot copy imported constrs in new project? set it as remote file in new project.
      if { $a_global_vars(b_arg_no_copy_srcs) } {
	set constrs_file $file
	set file_category "remote"
	if { $a_global_vars(b_absolute_path) } {
	  add_constrs_file "$file"
	} else {
	  set str "\"\[file normalize \"$proj_file_path\"\]\""
	  add_constrs_file $str
	}
      } else {
	# copy imported constrs in new project. Set it as local file in new project.
	set constrs_file $file
	set file_category "local"
	file mkdir [file dirname $imported_path]
	# TODO: discriminare local sources
	file copy -force $file_no_quotes $imported_path
	if { $a_global_vars(b_absolute_path) } {
	  import_constrs_file $tcl_obj "$file"
	} else {
	  set str "\"\[file normalize \"$imported_path\"\]\""
	  import_constrs_file $tcl_obj $str
	}
      }
    } else {
      # constrs sources were added, so check if these are local or added from remote location
      #      set file "\"$file\""
      set constrs_file $file

      # is added constrs local to the project? import it in the new project and set it as local in the new project
      if { !$a_global_vars(b_arg_no_copy_srcs) && [is_local_to_project $file] } {
	# file is added from within project, so set it as local in the new project
	set file_category "local"

	if { $a_global_vars(b_arg_dump_proj_info) } {
	  set src_file "\$PSRCDIR/$src_file"
	}
	file mkdir [file dirname [subst $src_file_path]]
	file copy -force $file_no_quotes [subst $src_file_path]
	#set src_file_path [copy_file_to_srcdir $file_no_quotes $fs_name]
	set str "\"\[file normalize \"$src_file_path\"\]\""
	if { $a_global_vars(b_arg_no_copy_srcs)} {
	  add_constrs_file "$str"
	} else {
	  import_constrs_file $tcl_obj $str
	}
      } else {
	# file is added from remote location, so set it as remote in the new project
	set file_category "remote"

	# find relative file path of the added constrs if no_copy in the new project
	if { $a_global_vars(b_arg_no_copy_srcs) && (!$a_global_vars(b_absolute_path)) } {
	  set file_no_quotes [string trim $file "\""]
	  set rel_file_path [get_relative_file_path_for_source $file_no_quotes $make_env(srcdir)]
	  set file_1 "\"\[file normalize \"\$origin_dir/$rel_file_path\"\]\""
	  add_constrs_file "$file_1"
	} else {
	  add_constrs_file "$file"
	}
      }

      # set flag that local sources were found and print warning at the end
      if { !$a_global_vars(b_local_sources) } {
	set a_global_vars(b_local_sources) 1
      }
    }
    write_constrs_fileset_file_properties $tcl_obj $fs_name $proj_dir $constrs_file $file_category
  }
}


proc add_constrs_file { file_str } {
  # Summary: add constrs file
  # This helper command is used to script help.
  # Argument Usage:
  # Return Value:
  # none

  variable a_global_vars
  variable l_script_data
  variable make_env

  if { $a_global_vars(b_absolute_path) } {
    lappend l_script_data "set file $file_str"
  } else {
    if { $a_global_vars(b_arg_no_copy_srcs) } {
      lappend l_script_data "set file $file_str"
    } else {
      set file_no_quotes [string trim $file_str "\""]
      set rel_file_path [get_relative_file_path_for_source $file_no_quotes $make_env(srcdir)]
      lappend l_script_data "set file \"\[file normalize \"\$origin_dir/$rel_file_path\"\]\""
    }
  }
  lappend l_script_data "set file_added \[add_files -norecurse -fileset \$obj \$file\]"
}




## ////////////////////////////////////////////////////////////////////////// ##
## //  WRITE PROPS   //////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##


proc write_props { proj_dir proj_name get_what tcl_obj type } {
  # Summary: write first class object properties
  # This helper command is used to script help.
  # Argument Usage:
  # Return Value:
  # none

  variable a_global_vars
  variable l_script_data
  variable b_project_board_set

  set obj_name [get_property name [$get_what $tcl_obj]]
  set read_only_props [rdi::get_attr_specs -class [get_property class $tcl_obj] -filter {is_readonly}]
  set prop_info_list [list]
  set properties [list_property [$get_what $tcl_obj]]

  foreach prop $properties {
    if { [is_deprecated $prop] } { continue }

    # skip read-only properties
    if { [lsearch $read_only_props $prop] != -1 } { continue }

    set prop_type "unknown"
    if { [string equal $type "run"] } {
      if { [regexp "STEPS" $prop] } {
	# skip step properties
      } else {
	set attr_names [rdi::get_attr_specs -class [get_property class [get_runs $tcl_obj] ]]
	set prop_type [get_property type [lindex $attr_names [lsearch $attr_names $prop]]]
      }
    } else {
      set attr_spec [rdi::get_attr_specs -quiet $prop -object [$get_what $tcl_obj]]
      if { {} == $attr_spec } {
	set prop_lower [string tolower $prop]
	set attr_spec [rdi::get_attr_specs -quiet $prop_lower -object [$get_what $tcl_obj]]
      }
      set prop_type [get_property type $attr_spec]
    }
    set def_val [list_property_value -default $prop $tcl_obj]
    set dump_prop_name [string tolower ${obj_name}_${type}_$prop]
    set cur_val [get_property $prop $tcl_obj]

    # filter special properties
    if { [filter $prop $cur_val] } { continue }

    # do not set "runs" or "project" part, if "board_part" is set
    if { ([string equal $type "project"] || [string equal $type "run"]) &&
	 [string equal -nocase $prop "part"] &&
	 $b_project_board_set } {
      continue
    }

    # do not set "fileset" target_part, if "board_part" is set
    if { [string equal $type "fileset"] &&
	 [string equal -nocase $prop "target_part"] &&
	 $b_project_board_set } {
      continue
    }

    # re-align values
    set cur_val [get_target_bool_val $def_val $cur_val]

    set prop_entry "[string tolower $prop]#[get_property $prop [$get_what $tcl_obj]]"

    # fix paths wrt the original project dir
    if {([string equal -nocase $prop "top_file"]) && ($cur_val != "") } {
      set file $cur_val

      set srcs_dir "${proj_name}.srcs"
      set file_dirs [split [string trim [file normalize [string map {\\ /} $file]]] "/"]
      set src_file [join [lrange $file_dirs [lsearch -exact $file_dirs "$srcs_dir"] end] "/"]

      if { [is_local_to_project $file] } {
	set proj_file_path "\$proj_dir/$src_file"
      } else {
	set proj_file_path "[get_relative_file_path_for_source $src_file [get_script_execution_dir]]"
      }
      set prop_entry "[string tolower $prop]#$proj_file_path"

    } elseif {([string equal -nocase $prop "target_constrs_file"] ||
	       [string equal -nocase $prop "target_ucf"]) &&
	       ($cur_val != "") } {

      set file $cur_val
      set fs_name $tcl_obj

      set path_dirs [split [string trim [file normalize [string map {\\ /} $file]]] "/"]
      set src_file [join [lrange $path_dirs [lsearch -exact $path_dirs "$fs_name"] end] "/"]
      set file_object [lindex [get_files -of_objects [get_filesets $fs_name] [list $file]] 0]
      set file_props [list_property $file_object]

      if { [lsearch $file_props "IMPORTED_FROM"] != -1 } {
	if { $a_global_vars(b_arg_no_copy_srcs) } {
	  set proj_file_path \$orig_proj_dir/${proj_name}.srcs/$src_file
	} else {
	  set proj_file_path \$proj_dir/${proj_name}.srcs/$src_file
	}
      } else {
	# is file new inside project?
	if { [is_local_to_project $file]  } {
	  # is file inside fileset dir?

	  if { !$a_global_vars(b_arg_no_copy_srcs) && [regexp "^${fs_name}/" $src_file] } {
	    set unique1 {\|\|=>}
	    set unique2 {<=\|\|}
	    set string {rand ||=> this is some text <=|| rand}
	    set replacement {some other text}
	    set import_file [regsub -- "(^${fs_name}/)(.*)" $src_file "\\1imports/\\2"]
	    #	    set proj_file_path \$orig_proj_dir/${proj_name}.srcs/$src_file
	    set proj_file_path \$orig_proj_dir/${proj_name}.srcs/$import_file
	  } else {
	    set file_no_quotes [string trim $file "\""]
	    set rel_file_path [get_relative_file_path_for_source $file_no_quotes [get_script_execution_dir]]
	    set proj_file_path "\[file normalize \"\$origin_dir/$rel_file_path\"\]"
	    #set proj_file_path "$file"
	  }
	} else {
	  if { $a_global_vars(b_absolute_path) } {
	    set proj_file_path "$file"
	  } else {
	    set file_no_quotes [string trim $file "\""]
	    set rel_file_path [get_relative_file_path_for_source $file_no_quotes [get_script_execution_dir]]
	    set proj_file_path "\[file normalize \"\$origin_dir/$rel_file_path\"\]"
	  }
	}
      }

      set prop_entry "[string tolower $prop]#$proj_file_path"
    }


    # re-align compiled_library_dir
    if { [string equal -nocase $prop "compxlib.compiled_library_dir"] ||
	 [string equal -nocase $prop "compxlib.modelsim_compiled_library_dir"] ||
	 [string equal -nocase $prop "compxlib.questa_compiled_library_dir"] ||
	 [string equal -nocase $prop "compxlib.ies_compiled_library_dir"] ||
	 [string equal -nocase $prop "compxlib.vcs_compiled_library_dir"] ||
	 [string equal -nocase $prop "compxlib.riviera_compiled_library_dir"] ||
	 [string equal -nocase $prop "compxlib.activehdl_compiled_library_dir"] } {
      set compile_lib_dir_path $cur_val
      set cache_dir "${proj_name}.cache"
      set path_dirs [split [string trim [file normalize [string map {\\ /} $cur_val]]] "/"]
      if {[lsearch -exact $path_dirs "$cache_dir"] > 0} {
	set dir_path [join [lrange $path_dirs [lsearch -exact $path_dirs "$cache_dir"] end] "/"]
	set compile_lib_dir_path "\$proj_dir/$dir_path"
      }
      set prop_entry "[string tolower $prop]#$compile_lib_dir_path"
    }

    # process run step tcl pre/post properties
    if { [string equal $type "run"] } {
      if { [regexp "STEPS" $prop] } {
	if { [regexp "TCL.PRE" $prop] || [regexp "TCL.POST" $prop] } {
	  if { ($cur_val != "") } {
	    set file $cur_val

	    set srcs_dir "${proj_name}.srcs"
	    set file_dirs [split [string trim [file normalize [string map {\\ /} $file]]] "/"]
	    set src_file [join [lrange $file_dirs [lsearch -exact $file_dirs "$srcs_dir"] end] "/"]

	    set tcl_file_path {}
	    if { [is_local_to_project $file] } {
	      set tcl_file_path "\$proj_dir/$src_file"
	    } else {
	      if { $a_global_vars(b_absolute_path) } {
		set tcl_file_path "$file"
	      } else {
		set rel_file_path "[get_relative_file_path_for_source $src_file [get_script_execution_dir]]"
		set tcl_file_path "\[file normalize \"\$origin_dir/$rel_file_path\"\]"
	      }
	    }
	    set prop_entry "[string tolower $prop]#$tcl_file_path"
	  }
	}
      }
    }

    if { $a_global_vars(b_arg_all_props) } {
      lappend prop_info_list $prop_entry
    } else {
      if { $def_val != $cur_val } {
	lappend prop_info_list $prop_entry
      }
    }

    if { $a_global_vars(b_arg_dump_proj_info) } {
      if { ([string equal -nocase $prop "top_file"] ||
	    [string equal -nocase $prop "target_constrs_file"] ||
	    [string equal -nocase $prop "target_ucf"] ) && [string equal $type "fileset"] } {

	# fix path
	set file $cur_val

	set srcs_dir "${proj_name}.srcs"
	set file_dirs [split [string trim [file normalize [string map {\\ /} $file]]] "/"]
	set src_file [join [lrange $file_dirs [lsearch -exact $file_dirs "$srcs_dir"] end] "/"]
	set cur_val "\$PSRCDIR/$src_file"
      }
      puts $a_global_vars(def_val_fh) "$prop:($prop_type) DEFAULT_VALUE ($def_val)==CURRENT_VALUE ($cur_val)"
      puts $a_global_vars(dp_fh) "${dump_prop_name}=$cur_val"
    }
  }

  if { {fileset} == $type } {
    set fs_type [get_property fileset_type [get_filesets $tcl_obj]]
    if { {SimulationSrcs} == $fs_type } {
      if { ![get_property is_readonly [current_project]] } {
	add_simulator_props $get_what $tcl_obj prop_info_list
      }
    }
  }

  # write properties now
  write_properties $prop_info_list $get_what $tcl_obj
}


## ////////////////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##



proc write_fileset_file_properties { tcl_obj fs_name proj_dir l_file_list file_category } {
  # Summary:
  # Write fileset file properties for local and remote files
  # Argument Usage:
  # tcl_obj: object to inspect
  # fs_name: fileset name
  # l_file_list: list of files (local or remote)
  # file_category: file catwgory (local or remote)
  # Return Value:
  # none

  variable a_global_vars
  variable l_script_data
  variable l_local_files
  variable l_remote_files

  # is this a IP block fileset? if yes, set current source fileset
  if { [is_ip_fileset $tcl_obj] } {
    lappend l_script_data "# Set '[current_fileset -srcset]' fileset file properties for $file_category files"
  } else {
    lappend l_script_data "# Set '$tcl_obj' fileset file properties for $file_category files"
  }
  set file_prop_count 0

  # collect local/remote files
  foreach file $l_file_list {
    if { [string equal $file_category "local"] } {
      lappend l_local_files $file
    } elseif { [string equal $file_category "remote"] } {
      lappend l_remote_files $file
    } else {}
  }

  foreach file $l_file_list {
    set file [string trim $file "\""]

    # fix file path for local files
    if { [string equal $file_category "local"] } {
      set path_dirs [split [string trim [file normalize [string map {\\ /} $file]]] "/"]
      set src_file [join [lrange $path_dirs end-1 end] "/"]
      set src_file [string trimleft $src_file "/"]
      set src_file [string trimleft $src_file "\\"]
      set file $src_file
    }

    set file_object ""
    if { [string equal $file_category "local"] } {
      set file_object [lindex [get_files -of_objects [get_filesets $fs_name] [list "*$file"]] 0]
    } elseif { [string equal $file_category "remote"] } {
      set file_object [lindex [get_files -of_objects [get_filesets $fs_name] [list $file]] 0]
    }

    set file_props [list_property $file_object]
    set prop_info_list [list]
    set prop_count 0

    foreach file_prop $file_props {
      set is_readonly [get_property is_readonly [rdi::get_attr_specs $file_prop -object $file_object]]
      if { [string equal $is_readonly "1"] } {
	continue
      }

      set prop_type [get_property type [rdi::get_attr_specs $file_prop -object $file_object]]
      set def_val [list_property_value -default $file_prop $file_object]
      set cur_val [get_property $file_prop $file_object]

      # filter special properties
      if { [filter $file_prop $cur_val $file] } { continue }

      # re-align values
      set cur_val [get_target_bool_val $def_val $cur_val]

      set dump_prop_name [string tolower ${fs_name}_file_${file_prop}]
      set prop_entry ""
      if { [string equal $file_category "local"] } {
	set prop_entry "[string tolower $file_prop]#[get_property $file_prop $file_object]"
      } elseif { [string equal $file_category "remote"] } {
	set prop_value_entry [get_property $file_prop $file_object]
	set prop_entry "[string tolower $file_prop]#$prop_value_entry"
      } else {}

      if { $a_global_vars(b_arg_all_props) } {
	lappend prop_info_list $prop_entry
	incr prop_count
      } else {
	if { $def_val != $cur_val } {
	  lappend prop_info_list $prop_entry
	  incr prop_count
	}
      }

      if { $a_global_vars(b_arg_dump_proj_info) } {
      puts $a_global_vars(def_val_fh) "[file tail $file]=$file_prop `($prop_type) :DEFAULT_VALUE ($def_val)==CURRENT_VALUE ($cur_val)"
	puts $a_global_vars(dp_fh) "$dump_prop_name=$cur_val"
      }
    }

    # write properties now
    if { $prop_count>0 } {
      if { {remote} == $file_category } {
	if { $a_global_vars(b_absolute_path) } {
	  lappend l_script_data "set file \"$file\""
	} else {
	  lappend l_script_data "set file \"\$origin_dir/[get_relative_file_path_for_source $file [get_script_execution_dir]]\""
	  lappend l_script_data "set file \[file normalize \$file\]"
	}
      } else {
	lappend l_script_data "set file \"$file\""
      }
      # is this a IP block fileset? if yes, get files from current source fileset
      if { [is_ip_fileset $tcl_obj] } {
	lappend l_script_data "set file_obj \[get_files -of_objects \[get_filesets [current_fileset -srcset]\] \[list \"*\$file\"\]\]"
      } else {
	lappend l_script_data "set file_obj \[get_files -of_objects \[get_filesets $tcl_obj\] \[list \"*\$file\"\]\]"
      }
      set get_what "get_files"
      write_properties $prop_info_list $get_what $tcl_obj
      incr file_prop_count
    }
  }

  if { $file_prop_count == 0 } {
    lappend l_script_data "# None"
  }
  lappend l_script_data ""
}





proc print_local_file_msg { msg_type } {
  # Summary: print warning on finding local sources
  # This helper command is used to script help.
  # Argument Usage:
  # Return Value:
  # None

  puts ""
  #  if { [string equal $msg_type "warning"] } {
  #    send_msg_id Vivado-projutils-010 WARNING "Found source(s) that were local or imported into the project. If this project is being source controlled, then\n\
  #    please ensure that the project source(s) are also part of this source controlled data. The list of these local source(s) can be found in the generated script\n\
  #    under the header section."
  #  } else {
  #    send_msg_id Vivado-projutils-011 INFO "If this project is being source controlled, then please ensure that the project source(s) are also part of this source\n\
  #    controlled data. The list of these local source(s) can be found in the generated script under the header section."
  #  }
  puts ""
}


## ////////////////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##


proc write_constrs_fileset_file_properties { tcl_obj fs_name proj_dir file file_category } {
  # Summary: write constrs fileset file properties
  # This helper command is used to script help.
  # Argument Usage:
  # Return Value:
  # none

  variable a_global_vars
  variable l_script_data
  variable l_local_files
  variable l_remote_files
  variable make_env

  set file_prop_count 0

  # collect local/remote files for the header section
  if { [string equal $file_category "local"] } {
    lappend l_local_files $file
  } elseif { [string equal $file_category "remote"] } {
    lappend l_remote_files $file
  }

  set file [string trim $file "\""]

  # fix file path for local files
  if { [string equal $file_category "local"] } {
    set path_dirs [split [string trim [file normalize [string map {\\ /} $file]]] "/"]
    set src_file [join [lrange $path_dirs end-1 end] "/"]
    set src_file [string trimleft $src_file "/"]
    set src_file [string trimleft $src_file "\\"]
    set file $src_file
  }

  set file_object ""
  if { [string equal $file_category "local"] } {
    set file_object [lindex [get_files -of_objects [get_filesets $fs_name] [list "*$file"]] 0]
  } elseif { [string equal $file_category "remote"] } {
    set file_object [lindex [get_files -of_objects [get_filesets $fs_name] [list $file]] 0]
  }

  # get the constrs file properties
  set file_props [list_property $file_object]
  set prop_info_list [list]
  set prop_count 0
  foreach file_prop $file_props {
    set is_readonly [get_property is_readonly [rdi::get_attr_specs $file_prop -object $file_object]]
    if { [string equal $is_readonly "1"] } {
      continue
    }
    set prop_type [get_property type [rdi::get_attr_specs $file_prop -object $file_object]]
    set def_val   [list_property_value -default $file_prop $file_object]
    set cur_val   [get_property $file_prop $file_object]

    # filter special properties
    if { [filter $file_prop $cur_val $file] } { continue }

    # re-align values
    set cur_val [get_target_bool_val $def_val $cur_val]

    set dump_prop_name [string tolower ${fs_name}_file_${file_prop}]
    set prop_entry ""
    if { [string equal $file_category "local"] } {
      set prop_entry "[string tolower $file_prop]#[get_property $file_prop $file_object]"
    } elseif { [string equal $file_category "remote"] } {
      set prop_value_entry [get_property $file_prop $file_object]
      set prop_entry "[string tolower $file_prop]#$prop_value_entry"
    }
    # include all properties?
    if { $a_global_vars(b_arg_all_props) } {
      lappend prop_info_list $prop_entry
      incr prop_count
    } else {
      # include only non-default (default behavior)
      if { $def_val != $cur_val } {
	lappend prop_info_list $prop_entry
	incr prop_count
      }
    }

    if { $a_global_vars(b_arg_dump_proj_info) } {
      puts $a_global_vars(def_val_fh) "[file tail $file]=$file_prop ($prop_type) :DEFAULT_VALUE ($def_val)==CURRENT_VALUE ($cur_val)"
      puts $a_global_vars(dp_fh) "$dump_prop_name=$cur_val"
    }
  }

  # write properties now
  if { $prop_count>0 } {
    if { {remote} == $file_category } {
      if { $a_global_vars(b_absolute_path) } {
	lappend l_script_data "set file \"$file\""
      } else {
	lappend l_script_data "set file \"\$origin_dir/[get_relative_file_path_for_source $file $make_env(srcdir)]\""
	lappend l_script_data "set file \[file normalize \$file\]"
      }
    } else {
      lappend l_script_data "set file \"$file\""
    }

    lappend l_script_data "set file_obj \[get_files -of_objects \[get_filesets $tcl_obj\] \[list \"*\$file\"\]\]"
    set get_what "get_files"
    write_properties $prop_info_list $get_what $tcl_obj
    incr file_prop_count
  }

  if { $file_prop_count == 0 } {
    lappend l_script_data "# None"
  }
}







}




























