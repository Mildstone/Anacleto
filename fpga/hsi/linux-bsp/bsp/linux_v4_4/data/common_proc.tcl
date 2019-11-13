


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
  puts ""
  set drv_name [common::get_property NAME $drv_handle]
  set sw_cores [get_sw_cores $drv_name]
  foreach i $sw_cores {
	puts "  | $i |"
	puts ".------------------------------------------------------------------- "
	report_property $i
	puts ""
	puts ""
  }
}

proc report_driver_peripherals { drv_handle } {
  # Get all peripherals connected to this driver
  set periphs [::hsi::utils::get_common_driver_ips $drv_handle]

  puts "-- Pheriperal found in block design --"
  puts ""
  foreach i $periphs {
	puts "  | $i | [::hsi::utils::get_ip_sub_type $i]"
    puts ".------------------------------------------------------------------- "
    report_property $i
	puts ""
    puts ""
  }
}



proc report_reg_property {drv_handle {skip_ps_check ""}} {

	if {[string_is_empty $skip_ps_check]} {
		if {[is_ps_ip $drv_handle]} {
			return 0
		}
	}

	set reg ""
	set slave [get_cells -hier ${drv_handle}]
	set ip_mem_handles [hsi::utils::get_ip_mem_ranges $slave]
	foreach mem_handle ${ip_mem_handles} {
		set base [string tolower [get_property BASE_VALUE $mem_handle]]
		set high [string tolower [get_property HIGH_VALUE $mem_handle]]
		set size [format 0x%x [expr {${high} - ${base} + 1}]]
		set proctype [get_property IP_NAME [get_cells -hier [get_sw_processor]]]
		if {[string_is_empty $reg]} {
			if {[string match -nocase $proctype "psu_cortexa53"]} {
				# check if base address is 64bit and split it as MSB and LSB
				if {[regexp -nocase {0x([0-9a-f]{9})} "$base" match]} {
					set temp $base
					set temp [string trimleft [string trimleft $temp 0] x]
					set len [string length $temp]
					set rem [expr {${len} - 8}]
					set high_base "0x[string range $temp $rem $len]"
					set low_base "0x[string range $temp 0 [expr {${rem} - 1}]]"
					set low_base [format 0x%08x $low_base]
					set reg "$low_base $high_base 0x0 $size"
				} else {
					set reg "0x0 $base 0x0 $size"
				}
			} else {
				set reg "$base $size"
			}
		} else {
			# ensure no duplication
			if {![regexp ".*${reg}.*" "$base $size" matched]} {
				set reg "$reg $base $size"
			}
		}
	}
	# set_drv_prop_if_empty $drv_handle reg $reg intlist
	puts " \[reg\] ---- > ${reg}"
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
proc parse_file2 { drv_handle file_src file_dst drv_string subs_ref_list } {

  set periphs  [::hsi::utils::get_common_driver_ips $drv_handle]
  set drv_name [common::get_property NAME $drv_handle]
  upvar $subs_ref_list words	

  set file_src [file normalize $file_src ]
  set file_dst [file normalize $file_dst]
  puts " parsing in: [file tail $file_dst]"
  set file_dst [open $file_dst "w"]
  fforeach line $file_src {
    puts $file_dst [string map $words $line]
  }
  close $file_dst

}

# PARSE FILE #
proc parse_file { drv_handle file_src file_dst sw } {  
  set drv_name [common::get_property NAME $drv_handle]
  # prepare substitution list for parser map #  
	uplevel {
	  set li [list]
    foreach node [array names sw] {	  	
      lappend li "\$$node\$"
      if {[catch {lappend li [expr $sw($node)]}]} {
       lappend li $sw($node)
      }
    }
	}
	upvar li li

  set file_src [file normalize $file_src ]
  set file_dst [file normalize $file_dst]
  puts " parsing in: [file tail $file_dst]"
  set file_dst [open $file_dst "w"]
  fforeach line $file_src {
    puts $file_dst [string map $li $line]
  }
  close $file_dst
}
