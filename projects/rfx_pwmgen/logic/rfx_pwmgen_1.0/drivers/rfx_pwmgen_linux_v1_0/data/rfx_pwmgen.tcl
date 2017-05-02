
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

proc generate {drv_handle} {
	puts ""
	puts "//  "
	puts "//  LINUX DRIVER FOR RFX PWMGEN "
	puts "//  "

	set dev_type [get_property "CONFIG.dev_type" $drv_handle]
	source_core_tcl $dev_type "${dev_type}.tcl"
	generate $drv_handle
	puts "// LINUX DRIVER RFX PWMGEN END "
}




