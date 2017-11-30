
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

