

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



# --------------------------------------
# Tcl procedure standalone_drc
# -------------------------------------
proc linux_drc {os_handle} {
 puts "-- DRC --"
}

# --------------------------------------
# Tcl procedure generate
# -------------------------------------
proc generate {os_handle} {
	global env
	puts "-- GENERATE LINUX V4 --"
	set os_core_v    [string map {. _} [get_property "VERSION" [get_os]]]
	set os_core_name "[get_os]_v${os_core_v}"
	source_core_tcl  $os_core_name "dt_common_proc.tcl"
	source_core_tcl  $os_core_name "common_proc.tcl"

	puts "| ========= LIST OF ACTIVE PERIPHERALS ======="
	puts "|    NAME \t\t DRIVER "
	foreach drv_handle [get_drivers] {
	  set hw_instance [common::get_property HW_INSTANCE $drv_handle]
	  set drv_name    [common::get_property NAME $drv_handle]
	  puts "| ${hw_instance} \t\t ${drv_name}"
	}
	puts ""
	puts ""
}
