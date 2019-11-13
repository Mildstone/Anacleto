

proc source_core_tcl { sw_core tcl_script } {
  # assuming the order of return is based on repo priority
  foreach i [get_sw_cores $sw_core] {
	set common_tcl_file "[get_property "REPOSITORY" $i]/data/$tcl_script"
	# puts " --- $common_tcl_file"
	if {[file exists $common_tcl_file]} {
	  source $common_tcl_file
	  break
	}
  }
}


proc generate { drv_handle } {
  puts ""
  puts "-- GENERATE GENERIC --"

  set os_core_v    [string map {. _} [get_property "VERSION" [get_os]]]
  set os_core_name "[get_os]_v${os_core_v}"
  source_core_tcl  $os_core_name "dt_common_proc.tcl"
  source_core_tcl  $os_core_name "common_proc.tcl"

  gen_compatible_property $drv_handle
  gen_reg_property $drv_handle

  report_driver_properties  $drv_handle
  report_reg_property $drv_handle
}



