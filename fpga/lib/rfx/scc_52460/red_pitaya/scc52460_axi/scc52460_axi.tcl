#
# Vivado (TM) v2015.4 (64-bit)
#
# scc52460_axi.tcl: Tcl script for re-creating project 'scc52460_axi'
#
# Generated by Vivado on Mon Jul 17 13:54:09 UTC 2017
# IP Build 1412160 on Tue Nov 17 13:47:24 MST 2015
#
# This file contains the Vivado Tcl commands for re-creating the project to the state*
# when this script was generated. In order to re-create the project, please source this
# file in the Vivado Tcl Shell.
#
# * Note that the runs in the created project will be configured the same way as the
#   original project, however they will not be launched automatically. To regenerate the
#   run results please launch the synthesis/implementation runs as needed.
#
#*****************************************************************************************
# NOTE: In order to use this script for source control purposes, please make sure that the
#       following files are added to the source control system:-
#
# 1. This project restoration tcl script (scc52460_axi.tcl) that was generated.
#
# 2. The following source(s) files that were local or imported into the original project.
#    (Please see the '$orig_proj_dir' and '$origin_dir' variable setting below at the start of the script)
#
#    <none>
#
# 3. The following remote source files that were added to the original project:-
#
#    <none>
#
#*****************************************************************************************


 ## MAKE_ENV ## 

################################################################################
# define paths
################################################################################

global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)

proc srcdir     {} { global env; if {[info exists env(srcdir)]} {return $env(srcdir)} }
proc top_srcdir {} { global env; if {[info exists env(top_srcdir)]} {return $env(top_srcdir)} }
proc builddir   {} { return . }


set_param general.maxThreads $env(maxThreads)

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

proc compute_project_name {} {
  set name [getenv NAME]
  if { $name eq "" } {set name [getenv PROJECT_NAME]}
  if { $name eq "" } {set name [lindex [split [srcdir] "/"] end]}
  #  set version [getenv VERSION]
  #  if { $version eq "" } {set version 1.0}
  set project_name ${name}
  return $project_name
}

proc compute_core_fullname {} {
  set core_name   [getenv NAME]
  set vendor_name [getenv VENDOR]
  set version_tag [getenv VERSION]
  if { $version_tag eq "" } { set version_tag 1.0 }
  if { $vendor_name ne "" } { set core_name ${vendor_name}_${core_name} }
  if { $version_tag ne "" } { set core_name ${core_name}_${version_tag} }
  return $core_name
}

proc compute_project_dir { mode } {
  set name [getenv NAME]
  if { $name eq "" } {set name [getenv PROJECT_NAME]}
  if { $name eq "" } {set name [lindex [split [srcdir] "/"] end]}
  switch $mode {
    "src"  {return [srcdir]/[getenv BOARD]/${name}}
    "edit" {return [getenv BOARD]/${name}_edit}
  }
  return [compute_project_name]
}


proc reset_core_env {} {
  variable core_env
  set    core_env(core_fullname)    [compute_core_fullname]
  set    core_env(core_name)        [getenv NAME]
  set    core_env(srcdir)           [srcdir]/[getenv VIVADO_IPDIR]/[compute_core_fullname]
  set    core_env(builddir)         [builddir]/[getenv VIVADO_IPDIR]/[compute_core_fullname]_edit
  set    core_env(VENDOR)           [getenv VENDOR]
  set    core_env(VERSION)          [getenv VERSION]
  set    core_env(SOURCES)          [getenv SOURCES]
  set    core_env(BD_SOURCES)       [getenv BD_SOURCES]
  set    core_env(IP_SOURCES)       [getenv IP_SOURCES]
  set    core_env(DRV_LINUX)        [getenv DRV_LINUX]
}
reset_core_env

proc reset_make_env {} {
  variable make_env
  set    make_env(project_name)     [compute_project_name]
  set    make_env(BOARD)            [getenv BOARD]
  set    make_env(VIVADO_VERSION)   [getenv VIVADO_VERSION]
  set    make_env(VIVADO_SOC_PART)  [getenv VIVADO_SOC_PART]
  set    make_env(srcdir)           [getenv srcdir]
  set    make_env(top_srcdir)       [getenv top_srcdir]
  set    make_env(maxThreads)       [getenv maxThreads]
  set    make_env(fpga_dir)         [getenv FPGA_DIR]
  set    make_env(DTREE_DIR)        [getenv DTREE_DIR]
  set    make_env(ip_repo)          [getenv FPGA_REPO_DIR]
  set    make_env(SOURCES)          [getenv SOURCES]
  set    make_env(BD_SOURCES)       [getenv BD_SOURCES]
  set    make_env(IP_SOURCES)       [getenv IP_SOURCES]
}

# set env by default when included
reset_make_env



