package provide makeutils 1.0
# package require Vivado 1.2014.1

global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)

namespace eval ::tclapp::socdev::makeutils {
  namespace export make_new_project
  namespace export make_open_project
  namespace export make_write_project
  namespace export make_edit_peripheral
  namespace export make_write_bitstream
  namespace export make_write_devicetree
  namespace export make_write_fsbl
}

## INCLUDES ##
catch {
  source -notrace $top_srcdir/fpga/vivado_socdev_env.tcl
  source -notrace $top_srcdir/fpga/write_project_tcl_devel.tcl
}


## NAMESPACE ###################################################################
namespace eval ::tclapp::socdev::makeutils {

## ////////////////////////////////////////////////////////////////////////// ##
## /// GLOBALS ////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

namespace eval v {
 upvar 1 make_env me
 upvar 1 project_env pe
 upvar 1 project_set ps
}

## export to write_project (FIX THIS using sourceOnce)
catch {
    array set ::tclapp::xilinx::projutils::make_env [array get make_env]
    array set ::tclapp::xilinx::projutils::project_env [array get project_env]
    array set ::tclapp::xilinx::projutils::project_set [array get project_set]
  }


proc set_compatible_with { program } {
  set current_parser [lindex [split [version] " "] 0]
  if { [string tolower $current_parser] != [string tolower $program] } {
    error "This script requires to be fired within $program environment."
  }
}


proc make_set_repo_path {} {
  set path_list [list]
  foreach ip_name [split $v::me(IP_SOURCES) " "] {
    set ip_path [file normalize [file dirname $v::me(srcdir)/$ip_name]]
    lappend path_list $ip_path
  }
  lappend path_list $v::me(ip_repo)
  if { [catch {current_project}] } { error "project not defined"
  } else { set_property ip_repo_paths [lsort -unique $path_list] [current_project] }
}

## ////////////////////////////////////////////////////////////////////////// ##
## /// CREATE PROJECT /////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

proc make_new_project { } {
  set_compatible_with Vivado

  set project_name $v::me(project_name)

  # setup a project
  create_project -part $v::me(VIVADO_SOC_PART) -force ${project_name} ./vivado_project
  if { [catch {current_project}] } { error "Could not start a new project" }
  # reset_project_vars
  reset_make_env

  # setup common ip catalog
  #  set_property ip_repo_paths $v::me(ip_repo) [current_project]
  make_set_repo_path
  update_ip_catalog

  # create flows
  set vivado_major_num [lindex [split $v::me(VIVADO_VERSION) '.'] 0]
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
  set_compatible_with Vivado
  set missing_components [list]

  if { [catch {current_project}] } {
    create_project -in_memory -part $v::me(VIVADO_SOC_PART) -force _dummy_edit_ip
  }
  foreach ip_name [split $v::me(IP_SOURCES) " "] {
    set ip_path [file dirname $ip_name]
    set ip_name [file tail $ip_name]
    if {![file exists $v::me(srcdir)/${ip_path}/$ip_name/component.xml]} {
	  #  set ip_name_seed    [join [lrange [split $ip_name "_"] 0 end-1] "_"]
	  #  set ip_name_version [lindex [split $ip_name "_"] end]
	  #  create_peripheral user.org user ${ip_name_seed} ${ip_name_version} \
	  #    -dir $v::me(srcdir)/${ip_path}
	  #  ipx::create_core user.org user ${ip_name_seed} ${ip_name_version}
	  #  add_peripheral_interface S00_AXI -interface_mode slave -axi_type lite \
	  #    [ipx::find_open_core user.org:user:${ip_name_seed}:${ip_name_version}]
	  #  generate_peripheral -force \
	  #    [ipx::find_open_core user.org:user:${ip_name_seed}:${ip_name_version}]
	  #  write_peripheral [ipx::find_open_core user.org:user:${ip_name_seed}:${ip_name_version}]
	  lappend missing_components $ip_name
	  create_project -part $v::me(VIVADO_SOC_PART) -force $ip_name \
	    $v::pe(dir_prj)/${ip_path}/${ip_name}_project
	} else {
	  ipx::edit_ip_in_project -upgrade true -name $ip_name \
	    -directory $v::pe(dir_prj)/${ip_path}/${ip_name}_project \
	    $v::me(srcdir)/${ip_path}/$ip_name/component.xml
	}
  }
  # Print warning message
  if { [llength $missing_components] > 0 } {
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
  set file [string map {\\ /} $file]
  set src_relative $v::me(srcdir)/$file
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

  # refer to https://www.xilinx.com/itp/xilinx10/isehelp/ise_r_source_types.htm
  # import all remote sources
  if {!($v::me(SOURCES) eq "")} {
   foreach file [split $v::me(SOURCES) " "] {
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
  if {!($v::me(BD_SOURCES) eq "")} {
   foreach file [split $v::me(BD_SOURCES) " "] {
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
  set_compatible_with Vivado

  set project_name $v::me(project_name)
  catch {::open_project -part $v::me(VIVADO_SOC_PART) \
	 $v::pe(dir_prj)/$project_name.xpr}
  ## restore project from tcl script ##
  if { [catch {current_project}] } {
    set  ::origin_dir_loc    $v::me(srcdir)
    set  ::orig_proj_dir_loc $v::pe(dir_prj)
    puts "RESTORING PROJECT FROM: $v::pe(dir_src)/$project_name.tcl"
    source $v::pe(dir_src)/../$project_name.tcl
  }
  ## no chance to open project ##
  if { [catch {current_project}] } { error "Could not open project" } \
  else { puts "PROJECT LOADED..."}

  ## load remote sources
  make_load_sources
}


## ////////////////////////////////////////////////////////////////////////// ##
## /// WRITE PROJECT //////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

proc make_write_project {} {
  set_compatible_with Vivado

  if { [catch {current_project}] } { make_open_project }
  file mkdir $v::pe(dir_src)
  write_project_tcl \
    -force -target_proj_dir $v::pe(dir_prj) \
    $v::pe(dir_src)/../$v::pe(project_name).tcl
}



## ////////////////////////////////////////////////////////////////////////// ##
## /// WRITE BITSTREAM ////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

proc make_write_bitstream {} {
  set_compatible_with Vivado

  make_open_project
  set prj_name $v::pe(project_name)
  set path_out $v::pe(dir_out)
  set path_sdk $v::pe(dir_sdk)

  file mkdir $path_out
  file mkdir $path_sdk

  ## ////////////////////////////////////////////////////// ##
  ## generate a bitstream

  proc get_major { code } {
   return [lindex [split $code '.'] 0]
  }

  if { [lsearch -exact [get_runs] auto_synth_1] == -1 } {
    set flow "Vivado Synthesis [get_major $v::me(VIVADO_VERSION)]"
    create_run -flow $flow auto_synth_1
  }
  if { [lsearch -exact [get_runs] auto_impl_1] == -1 } {
    set flow "Vivado Implementation [get_major $v::me(VIVADO_VERSION)]"
    create_run auto_impl_1 -parent_run auto_synth_1 -flow $flow
  }

  ## customize directory output for run ##
  #  file mkdir $v::pe(rel_dir_prj)/$path_out/synth
  #  file mkdir $v::pe(rel_dir_prj)/$path_out/impl
  #  set_property DIRECTORY $v::pe(rel_dir_prj)/$path_out/synth [get_runs auto_synth_1]
  #  set_property DIRECTORY $v::pe(rel_dir_prj)/$path_out/impl  [get_runs auto_impl_1 ]


  ## START SYNTH ##
  reset_run auto_impl_1
  reset_run auto_synth_1

#  launch_runs auto_impl_1 -jobs $v::me(maxThreads)
#  wait_on_run auto_synth_1

#  open_run auto_synth_1
#  set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

  ## START IMPL ##
  #  launch_runs auto_impl_1 -jobs $v::me(maxThreads)
  #  launch_runs auto_impl_1
  #  wait_on_run auto_impl_1

  launch_runs auto_impl_1 -to_step write_bitstream -jobs $v::me(maxThreads)
  wait_on_run auto_synth_1
  wait_on_run auto_impl_1

  ## ////////////////////////////////////////////////////// ##
  ## generate system definition ##

  open_run auto_synth_1
  set  synth_dir [get_property DIRECTORY [get_runs auto_synth_1]]
  set  impl_dir  [get_property DIRECTORY [get_runs auto_impl_1 ]]
  set  top_name  [get_property TOP [current_design]]
  file  copy -force  $impl_dir/${top_name}.hwdef $path_sdk/$prj_name.hwdef
  file  copy -force  $impl_dir/${top_name}.bit   $path_sdk/$prj_name.bit
  file  copy -force  $impl_dir/${top_name}.bit   $path_out/$prj_name.bit

  write_sysdef    -force   -hwdef   $path_sdk/$prj_name.hwdef \
			   -bitfile $path_sdk/$prj_name.bit \
			   -file    $path_sdk/$prj_name.sysdef
  # Export Hardware for petalinux inclusion #

  write_hwdef     -force   -file    $path_sdk/$prj_name.hdf

}


## ////////////////////////////////////////////////////////////////////////// ##
## /// WRITE DEVICETREE ///////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

proc make_write_devicetree {} {
  set_compatible_with Hsi

  set prj_name $v::pe(project_name)
  set path_out $v::pe(dir_out)
  set path_sdk $v::pe(dir_sdk)

  #  set boot_args { console=ttyPS0,115200n8 root=/dev/ram rw \
  #		  initrd=0x00800000,16M earlyprintk \
  #		  mtdparts=physmap-flash.0:512K(nor-fsbl),512K(nor-u-boot),\
  #		  5M(nor-linux),9M(nor-user),1M(nor-scratch),-(nor-rootfs) }

  open_hw_design $path_sdk/$prj_name.sysdef
  set_repo_path $v::me(DTREE_DIR)
  create_sw_design device-tree -os device_tree -proc ps7_cortexa9_0

  set_property CONFIG.kernel_version {2015.4} [get_os]
  #set_property CONFIG.bootargs $boot_args [get_os]

  generate_target -dir $path_sdk/dts
}


proc make_write_fsbl {} {
  set_compatible_with Hsi

  set prj_name $v::pe(project_name)
  set path_out $v::pe(dir_out)
  set path_sdk $v::pe(dir_sdk)

  #  set boot_args { console=ttyPS0,115200n8 root=/dev/ram rw \
  #		  initrd=0x00800000,16M earlyprintk \
  #		  mtdparts=physmap-flash.0:512K(nor-fsbl),512K(nor-u-boot),\
  #		  5M(nor-linux),9M(nor-user),1M(nor-scratch),-(nor-rootfs) }

  open_hw_design $path_sdk/$prj_name.sysdef
  set_repo_path $v::me(DTREE_DIR)

  #  generate_app  -os standalone -proc ps7_cortexa9_0 -app zynq_fsbl \
  #    -compile -sw fsbl -dir $path_sdk/fsbl
}

}
## END NAMESPACE
