
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
 
 create_project rp_logic_1.0  "$make_env(builddir)/edit/red_pitaya"  -part xc7z010clg400-1
 
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
 file mkdir "$project_env(dir_prj)/rp_logic_1.0.srcs/sources_1/bd/red_pitaya_ps_1"
 file copy -force "$project_env(dir_src)/rp_logic_1.0.srcs/sources_1/bd/red_pitaya_ps_1/red_pitaya_ps_1.bd" \
    "$project_env(dir_prj)/rp_logic_1.0.srcs/sources_1/bd/red_pitaya_ps_1/red_pitaya_ps_1.bd"
 set files [list \
  "[file normalize $project_env(dir_prj)/rp_logic_1.0.srcs/sources_1/bd/red_pitaya_ps_1/red_pitaya_ps_1.bd]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/axi4_lite_slave.v]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/classic/axi_master.v]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/classic/axi_wr_fifo.v]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/classic/red_pitaya_ams.v]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/classic/red_pitaya_asg.v]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/classic/red_pitaya_asg_ch.v]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/classic/red_pitaya_hk.v]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/classic/red_pitaya_id.v]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/classic/red_pitaya_pid.v]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/classic/red_pitaya_pid_block.v]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/classic/red_pitaya_scope.v]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/acq.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/evn_pkg.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/asg.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/asg_bst.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/asg_per.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/interface/axi4_if.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/axi4_slave.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/axi4_stream_cnt.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/axi4_stream_demux.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/axi4_stream_dly.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/interface/axi4_stream_if.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/axi4_stream_mux.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/axi4_stream_pas.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/axi4_stream_reg.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/bin_and.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/clb.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/clkdiv.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/ctrg.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/cts.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/debounce.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/gen.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/id.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/la.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/la_trg.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/lg.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/lin_add.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/lin_mul.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/mgmt.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/muxctl.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/old_acq.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/old_asg.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/old_asg_top.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/old_id.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/old_la_top.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/osc.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/osc_trg.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/pdm.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/pid.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/pid_block.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/pwm.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/red_pitaya_dfilt1.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/red_pitaya_pll.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/classic/red_pitaya_pwm.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/rle.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/scope_dec_avg.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/scope_filter.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/str2mm.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/str_dec.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/interface/sys_bus_if.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/sys_bus_interconnect.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/sys_bus_stub.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/sys_reg_array_o.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/interface/spi_if.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/interface/gpio_if.sv]"\
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/rtl/interface/axi4_lite_if.sv]"\
 ]
 add_files -norecurse -fileset $obj $files
 # 
 # Properties for axi4_lite_slave.v
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/axi4_lite_slave.v"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "Verilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for axi_master.v
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/classic/axi_master.v"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "Verilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for axi_wr_fifo.v
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/classic/axi_wr_fifo.v"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "Verilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for red_pitaya_ams.v
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/classic/red_pitaya_ams.v"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "Verilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for red_pitaya_asg.v
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/classic/red_pitaya_asg.v"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "Verilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for red_pitaya_asg_ch.v
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/classic/red_pitaya_asg_ch.v"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "Verilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for red_pitaya_hk.v
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/classic/red_pitaya_hk.v"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "Verilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for red_pitaya_id.v
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/classic/red_pitaya_id.v"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "Verilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for red_pitaya_pid.v
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/classic/red_pitaya_pid.v"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "Verilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for red_pitaya_pid_block.v
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/classic/red_pitaya_pid_block.v"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "Verilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for red_pitaya_scope.v
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/classic/red_pitaya_scope.v"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "Verilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for acq.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/acq.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for evn_pkg.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/evn_pkg.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for asg.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/asg.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for asg_bst.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/asg_bst.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for asg_per.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/asg_per.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for axi4_if.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/interface/axi4_if.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for axi4_slave.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/axi4_slave.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for axi4_stream_cnt.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/axi4_stream_cnt.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for axi4_stream_demux.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/axi4_stream_demux.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for axi4_stream_dly.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/axi4_stream_dly.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for axi4_stream_if.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/interface/axi4_stream_if.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for axi4_stream_mux.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/axi4_stream_mux.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for axi4_stream_pas.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/axi4_stream_pas.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for axi4_stream_reg.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/axi4_stream_reg.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for bin_and.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/bin_and.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for clb.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/clb.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for clkdiv.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/clkdiv.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for ctrg.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/ctrg.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for cts.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/cts.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for debounce.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/debounce.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for gen.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/gen.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for id.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/id.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for la.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/la.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for la_trg.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/la_trg.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for lg.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/lg.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for lin_add.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/lin_add.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for lin_mul.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/lin_mul.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for mgmt.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/mgmt.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for muxctl.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/muxctl.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for old_acq.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/old_acq.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for old_asg.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/old_asg.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for old_asg_top.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/old_asg_top.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for old_id.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/old_id.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for old_la_top.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/old_la_top.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for osc.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/osc.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for osc_trg.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/osc_trg.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for pdm.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/pdm.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for pid.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/pid.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for pid_block.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/pid_block.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for pwm.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/pwm.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for red_pitaya_dfilt1.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/red_pitaya_dfilt1.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for red_pitaya_pll.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/red_pitaya_pll.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for red_pitaya_pwm.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/classic/red_pitaya_pwm.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for rle.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/rle.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for scope_dec_avg.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/scope_dec_avg.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for scope_filter.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/scope_filter.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for str2mm.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/str2mm.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for str_dec.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/str_dec.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for sys_bus_if.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/interface/sys_bus_if.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for sys_bus_interconnect.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/sys_bus_interconnect.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for sys_bus_stub.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/sys_bus_stub.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for sys_reg_array_o.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/sys_reg_array_o.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for spi_if.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/interface/spi_if.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for gpio_if.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/interface/gpio_if.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for axi4_lite_if.sv
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/rtl/interface/axi4_lite_if.sv"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "file_type" "SystemVerilog" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for red_pitaya_ps_1.bd
  set file "$project_env(dir_prj)/rp_logic_1.0.srcs/sources_1/bd/red_pitaya_ps_1/red_pitaya_ps_1.bd"
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "exclude_debug_logic" "0" $file_obj
  if { ![get_property "is_locked" $file_obj] } {
    set_property -quiet "generate_synth_checkpoint" "1" $file_obj
  }
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  if { ![get_property "is_locked" $file_obj] } {
    set_property -quiet "is_locked" "0" $file_obj
  }
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "pfm_name" "" $file_obj
  if { ![get_property "is_locked" $file_obj] } {
    set_property -quiet "synth_checkpoint_mode" "Hierarchical" $file_obj
  }
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
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
 set files [list \
  "[file normalize $make_env(srcdir)/../../build/projects/rp_legacy/redpitaya/fpga/sdc/red_pitaya.xdc]"\
 ]
 add_files -norecurse -fileset $obj $files
 # 
 # Properties for red_pitaya.xdc
  set file "$project_env(dir_src)/../../../../build/projects/rp_legacy/redpitaya/fpga/sdc/red_pitaya.xdc"
  set file [file normalize $file]
  set file_obj [get_files -of_objects [get_filesets constrs_1] [list "$file"]]
  set_property -quiet "file_type" "XDC" $file_obj
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  set_property -quiet "processing_order" "NORMAL" $file_obj
  set_property -quiet "scoped_to_cells" "" $file_obj
  set_property -quiet "scoped_to_ref" "" $file_obj
  set_property -quiet "used_in" "synthesis implementation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # No properties for constrs_1
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
