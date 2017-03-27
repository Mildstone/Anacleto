
################################################################################
# define paths
################################################################################

global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)

set_param general.maxThreads $env(maxThreads)


namespace eval ::tclapp::socdev::makeutils {

  variable make_env
  variable project_set
  variable project_env


proc  getenv { name {default ""}} {
  variable ::env
  if { [info exists env($name)] } {
    return $env($name)
  } else {
    return $default
  }
}

proc compute_project_name {} {
  set project_name [getenv PROJECT_NAME]
  if { $project_name eq "" } {
    set project_name [getenv SOC_BOARD]
  } else {
    set project_name ${project_name}_[getenv SOC_BOARD]
  }
  return $project_name
}

proc reset_make_env {} {
  variable make_env
  set    make_env(project_name)     [compute_project_name]
  set    make_env(soc_board)        [getenv SOC_BOARD]
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

  set project_set(VIVADO_VERSION) "\$make_env(VIVADO_VERSION)"
  set project_set(project_name)   "\$make_env(project_name)"
  set project_set(dir_prj)        "vivado_project"
  set project_set(dir_src)        "\$make_env(srcdir)/vivado_src"
  set project_set(dir_sdc)        "sdc"
  set project_set(dir_out)        "out"
  set project_set(dir_sdk)        "sdk"

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
  close $fp
  set make_env(self) [list]
  lappend make_env(self) {*}$introspection
}
set_socdev_env

}

