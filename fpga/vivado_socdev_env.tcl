
################################################################################
# define paths
################################################################################

global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)

set_param general.maxThreads $env(maxThreads)


namespace eval ::tclapp::socdev::makeutils {
  variable make_env


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
  variable ::env
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

}

