
################################################################################
# define paths
################################################################################

global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)

proc srcdir     {} { variable srcdir; return $srcdir }
proc top_srcdir {} { variable srcdir; return $srcdir }
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
  set version [getenv VERSION]
  if { $version eq "" } {set version 1.0}
  set project_name [getenv BOARD]_${name}_${version}
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
  set version [getenv VERSION]
  if { $version eq "" } {set version 1.0}
  switch $mode {
    "src"  {return [srcdir]/[getenv BOARD]/${name}_${version}}
    "edit" {return [getenv BOARD]/${name}_${version}_edit}
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

