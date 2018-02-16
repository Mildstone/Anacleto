

proc source_core_tcl { sw_core tcl_script } {
  # assuming the order of return is based on repo priority
  foreach i [get_sw_cores $sw_core] {
    set common_tcl_file "[get_property "REPOSITORY" $i]/data/$tcl_script"
    puts " --- $common_tcl_file"
    if {[file exists $common_tcl_file]} {
      source $common_tcl_file
      break
    }
  }
}



proc generate { drv_handle } {
  puts "-- GENERATE MMIO --"
  set os_core_v    [string map {. _} [get_property "VERSION" [get_os]]]
  set os_core_name "[get_os]_v${os_core_v}"
  source_core_tcl  $os_core_name "dt_common_proc.tcl"
  source_core_tcl  $os_core_name "common_proc.tcl"

  gen_compatible_property $drv_handle

  # set variables
  set drv_name [common::get_property NAME $drv_handle]
  array set sw {
  # -------------------------------------------------
    os_core     $os_core_name
    mod_name    $drv_name
    modname     $drv_name
    hw_instance {[common::get_property HW_INSTANCE $drv_handle]}
    hw_version  {[common::get_property VERSION $drv_handle]}
    hw_name     {[common::get_property NAME $drv_handle]}
    compatible  {[common::get_property CONFIG.compatible $drv_handle]}
    dev_type    {[common::get_property CONFIG.dev_type $drv_handle]}
  # --------------------------------------------------
  }

  # prepare substitution list for parser map #
  set li [list]
  foreach node [array names sw] {
    lappend li "@$node@"
    if {[catch {lappend li [expr $sw($node)]}]} {
     lappend li $sw($node)
    }
  }

  report_driver_properties  $drv_handle
  report_driver_peripherals $drv_handle
  parse_file $drv_handle "src/axi_mmio.c.template" "src/${drv_name}.c" "axi_mmio" li;
  parse_file $drv_handle "src/axi_mmio.h.template" "src/${drv_name}.h" "axi_mmio" li;
}