variable project_env
proc reset_project_env { } {
  variable make_env
  variable project_set
  variable project_env

  set project_set(VIVADO_VERSION) $make_env(VIVADO_VERSION)
  set project_set(project_name)   [compute_project_name]
  set project_set(dir_prj)        [compute_project_dir edit]
  set project_set(dir_src)        [compute_project_dir src]
  set project_set(dir_sdc)        [compute_project_dir edit]/sdc
  set project_set(dir_out)        [compute_project_dir edit]/out
  set project_set(dir_sdk)        [compute_project_dir edit]/sdk

  set project_set(sources_list) [split $make_env(SOURCES) " "]

  foreach { key val } [array get project_set] {
   # puts "project_env($key) [subst $val]"
   set project_env($key) [subst $val]
  }

  # save to projutils global variable
  #  catch {
  #    variable ::tclapp::xilinx::projutils::a_make_vars
  #    array set a_make_vars [array get a_project_vars]
  #  }
}
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
  lappend introspection "namespace upvar ::tclapp::socdev::makeutils make_env make_env"
  lappend introspection "namespace upvar ::tclapp::socdev::makeutils project_env project_env"
  lappend introspection "namespace upvar ::tclapp::socdev::makeutils project_set project_set"
  lappend introspection "namespace upvar ::tclapp::socdev::makeutils core_env core_env"
  close $fp
  set make_env(self) [list]
  lappend make_env(self) {*}$introspection
}
set_socdev_env

}


namespace upvar ::tclapp::socdev::makeutils make_env make_env
namespace upvar ::tclapp::socdev::makeutils project_env project_env
namespace upvar ::tclapp::socdev::makeutils project_set project_set
namespace upvar ::tclapp::socdev::makeutils core_env core_env


# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "$project_set(dir_src)"

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}

variable script_file
set script_file "scc52460_axi.tcl"

# Help information for this script
proc help {} {
  variable script_file
  puts "\nDescription:"
  puts "Recreate a Vivado project from this script. The created project will be"
  puts "functionally equivalent to the original project for which this script was"
  puts "generated. The script contains commands for creating a project, filesets,"
  puts "runs, adding/importing sources and setting properties on various objects.\n"
  puts "Syntax:"
  puts "$script_file"
  puts "$script_file -tclargs \[--origin_dir <path>\]"
  puts "$script_file -tclargs \[--help\]\n"
  puts "Usage:"
  puts "Name                   Description"
  puts "-------------------------------------------------------------------------"
  puts "\[--origin_dir <path>\]  Determine source file paths wrt this path. Default"
  puts "                       origin_dir path value is \".\", otherwise, the value"
  puts "                       that was set with the \"-paths_relative_to\" switch"
  puts "                       when this script was generated.\n"
  puts "\[--help\]               Print help information for this script"
  puts "-------------------------------------------------------------------------\n"
  exit 0
}

if { $::argc > 0 } {
  for {set i 0} {$i < [llength $::argc]} {incr i} {
    set option [string trim [lindex $::argv $i]]
    switch -regexp -- $option {
      "--origin_dir" { incr i; set origin_dir [lindex $::argv $i] }
      "--help"       { help }
      default {
        if { [regexp {^-} $option] } {
          puts "ERROR: Unknown option '$option' specified, please type '$script_file -tclargs --help' for usage info.\n"
          return 1
        }
      }
    }
  }
}

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/../../../../../../build/fpga/lib/rfx/scc_52460/red_pitaya/scc52460_axi_edit"]"

# Create project
create_project scc52460_axi "red_pitaya/scc52460_axi_edit" -part xc7z010clg400-1

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Reconstruct message rules
# None

# Set project properties
set obj [get_projects scc52460_axi]
set_property "default_lib" "xil_defaultlib" $obj
set_property "ip_cache_permissions" "read write" $obj
set_property "part" "xc7z010clg400-1" $obj
set_property "sim.ip.auto_export_scripts" "1" $obj
set_property "simulator_language" "Mixed" $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
# Empty (no sources present)

# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Empty (no sources present)

# Set 'constrs_1' fileset properties
set obj [get_filesets constrs_1]

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
# Empty (no sources present)

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property "xelab.nosort" "1" $obj
set_property "xelab.unifast" "" $obj

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
  create_run -name synth_1 -part xc7z010clg400-1 -flow {Vivado Synthesis 2015} -strategy "Vivado Synthesis Defaults" -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow "Vivado Synthesis 2015" [get_runs synth_1]
}
set obj [get_runs synth_1]
set_property "part" "xc7z010clg400-1" $obj

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
  create_run -name impl_1 -part xc7z010clg400-1 -flow {Vivado Implementation 2015} -strategy "Vivado Implementation Defaults" -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2015" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property "part" "xc7z010clg400-1" $obj
set_property "steps.write_bitstream.args.readback_file" "0" $obj
set_property "steps.write_bitstream.args.verbose" "0" $obj

# set the current impl run
current_run -implementation [get_runs impl_1]

puts "INFO: Project created:scc52460_axi"
