package provide makeutils 1.0
package require Vivado 1.2014.1

global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)

namespace eval ::tclapp::socdev::makeutils {
  namespace export make_create_project
  namespace export make_open_project
  namespace export make_write_project
  namespace export reset_project_vars
  namespace export make_edit_peripheral
}

## INCLUDES ##
source -notrace $top_srcdir/fpga/vivado_socdev_env.tcl
source -notrace $top_srcdir/fpga/write_project_tcl_devel.tcl


namespace eval ::tclapp::socdev::makeutils {

## ////////////////////////////////////////////////////////////////////////// ##
## /// GLOBALS ////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

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

variable a_project_vars
proc reset_project_vars { } {
  variable make_env
  variable a_project_vars
  variable ::tclapp::xilinx::projutils::a_make_vars

  set a_project_vars(VIVADO_VERSION) $make_env(VIVADO_VERSION)
  set a_project_vars(project_name) $make_env(project_name)
  set a_project_vars(srcdir)       $make_env(srcdir)
  set a_project_vars(top_srcdir)   $make_env(top_srcdir)
  set a_project_vars(rel_dir_prj)  [get_rel_path vivado_project .]
  set a_project_vars(abs_dir_prj)  [get_abs_path vivado_project  ]
  set a_project_vars(rel_src_prj)  [get_rel_path $a_project_vars(srcdir)/vivado_src .]
  set a_project_vars(abs_src_prj)  [get_abs_path $a_project_vars(srcdir)/vivado_src  ]
  set a_project_vars(dir_src)      "hdl"
  set a_project_vars(dir_bd)       "bd"
  set a_project_vars(dir_sdc)      "sdc"

  set a_project_vars(sources_list) [split $make_env(SOURCES) " "]

  # save to projutils global variable
  array set a_make_vars [array get a_project_vars]
}
reset_project_vars



proc make_set_repo_path {} {
  variable make_env
  variable a_project_vars

  set path_list [list]
  foreach ip_name [split $make_env(IP_SOURCES) " "] {
    set ip_path [file normalize [file dirname $a_project_vars(srcdir)/$ip_name]]
    lappend path_list $ip_path
  }
  lappend path_list $make_env(ip_repo)
  if { [catch {current_project}] } { error "project not defined"
  } else { set_property ip_repo_paths [lsort -unique $path_list] [current_project] }
}

## ////////////////////////////////////////////////////////////////////////// ##
## /// CREATE PROJECT /////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

proc make_create_project { } {
  variable make_env
  variable a_project_vars

  set project_name $make_env(project_name)

  # setup a project
  create_project -part $make_env(VIVADO_SOC_PART) -force ${project_name} ./vivado_project
  if { [catch {current_project}] } { error "Could not start a new project" }
  reset_project_vars

  # setup common ip catalog
  #  set_property ip_repo_paths $make_env(ip_repo) [current_project]
  make_set_repo_path
  update_ip_catalog

  # create flows
  set vivado_major_num [lindex [split $make_env(VIVADO_VERSION) '.'] 0]
  set flow "Vivado Synthesis $vivado_major_num"
  create_run -flow $flow auto_synth_1
  set flow "Vivado Implementation $vivado_major_num"
  create_run auto_impl_1 -parent_run auto_synth_1 -flow $flow

  # load files
  make_load_sources

  # write project
  make_write_project
}


## ////////////////////////////////////////////////////////////////////////// ##
## /// EDIT PERIPHERAL ////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

proc make_edit_peripheral { } {
  variable a_project_vars
  variable make_env

  if { [catch {current_project}] } {
    create_project -in_memory -part $make_env(VIVADO_SOC_PART) -force _dummy_edit_ip
  }
  foreach ip_name [split $make_env(IP_SOURCES) " "] {
    set ip_path [file dirname $ip_name]
    set ip_name [file tail $ip_name]
    set missing_components [list]
    if {![file exists $a_project_vars(srcdir)/${ip_path}/$ip_name/component.xml]} {
	  #  set ip_name_seed    [join [lrange [split $ip_name "_"] 0 end-1] "_"]
	  #  set ip_name_version [lindex [split $ip_name "_"] end]
	  #  create_peripheral user.org user ${ip_name_seed} ${ip_name_version} \
	  #    -dir $a_project_vars(srcdir)/${ip_path}
	  #  ipx::create_core user.org user ${ip_name_seed} ${ip_name_version}
	  #  add_peripheral_interface S00_AXI -interface_mode slave -axi_type lite \
	  #    [ipx::find_open_core user.org:user:${ip_name_seed}:${ip_name_version}]
	  #  generate_peripheral -force \
	  #    [ipx::find_open_core user.org:user:${ip_name_seed}:${ip_name_version}]
	  #  write_peripheral [ipx::find_open_core user.org:user:${ip_name_seed}:${ip_name_version}]
	  lappend missing_components $ip_name
	  create_project -part $make_env(VIVADO_SOC_PART) -force $ip_name \
	    $a_project_vars(rel_dir_prj)/${ip_path}/${ip_name}_project
	} else {
	  ipx::edit_ip_in_project -upgrade true -name $ip_name \
	    -directory $a_project_vars(rel_dir_prj)/${ip_path}/${ip_name}_project \
	    $a_project_vars(srcdir)/${ip_path}/$ip_name/component.xml
	}
  }
  # Print warning message
  if { [llength missing_components] != 0 } {
    puts " "
    puts "  ------------------------------------------------------------------------- "
    puts " | Valid IP definitions were not found in the specified source  directory.  "
    puts " | The script will continue creating a generic vivado project that must be  "
    puts " | packed manually to a new ip using \"Tools->Create and Package IP\""
    puts " |   list of missing ip:"
    foreach ip $missing_components {
      set ip_name_seed    [join [lrange [split $ip "_"] 0 end-1] "_"]
      set ip_name_version [lindex [split $ip "_"] end]
      puts " |                      $ip_name_seed $ip_name_version"
    }
    puts "  ------------------------------------------------------------------------- "
  }
  if { [get_projects _dummy_edit_ip] != "" } {
    current_project _dummy_edit_ip
    close_project -quiet
  }
}


## ////////////////////////////////////////////////////////////////////////// ##
## /// OPEN PROJECT ///////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

# find file in directories
proc make_find_path {file} {
  variable make_env
  set file [string map {\\ /} $file]
  set src_relative $make_env(srcdir)/$file
  set bld_relative $file
  if {[file exists $bld_relative]} { set file $bld_relative }
  if {[file exists $src_relative]} { set file $src_relative }
  set full_path [string trim [file normalize $file]]
  foreach f [get_files] {
    if { [string trim [file normalize [string map {\\ /} $f]]] eq $full_path } {
      return
    }
 }
 return $file
}

# remove overlapping bd designs (the proprity goes to tcl imported scripts)
proc make_remove_bd_design { design_name } {
  set cur_design [current_bd_design -quiet]
  set list_cells [get_bd_cells -quiet]
  if { ${design_name} eq "" } {
     error "ERROR: Please set the variable <design_name> to a non-empty value."
  } elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
     close_bd_design ${cur_design}
  }
  if { [get_files -quiet ${design_name}.bd] ne "" } {
     remove_file [get_files -quiet ${design_name}.bd]
  }
}

