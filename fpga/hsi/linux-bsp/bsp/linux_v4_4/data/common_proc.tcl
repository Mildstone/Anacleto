


proc get_source_path { drv_handle } {

  set drv_name [common::get_property NAME $drv_handle]
  set dev_type [common::get_property CONFIG.dev_type $drv_handle]

  if {[llength $dev_type] != 0} {
   set dir [file normalize "../$dev_type"]
  } else {
   set dir [pwd]
  }

  return $dir
}

proc report_driver_properties { drv_handle } {
  puts " ** DRIVER HANDLER PROPERTIES ** "
  report_property $drv_handle
  puts ""
}

proc report_driver_peripherals { drv_handle } {
  # Get all peripherals connected to this driver
  set periphs [::hsi::utils::get_common_driver_ips $drv_handle]

  puts "-- Pheripheral found in block design --"
  puts ""
  foreach i $periphs {
    puts "  | $i |"
    puts ".------------------------------------------------------------------- "
    report_property $i
    puts ""
    ::hsi::utils::get_ip_sub_type $i
    puts ""
  }
}


proc write_define_file { drv_handle file_dst drv_string args } {
  # get args list
  set args [::hsi::utils::get_exact_arg_list $args]
  #
  # Get all peripherals connected to this driver
  set periphs [::hsi::utils::get_common_driver_ips $drv_handle]
  #
  #
  ## DEBUG: ##    print to STDOUT
  set file_handle stdout
  #
  # Print all parameters for all peripherals
  puts $file_handle "\n/******************************************************************/\n"
  puts ""
  set device_id 0
  foreach periph $periphs {
    puts $file_handle "/* Definitions for peripheral [string toupper [common::get_property NAME $periph]] */"
    foreach arg $args {
	if {[string compare -nocase "DEVICE_ID" $arg] == 0} {
	  set value $device_id
	  incr device_id
	} else {
	  set value [common::get_property CONFIG.$arg $periph]
	}
	if {[llength $value] == 0} {
	    set value 0
	}
	set value [::hsi::utils::format_addr_string $value $arg]
	if {[string compare -nocase "HW_VER" $arg] == 0} {
	    puts $file_handle "#define [::hsi::utils::get_ip_param_name $periph $arg] \"$value\""
	} else {
	    puts $file_handle "#define [::hsi::utils::get_ip_param_name $periph $arg] $value"
	}
    }
    puts $file_handle ""
  }
  puts $file_handle "\n/******************************************************************/\n"

}



# //////////////////////////////////////////////////////////////////////////// #
# ///  PARSE FILE  /////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #

# hkassem at gmail dot com - 2016
proc fforeach {fforeach_line_ref fforeach_file_path fforeach_body} {
    upvar $fforeach_line_ref fforeach_line
	set fforeach_fid [open $fforeach_file_path r]
    fconfigure $fforeach_fid -encoding utf-8
    while {[gets $fforeach_fid fforeach_line] >= 0} {
	    # for each lambda
	    uplevel $fforeach_body
    }
    close $fforeach_fid
 }

# PARSE FILE #
proc parse_file { drv_handle file_src file_dst drv_string subs_ref_list } {

  set periphs  [::hsi::utils::get_common_driver_ips $drv_handle]
  set drv_name [common::get_property NAME $drv_handle]
  upvar $subs_ref_list words


  set file_src [file normalize "[get_source_path $drv_handle]/$file_src" ]
  set file_dst [file normalize $file_dst]
  puts " parsing in: $file_dst"
  set file_dst [open $file_dst "w"]
  fforeach line $file_src {
    puts $file_dst [string map $words $line]
  }
  close $file_dst

}
