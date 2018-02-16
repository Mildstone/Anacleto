
## ////////////////////////////////////////////////////////////////////////// ##
## /// MAKE ENV  //////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##


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



################################################################################
# define paths
################################################################################

global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)

## set_param general.maxThreads $env(maxThreads)

namespace eval ::tclapp::socdev::makeutils {

  variable make_env
  variable project_set
  variable project_env
  variable core_env

proc  getenv { name {default ""}} {
  variable ::env
  if { [info exists env($name)] } {
    return $env($name)
  } else {    
    return $default
  }
}

proc srcdir       {} { return [getenv srcdir .] }
proc top_srcdir   {} { return [getenv top_srcdir .] }
proc builddir     {} { return [getenv builddir .] }
proc top_builddir {} { return [getenv top_builddir .] }

proc compute_project_name {} {
  set name [getenv NAME [getenv PROJECT_NAME]]
  set vendor_name [getenv VENDOR]
  set version_tag [getenv VERSION 1.0]
  if { $name eq "" } {set name [lindex [split [srcdir] "/"] end]}
  if { $vendor_name ne "" } { set name ${vendor_name}_${name} }
  if { $version_tag ne "" } { set name ${name}_${version_tag} }
  return ${name}
}

proc compute_core_fullname {} {
  return [compute_project_name]
}

proc compute_project_dir { mode } {
  switch $mode {
    "src"  {return [getenv VIVADO_SRCDIR]}
    "edit" {return [getenv VIVADO_PRJDIR]}
  }
  return [compute_project_name]
}


proc reset_make_env {} {
  variable make_env
  set    make_env(srcdir)           [getenv srcdir .]
  set    make_env(builddir)         [getenv builddir .]
  set    make_env(VIVADO_VERSION)   [getenv VIVADO_VERSION]
  set    make_env(top_srcdir)       [getenv top_srcdir]
  set    make_env(maxThreads)       [getenv maxThreads]
  set    make_env(fpga_dir)         [getenv FPGA_DIR]
  set    make_env(DTREE_DIR)        [getenv DTREE_DIR]
}
# set env by default when included
reset_make_env

proc reset_core_env {} {
  variable core_env
  set    core_env(core_fullname)    [compute_core_fullname]
  set    core_env(core_name)        [getenv NAME]
  set    core_env(ipdir)            [getenv VIVADO_IPDIR]/[compute_core_fullname]
  set    core_env(VENDOR)           [getenv VENDOR]
  set    core_env(VERSION)          [getenv VERSION]
  set    core_env(DRV_LINUX)        [getenv DRV_LINUX]
  set    core_env(BSPDIR)           [getenv BSPDIR]
}
# set env by default when included
reset_core_env

proc reset_project_env { } {
  variable make_env
  variable project_env

  set project_env(project_name)    [compute_project_name]
  set project_env(VIVADO_VERSION)  [getenv VIVADO_VERSION]
  set project_env(VIVADO_SOC_PART) [getenv VIVADO_SOC_PART]
  set project_env(BOARD)           [getenv BOARD]
  set project_env(BOARD_PART)      [getenv BOARD_PART]
  set project_env(BOARD_PRESET)    [getenv BOARD_PRESET]
  set project_env(dir_prj)         [compute_project_dir edit]
  set project_env(dir_src)         [compute_project_dir src]
  set project_env(dir_sdc)         [compute_project_dir edit]/[compute_project_name].sdc
  set project_env(dir_bit)         [compute_project_dir edit]/[compute_project_name].bit
  set project_env(dir_sdk)         [compute_project_dir edit]/[compute_project_name].sdk
  set project_env(ip_repo)         [getenv FPGA_REPO_DIR]
  set project_env(synth_name)      [getenv synth_name "anacleto_synth"]
  set project_env(impl_name)       [getenv impl_name  "anacleto_impl"]
  set project_env(SOURCES)         [getenv SOURCES]
  set project_env(ARCHIVE)         [getenv ARCHIVE]
  set project_env(PRJCFG)          [getenv PRJCFG]
  set project_env(IPCFG)           [getenv IPCFG]
  set project_env(BD_SOURCES)      [getenv BD_SOURCES]
  set project_env(IP_SOURCES)      [getenv IP_SOURCES]
  set project_env(COMPILE_ORDER)   [getenv COMPILE_ORDER]
  set project_env(sources_list)    [split [getenv SOURCES] " "]
}
# set env by default when included
reset_project_env


proc set_socdev_env {} {
  variable make_env
  set introspection [list]
  set fp [open [info script] r]
  set file_data [read $fp]
  set data [split $file_data "\n"]
  foreach line $data {
    lappend introspection $line
  }
  lappend introspection "namespace upvar ::tclapp::socdev::makeutils make_env    make_env"
  lappend introspection "namespace upvar ::tclapp::socdev::makeutils project_env project_env"
  lappend introspection "namespace upvar ::tclapp::socdev::makeutils core_env    core_env"
  close $fp
  set make_env(self) [list]
  lappend make_env(self) {*}$introspection
}
set_socdev_env

}