# load remote sources
proc make_load_sources {} {
  variable make_env
  # refer to https://www.xilinx.com/itp/xilinx10/isehelp/ise_r_source_types.htm
  # import all remote sources
  if {!($make_env(SOURCES) eq "")} {
   foreach file [split $make_env(SOURCES) " "] {
     set ftype [file extension $file]
     set path [make_find_path $file]
     if {$path eq ""} {continue}
     switch -regexp $ftype {
       \.(v|V|verilog)\$         { read_verilog $path }
       \.(sv|SV)\$               { read_verilog -sv $path }
       \.(vhd|Vhd|vhdl|Vhdl)\$   { read_vhdl $path }
       \.(xdc|Xdc)\$             { read_xdc $path }
       \.(bd)\$                  { add_files $path }
     }
   }
  }
  # import all remote BD from TCL scripts
  if {!($make_env(BD_SOURCES) eq "")} {
   foreach file [split $make_env(BD_SOURCES) " "] {
     set ftype [file extension $file]
     set path [make_find_path $file]
     if {$path eq ""} {continue}
     switch -regexp $ftype {
       \.(tcl|Tcl)\$       { puts "INFO: reading design from TCL script..."
			     set err [source -quiet $path]
			     if { !($err eq "") } {
				  puts "INFO: the tcl design $design_name has priority over bd binary"
				  puts "      removed $design_name in project, replacing with $path"
				  make_remove_bd_design ${design_name}
				  set err [source -quiet $path]
				  if { !($err eq "") } { error $errMsg }
				}
			   }
       \.(bd)\$            { add_files $path }
     }
   }
  }
}

proc make_open_project {} {
  variable make_env
  variable a_project_vars
  set project_name $make_env(project_name)
  catch {::open_project -part $make_env(VIVADO_SOC_PART) \
	 $a_project_vars(rel_dir_prj)/$project_name.xpr}
  ## restore project from tcl script ##
  if { [catch {current_project}] } {
    set  ::origin_dir_loc    $a_project_vars(rel_src_prj)
    set  ::orig_proj_dir_loc $a_project_vars(rel_dir_prj)
    puts "RESTORING PROJECT FROM: $a_project_vars(rel_src_prj)/$project_name.tcl"
    source -quiet $a_project_vars(rel_src_prj)/$project_name.tcl
  }
  ## no chance to open project ##
  if { [catch {current_project}] } { error "Could not open project" }

  make_load_sources
}


## ////////////////////////////////////////////////////////////////////////// ##
## /// WRITE PROJECT //////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

proc make_write_project {} {
  variable make_env
  variable a_project_vars

  if { [catch {current_project}] } { make_open_project }
  file mkdir $a_project_vars(rel_src_prj)
  write_project_tcl \
    -force -target_proj_dir $a_project_vars(rel_dir_prj) \
    $a_project_vars(rel_src_prj)/$a_project_vars(project_name).tcl
}
}
