
## ////////////////////////////////////////////////////////////////////////// ##
## /// MAKE ENV  //////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##


## ////////////////////////////////////////////////////////////////////////// ##
## /// MAKE ENV  //////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##


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
 
 create_project rfx_rpadc_fifo_1.0  "$make_env(builddir)/edit/red_pitaya"  -part xc7z010clg400-1
 
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
 file mkdir "$project_env(dir_prj)/rfx_rpadc_fifo_1.0.srcs/sources_1/bd/rpadc_1"
 file copy -force "$project_env(dir_src)/rfx_rpadc_fifo_1.0.srcs/sources_1/bd/rpadc_1/rpadc_1.bd" \
    "$project_env(dir_prj)/rfx_rpadc_fifo_1.0.srcs/sources_1/bd/rpadc_1/rpadc_1.bd"
 file mkdir "$project_env(dir_prj)/rfx_rpadc_fifo_1.0.srcs/sources_1/bd/rpadc_1/hdl"
 file copy -force "$project_env(dir_src)/rfx_rpadc_fifo_1.0.srcs/sources_1/bd/rpadc_1/hdl/rpadc_1_wrapper.v" \
    "$project_env(dir_prj)/rfx_rpadc_fifo_1.0.srcs/sources_1/bd/rpadc_1/hdl/rpadc_1_wrapper.v"
 set files [list \
  "[file normalize $project_env(dir_prj)/rfx_rpadc_fifo_1.0.srcs/sources_1/bd/rpadc_1/rpadc_1.bd]"\
  "[file normalize $project_env(dir_prj)/rfx_rpadc_fifo_1.0.srcs/sources_1/bd/rpadc_1/hdl/rpadc_1_wrapper.v]"\
 ]
 add_files -norecurse -fileset $obj $files
 # 
 # No properties for sources_1
 # Properties for rpadc_1.bd
  set file "$project_env(dir_prj)/rfx_rpadc_fifo_1.0.srcs/sources_1/bd/rpadc_1/rpadc_1.bd"
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "exclude_debug_logic" "0" $file_obj
  if { ![get_property "is_locked" $file_obj] } {
    set_property -quiet "generate_synth_checkpoint" "0" $file_obj
  }
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  if { ![get_property "is_locked" $file_obj] } {
    set_property -quiet "is_locked" "0" $file_obj
  }
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  if { ![get_property "is_locked" $file_obj] } {
    set_property -quiet "synth_checkpoint_mode" "None" $file_obj
  }
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for rpadc_1_wrapper.v
  set file "$project_env(dir_prj)/rfx_rpadc_fifo_1.0.srcs/sources_1/bd/rpadc_1/hdl/rpadc_1_wrapper.v"
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
  "[file normalize $make_env(srcdir)/./red_pitaya.xdc]"\
 ]
 add_files -norecurse -fileset $obj $files
 # 
 # Properties for red_pitaya.xdc
  set file "$project_env(dir_src)/../../red_pitaya.xdc"
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

namespace upvar ::tclapp::socdev::makeutils make_env    make_env
namespace upvar ::tclapp::socdev::makeutils project_env project_env
namespace upvar ::tclapp::socdev::makeutils core_env    core_env


## ////////////////////////////////////////////////////////////////////////// ##
## /// CREATE PROJ ////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##
 
 create_project rfx_rpadc_fifo_1.0  "$make_env(builddir)/edit/red_pitaya"  -part xc7z010clg400-1
 
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
 file mkdir "$project_env(dir_prj)/rfx_rpadc_fifo_1.0.srcs/sources_1/bd/rpadc_1"
 file copy -force "$project_env(dir_src)/rfx_rpadc_fifo_1.0.srcs/sources_1/bd/rpadc_1/rpadc_1.bd" \
    "$project_env(dir_prj)/rfx_rpadc_fifo_1.0.srcs/sources_1/bd/rpadc_1/rpadc_1.bd"
 file mkdir "$project_env(dir_prj)/rfx_rpadc_fifo_1.0.srcs/sources_1/bd/rpadc_1/hdl"
 file copy -force "$project_env(dir_src)/rfx_rpadc_fifo_1.0.srcs/sources_1/bd/rpadc_1/hdl/rpadc_1_wrapper.v" \
    "$project_env(dir_prj)/rfx_rpadc_fifo_1.0.srcs/sources_1/bd/rpadc_1/hdl/rpadc_1_wrapper.v"
 set files [list \
  "[file normalize $project_env(dir_prj)/rfx_rpadc_fifo_1.0.srcs/sources_1/bd/rpadc_1/rpadc_1.bd]"\
  "[file normalize $project_env(dir_prj)/rfx_rpadc_fifo_1.0.srcs/sources_1/bd/rpadc_1/hdl/rpadc_1_wrapper.v]"\
 ]
 add_files -norecurse -fileset $obj $files
 # 
 # No properties for sources_1
 # Properties for rpadc_1.bd
  set file "$project_env(dir_prj)/rfx_rpadc_fifo_1.0.srcs/sources_1/bd/rpadc_1/rpadc_1.bd"
  set file_obj [get_files -of_objects [get_filesets sources_1] [list "$file"]]
  set_property -quiet "exclude_debug_logic" "0" $file_obj
  if { ![get_property "is_locked" $file_obj] } {
    set_property -quiet "generate_synth_checkpoint" "0" $file_obj
  }
  set_property -quiet "is_enabled" "1" $file_obj
  set_property -quiet "is_global_include" "0" $file_obj
  if { ![get_property "is_locked" $file_obj] } {
    set_property -quiet "is_locked" "0" $file_obj
  }
  set_property -quiet "library" "xil_defaultlib" $file_obj
  set_property -quiet "path_mode" "RelativeFirst" $file_obj
  if { ![get_property "is_locked" $file_obj] } {
    set_property -quiet "synth_checkpoint_mode" "None" $file_obj
  }
  set_property -quiet "used_in" "synthesis implementation simulation" $file_obj
  set_property -quiet "used_in_implementation" "1" $file_obj
  set_property -quiet "used_in_simulation" "1" $file_obj
  set_property -quiet "used_in_synthesis" "1" $file_obj
 # 
 # Properties for rpadc_1_wrapper.v
  set file "$project_env(dir_prj)/rfx_rpadc_fifo_1.0.srcs/sources_1/bd/rpadc_1/hdl/rpadc_1_wrapper.v"
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
  "[file normalize $make_env(srcdir)/./red_pitaya.xdc]"\
 ]
 add_files -norecurse -fileset $obj $files
 # 
 # Properties for red_pitaya.xdc
  set file "$project_env(dir_src)/../../red_pitaya.xdc"
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
