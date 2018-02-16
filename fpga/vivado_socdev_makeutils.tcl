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
# package require Vivado 1.2014.1

global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)



namespace eval ::tclapp::socdev::makeutils {
  namespace export make_new_project
  namespace export make_open_project
  namespace export make_write_project
  namespace export make_new_ip
  namespace export make_edit_ip
  namespace export make_write_bitstream
  namespace export make_write_devicetree
  namespace export make_write_linux_bsp
  namespace export make_write_fsbl
  namespace export make_package_hls_ip
}

## INCLUDES ##
catch {
  source -notrace $top_srcdir/fpga/vivado_socdev_env.tcl
  source -notrace $top_srcdir/fpga/vivado_socdev_listutils.tcl
  source -notrace $top_srcdir/fpga/write_anacleto_prj.tcl
}


## NAMESPACE ###################################################################
namespace eval ::tclapp::socdev::makeutils {

## ////////////////////////////////////////////////////////////////////////// ##
## /// GLOBALS ////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

namespace eval v {
 upvar 1 make_env    me
 upvar 1 project_env pe
 upvar 1 core_env    ce
 # debug get function id
 proc fid {} { get_funid [namespace parent] [lindex [info level 1] 0] }
 proc mid {} { get_msgid [namespace parent] [lindex [info level 1] 0] }
}


## export to write_project (FIX THIS using sourceOnce)
catch {
    array set ::tclapp::xilinx::projutils::make_env    [array get make_env]
    array set ::tclapp::xilinx::projutils::project_env [array get project_env]
    array set ::tclapp::xilinx::projutils::core_env    [array get core_env]
  }


proc set_compatible_with { program } {
  set current_parser [lindex [split [version] " "] 0]
  if { [string tolower $current_parser] != [string tolower $program] } {
    error "This script requires to be fired within $program environment."
  }
}


proc make_init_script {} {
 set path_brd "$v::me(top_srcdir)/fpga/brd \
			   $v::me(top_srcdir)/fpga/brd/red_pitaya \
			   $v::me(top_srcdir)/fpga/brd/red_pitaya/1.1 "
 set_param board.repoPaths $path_brd

}


## ////////////////////////////////////////////////////////////////////////// ##
## /// SET REPO PATHS /////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

proc make_set_repo_path {} {
  set path_list [list]
  foreach ip_name [split $v::pe(IP_SOURCES) " "] {
    send_msg_id [v::mid]-1 INFO "ip name: $ip_name"
	set ip_path [file dirname $ip_name]
    lappend path_list $ip_path
  }
  foreach el [split $v::pe(ip_repo) " "] { lappend path_list $el }
  lappend path_list $v::me(builddir)
  if { [catch {current_project}] } {
   send_msg_id [v::mid]-2 ERROR "project not defined"
  } else {
   set_property ip_repo_paths [lsort -unique $path_list] [current_project]
  }
}



## ////////////////////////////////////////////////////////////////////////// ##
## /// CREATE PROJECT /////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

proc make_new_project {{exec_preset 1}} {
  set_compatible_with Vivado

  set part    $v::pe(VIVADO_SOC_PART)
  set name    $v::pe(project_name)
  set dir_prj $v::pe(dir_prj)

  # init script
  make_init_script

  # setup a project
  create_project -part $part -force $name $dir_prj
  if { [catch {current_project}] } { error "Could not start a new project" }

  puts $v::pe(BOARD_PART)
  set_property BOARD_PART $v::pe(BOARD_PART) [current_project]

  # setup common ip catalog
  make_set_repo_path
  update_ip_catalog

  # load files
  make_load_sources
  set_property source_mgmt_mode All [current_project]

  # execute post scritps
  if { $v::pe(PRJCFG) eq "" && $exec_preset eq 1 } {
	source -notrace $v::pe(BOARD_PRESET)
	board_init
  } else {
	make_exec_scripts PRJCFG
  }

  # write project
  make_write_project
}

## ////////////////////////////////////////////////////////////////////////// ##
## /// CREATE PERIPHERAL //////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##


proc make_package_hls_ip {} {
  #
  ## set_compatible_with Hls
  set project_name $v::pe(project_name)
  set dir_prj      $v::pe(dir_prj)
  set core_name    $v::ce(core_name)
  set ipdir        $v::ce(ipdir)
  set solution     solution1

  set current_dir [pwd]
  file mkdir $dir_prj
  cd $dir_prj
  open_project $project_name
  cd $current_dir
  foreach file [split $v::pe(SOURCES) " "] {
	set ftype [file extension $file]
	set path [make_find_path $file]
	if {$path eq ""} {continue}
	add_files $path
  }
  set_top $core_name

  open_solution -reset $solution
  set_part $v::pe(VIVADO_SOC_PART)

  create_clock -period "100MHz"
  csynth_design
  export_design -format ip_catalog

  close_project

  # TODO: This is very ugly man !
  #  file mkdir $ipdir/$project_name
  #  foreach file [glob -directory $dir_prj/$project_name/$solution/impl/ip *] {
  #   if {[file exists $file]} { file delete -force $ipdir/$file }
  #   file copy -force $file $ipdir
  #  }
  #  file delete -force $dir_prj/$project_name/$solution/impl/ip
  file mkdir $ipdir
  file delete -force $ipdir
  file copy -force $dir_prj/$project_name/$solution/impl/ip $ipdir
  file delete -force $dir_prj/$project_name/$solution/impl/ip
}


proc make_package_ip { } {
  set_compatible_with Vivado

  set project_name $v::pe(project_name)
  set dir_prj      $v::pe(dir_prj)
  set core_name    $v::ce(core_name)
  set ipdir        $v::ce(ipdir)

  # init script
  make_init_script

  # setup a project
  if { [file exists $dir_prj/$project_name.xpr] } {
	 make_open_project
  } else {
  #	 create_project -in_memory -part $v::pe(VIVADO_SOC_PART) -force dummy
  #	 if { [catch {current_project}] } { send_msg_id [v::mid]-1 ERROR "dummy prj fail"}
  #	 make_load_sources
  #	 set_property source_mgmt_mode All [current_project]
	 make_new_project 0
  }
  if { [catch {current_project}] } {
   send_msg_id [v::mid]-1 ERROR "Could not start a new project"
  }

  set files_no [llength [get_files -quiet]]
  if { $files_no > 0 } {
   ipx::package_project -import_files -root_dir $ipdir
   # ipx::package_project -root_dir $ipdir
   set core [ipx::current_core]
   set_property VERSION      $v::ce(VERSION) $core
   set_property NAME         $v::ce(core_name) $core
   set_property DISPLAY_NAME $v::ce(core_fullname) $core
   set_property LIBRARY      $v::ce(VENDOR) $core
   set_property VENDOR       $v::ce(VENDOR) $core
   #  set_property DESCRIPTION $v::ce(DESCRIPTION) $core

   # synth design to make a first compile test
   synth_design -rtl -name rtl_1

   ipx::create_xgui_files $core
   ipx::update_checksums $core
   ipx::save_core $core
   ipx::add_file_group -type software_driver {} $core
   foreach file [split $v::ce(DRV_LINUX) " "] {
	add_files -force -norecurse \
	 -copy_to ${ipdir}/bsp/[file dirname $file] $v::me(srcdir)/$file
	ipx::add_file bsp/$file \
	 [ipx::get_file_groups xilinx_softwaredriver -of_objects $core]
   }
   ipx::save_core $core
  } else {
   file mkdir $ipdir
   ipx::create_core $v::ce(VENDOR) $v::ce(VENDOR) \
		    $v::ce(core_name) $v::ce(VERSION)
   set core [ipx::current_core]
   set_property ROOT_DIRECTORY $ipdir $core
   ipx::save_core $core

  }

#  foreach file [split $v::ce(DRV_LINUX) " "] {
#   add_files -force -norecurse \
#	 -copy_to ${dir_prj}/bsp/[file dirname $file] $v::me(srcdir)/$file
#   ipx::add_file bsp/$file \
#	 [ipx::get_file_groups xilinx_softwaredriver -of_objects $core]
#  }
#  ipx::save_core $core



  # execute post scritps
  make_exec_scripts IPCFG

#  # reopen ip project for editing
#  if { [get_projects dummy] == "" } {
#   close_project -quiet
#   create_project -in_memory -part $v::pe(VIVADO_SOC_PART) -force dummy
#   if { [catch {current_project dummy}] } { send_msg_id [v::mid]-1 ERROR "dummy prj fail"}
#   current_project dummy
#  }
#  ipx::edit_ip_in_project -force true -upgrade true -name ${project_name}_ip2 \
#	-directory $dir_prj $ipdir/component.xml
#  current_project $project_name
#  # write project
#  ipx::create_xgui_files $core
#  ipx::update_checksums $core
#  ipx::save_core $core

#  # close dummy in memory project
#  if { [get_projects dummy] != "" } {
#	current_project dummy
#	close_project -quiet
#  }
}


## ////////////////////////////////////////////////////////////////////////// ##
## /// EDIT PERIPHERAL ////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##


proc make_edit_ip { } {
  set_compatible_with Vivado

  # init script
  make_init_script

  set project_name $v::pe(project_name)
  set dir_prj      $v::pe(dir_prj)
  set core_name    $v::ce(core_name)
  set ipdir        $v::ce(ipdir)


  if { ![file exists $ipdir/component.xml] } {
   make_package_ip
  } else {
   make_open_project
  }

  puts "FILE_IP: $ipdir/component.xml"
  add_files $ipdir/component.xml
  ipx::open_core $ipdir/component.xml
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
proc make_load_sources { } {

  # refer to https://www.xilinx.com/itp/xilinx10/isehelp/ise_r_source_types.htm
  # import all remote sources

  puts " $v::pe(SOURCES) "
  if {!($v::pe(SOURCES) eq "")} {
   foreach file [split $v::pe(SOURCES) " "] {
     set ftype [file extension $file]
     set path [make_find_path $file]
     if {$path eq ""} {continue}
     switch -regexp $ftype {
       \.(v|V|verilog)\$         { read_verilog $path }
       \.(sv|SV)\$               { read_verilog -sv $path }
       \.(vhd|Vhd|vhdl|Vhdl)\$   { read_vhdl $path }
	   \.(xdc|Xdc)\$             { read_xdc $path }
	   \.(bd)\$                  { add_files $path }
       \.(tcl|Tcl)\$             { send_msg_id [v::mid]-1 INFO \
				   "executing TCL script from SOURCES ..."
				   set err [source -notrace $path]
				   if { !($err eq "") } {
				    send_msg_id [v::mid]-2 ERROR \
				    "some error occurred executing TCL script.."}
				 }
     }
   }
  }
  # import all remote BD from TCL scripts
  if {!($v::pe(BD_SOURCES) eq "")} {
   foreach file [split $v::pe(BD_SOURCES) " "] {
     set ftype [file extension $file]
     set path [make_find_path $file]
     if {$path eq ""} {continue}
     switch -regexp $ftype {
       \.(tcl|Tcl)\$       { send_msg_id [v::mid]-3 INFO "reading design from TCL script..."
							 set err [source -quiet $path]
							 if { !($err eq "")  } {
							  send_msg_id [v::mid]-3 INFO \
							  "the tcl design $design_name has priority over bd binary \
							  removed $design_name in project, replacing with $path"
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

proc load_sources { src_list type fset } {
# report_ip_status -name ip_status
# regenerate_bd_layout
# create_fileset -simset sim_2
# set_property SOURCE_SET sources_1 [get_filesets sim_2]
# add_files -fileset sim_2 -norecurse $path
# current_fileset -simset [ get_filesets sim_2 ]
# update_compile_order -fileset sim_2
}


proc make_exec_scripts { var } {

if {!($v::pe($var) eq "")} {
 foreach file [split $v::pe($var) " "] {
   puts " ----------------------------------------------------------"
   puts "  executing: $file "
   puts " ----------------------------------------------------------"
   set ftype [file extension $file]
   set path [make_find_path $file]
   if {$path eq ""} {continue}
   switch -regexp $ftype {
	 \.(tcl|Tcl)\$             { send_msg_id [v::mid]-1 INFO \
								 "executing TCL script from SCRIPTS ..."
								 set err [source -notrace $path]
								 if { !($err eq "") } {
								 send_msg_id [v::mid]-2 ERROR \
								 "some error occurred executing TCL script.."}
								}
   }
 }
}
}


proc make_open_project {} {
  set_compatible_with Vivado

  # init script
  make_init_script

  set part $v::pe(VIVADO_SOC_PART)
  set name $v::pe(project_name)
  set dir_prj $v::pe(dir_prj)
  set dir_src $v::pe(dir_src)

  catch {::open_project -part $part $dir_prj/$name.xpr}
  ## restore project from tcl script ##
  if { [catch {current_project}] } {
      set  ::origin_dir_loc    $dir_src
      set  ::orig_proj_dir_loc $dir_prj
      puts "RESTORING PROJECT FROM: $dir_src/$name.tcl"
	  catch {source -notrace $dir_src/$name.tcl}
  }
  ## no chance to open project ##
  if { [catch {current_project}] } {
   puts "Could not open project, creating new"
   make_new_project
  } else {
   puts "PROJECT LOADED..."
  }

  # setup common ip catalog
  make_set_repo_path
  update_ip_catalog

  ## load remote sources
  make_load_sources
  set_property source_mgmt_mode All [current_project]

  # execute post scritps
  make_exec_scripts PRJCFG
}


## ////////////////////////////////////////////////////////////////////////// ##
## /// WRITE PROJECT //////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

proc make_write_project {} {
  set_compatible_with Vivado

  set dir_src $v::pe(dir_src)
  set archive $v::pe(ARCHIVE)

  set ::origin_dir $dir_src

  if { [catch {current_project}] } { make_open_project }
  file mkdir $v::pe(dir_src)

  # achive project
  if { $archive != "" } {
	set archive_file [file tail $archive]
	archive_project $dir_src/$archive_file \
	  -force -exclude_run_results -include_config_settings
  }

  # save to srcdir data and tcl script
  write_anacleto_tcl \
	-force -target_proj_dir $v::pe(dir_prj) \
	$v::pe(dir_src)/$v::pe(project_name).tcl

}



## ////////////////////////////////////////////////////////////////////////// ##
## /// WRITE BITSTREAM ////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

proc make_write_bitstream {} {
  set_compatible_with Vivado

  set prj_name $v::pe(project_name)
  set path_bit $v::pe(dir_bit)
  set path_sdk $v::pe(dir_sdk)

  make_open_project

  # set name of run
  set synth $v::pe(synth_name)
  set impl  $v::pe(impl_name)

  ## ////////////////////////////////////////////////////// ##
  ## generate a bitstream
  proc get_major { code } { return [lindex [split $code '.'] 0] }

  if { [lsearch -exact [get_runs] $synth] == -1 } {
	set flow "Vivado Synthesis [get_major $v::pe(VIVADO_VERSION)]"
    create_run -flow $flow $synth
  }
  if { [lsearch -exact [get_runs] $impl] == -1 } {
	set flow "Vivado Implementation [get_major $v::pe(VIVADO_VERSION)]"
    create_run $impl -parent_run $synth -flow $flow
  }

  ## customize directory output for run ##
  #  file mkdir $v::pe(rel_dir_prj)/$path_bit/synth
  #  file mkdir $v::pe(rel_dir_prj)/$path_bit/impl
  #  set_property DIRECTORY $v::pe(rel_dir_prj)/$path_bit/synth [get_runs $synth]
  #  set_property DIRECTORY $v::pe(rel_dir_prj)/$path_bit/impl  [get_runs $impl ]
  #  set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

  ## START SYNTH ##
  reset_run $impl
  reset_run $synth

  launch_runs $impl -to_step write_bitstream -jobs $v::me(maxThreads)
  wait_on_run $synth
  wait_on_run $impl

  ## ////////////////////////////////////////////////////// ##
  ## generate system definition ##
  file mkdir $path_bit
  file mkdir $path_sdk
  open_run $synth
  set  synth_dir [get_property DIRECTORY [get_runs $synth]]
  set  impl_dir  [get_property DIRECTORY [get_runs $impl ]]
  set  top_name  [get_property TOP [current_design]]
  file  copy -force  $impl_dir/${top_name}.hwdef $path_sdk/$prj_name.hwdef
  file  copy -force  $impl_dir/${top_name}.bit   $path_sdk/$prj_name.bit
  file  copy -force  $impl_dir/${top_name}.bit   $path_bit/$prj_name.bit

  write_sysdef    -force   -hwdef   $path_sdk/$prj_name.hwdef \
				  -bitfile $path_sdk/$prj_name.bit \
				  -file    $path_sdk/$prj_name.sysdef

  # Export Hardware for SDK inclusion #
  write_hwdef     -force   -file    $path_sdk/$prj_name.hdf
}


## ////////////////////////////////////////////////////////////////////////// ##
## /// WRITE DEVICETREE ///////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

proc make_write_devicetree {} {
  set_compatible_with Hsi

  set prj_name $v::pe(project_name)
  set path_bit $v::pe(dir_bit)
  set path_sdk $v::pe(dir_sdk)

  #  set boot_args { console=ttyPS0,115200n8 root=/dev/ram rw \
  #		  initrd=0x00800000,16M earlyprintk \
  #		  mtdparts=physmap-flash.0:512K(nor-fsbl),512K(nor-u-boot),\
  #		  5M(nor-linux),9M(nor-user),1M(nor-scratch),-(nor-rootfs) }

  open_hw_design $path_sdk/$prj_name.sysdef
  set_repo_path $v::me(DTREE_DIR)
  create_sw_design device-tree -os device_tree -proc ps7_cortexa9_0

  # set_property CONFIG.kernel_version {2016.2} [get_os]
  # set_property CONFIG.bootargs $boot_args [get_os]

  generate_target -dir $path_sdk/dts
}


## ////////////////////////////////////////////////////////////////////////// ##
## /// FSBL ///////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

proc make_write_fsbl {} {
  set_compatible_with Hsi

  set prj_name $v::pe(project_name)
  set path_bit $v::pe(dir_bit)
  set path_sdk $v::pe(dir_sdk)

  #  set boot_args { console=ttyPS0,115200n8 root=/dev/ram rw \
  #		  initrd=0x00800000,16M earlyprintk \
  #		  mtdparts=physmap-flash.0:512K(nor-fsbl),512K(nor-u-boot),\
  #		  5M(nor-linux),9M(nor-user),1M(nor-scratch),-(nor-rootfs) }

  open_hw_design $path_sdk/$prj_name.sysdef
  set_repo_path $v::me(DTREE_DIR)

  generate_app  -os standalone -proc ps7_cortexa9_0 -app zynq_fsbl \
      -compile -sw fsbl -dir $path_sdk/fsbl
}


## ////////////////////////////////////////////////////////////////////////// ##
## /// BSP ////////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

proc make_write_linux_bsp {} {
  set_compatible_with Hsi

  set prj_name $v::pe(project_name)
  set path_bit $v::pe(dir_bit)
  set path_sdk $v::pe(dir_sdk)

  open_hw_design $path_sdk/$prj_name.sysdef

  set_repo_path  $v::me(top_srcdir)/fpga/hsi/linux-bsp
  #  foreach ip_name [split $v::pe(IP_SOURCES)] {
  #	set_repo_path $v::me(srcdir)/$ip_name
  #  }
  # set_repo_path  $path_sdk

  create_sw_design ll -os linux -proc ps7_cortexa9_0 -verbose
  generate_target -dir $path_sdk/bsp bsp
  # generate_target -dir $path_sdk/app app
}


}
## END NAMESPACE