namespace upvar ::tclapp::socdev::makeutils make_env    make_env
namespace upvar ::tclapp::socdev::makeutils project_env project_env
namespace upvar ::tclapp::socdev::makeutils core_env    core_env


## ////////////////////////////////////////////////////////////////////////// ##
## /// CREATE PROJ ////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##
 
 create_project rfx_pwm_1.0  "$make_env(builddir)/edit/red_pitaya"  -part xc7z010clg400-1
 
 # Set the directory path for the new project
 set proj_dir [get_property directory [current_project]]
 
 # Reconstruct message rules
 # None
 
## ////////////////////////////////////////////////////////////////////////// ##
## /// FILESETS    ////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

 # /////////////////////////////////////////////////////////////  
 # // sources_1                                                    
 # /////////////////////////////////////////////////////////////  
 # 
 # Create 'sources_1' fileset (if not found)
 if {[string equal [get_filesets -quiet sources_1] ""]} {
   create_fileset -srcset sources_1
 }
 # 
 # Set IP repository paths
 # No local ip repos found for sources_1 ... 
 # 
 # Set 'sources_1' fileset object
 set obj [get_filesets sources_1]
 set files [list \
  "[file normalize $make_env(srcdir)/src/pwm.vhd]"\
  "[file normalize $make_env(srcdir)/src/rfx_pwm_v1_0.vhd]"\
  "[file normalize $make_env(srcdir)/src/rfx_pwm_v1_0_S00_AXI.vhd]"\
 ]
 add_files -norecurse -fileset $obj $files
 # 
 # Properties for pwm.vhd
  set file "$project_env(dir_src)/../../src/pwm.vhd"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "VHDL" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis simulation" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for rfx_pwm_v1_0.vhd
  set file "$project_env(dir_src)/../../src/rfx_pwm_v1_0.vhd"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "VHDL" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis simulation" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for rfx_pwm_v1_0_S00_AXI.vhd
  set file "$project_env(dir_src)/../../src/rfx_pwm_v1_0_S00_AXI.vhd"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "VHDL" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis simulation" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # No properties for sources_1
 # 
 # 
 # /////////////////////////////////////////////////////////////  
 # // constrs_1                                                    
 # /////////////////////////////////////////////////////////////  
 # 
 # Create 'constrs_1' fileset (if not found)
 if {[string equal [get_filesets -quiet constrs_1] ""]} {
   create_fileset -constrset constrs_1
 }
 # 
 # Set 'constrs_1' fileset object
 set obj [get_filesets constrs_1]
 # Empty (no sources present)

 # 
 # 
 # /////////////////////////////////////////////////////////////  
 # // sim_1                                                    
 # /////////////////////////////////////////////////////////////  
 # 
 # Create 'sim_1' fileset (if not found)
 if {[string equal [get_filesets -quiet sim_1] ""]} {
   create_fileset -simset sim_1
 }
 # 
 # Set 'sim_1' fileset object
 set obj [get_filesets sim_1]
 # Empty (no sources present)

 # 
 # 
