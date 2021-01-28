

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


proc generate_reg_file {} {
  ## ///////////////////////////////////////////////////////////////////////////
  ## //  REG.H  ////////////////////////////////////////////////////////////////
  ##
  set periphs [::hsi::utils::get_common_driver_ips $drv_handle]
  set li [list]
  foreach i $periphs {
	set c_name [common::get_property CONFIG.Component_Name $i]
	set l_addr [common::get_property CONFIG.C_BASEADDR $i]
	set h_addr [common::get_property CONFIG.C_HIGHADDR $i]
	lappend li "void *$c_name\[\] = {$l_addr, $h_addr};"
  }
  set file_dst [open "src/${drv_name}_reg.h" "w"]
  foreach l $li {
   puts $file_dst "$l"
  }
  close $file_dst
}




proc generate { drv_handle } {
  puts ""
  puts "-- GENERATE MMIO --"

  set os_core_v    [string map {. _} [get_property "VERSION" [get_os]]]
  set os_core_name "[get_os]_v${os_core_v}"
  source_core_tcl  $os_core_name "dt_common_proc.tcl"
  source_core_tcl  $os_core_name "common_proc.tcl"

  gen_peripheral_nodes $drv_handle "create_node_only"
  gen_reg_property $drv_handle
  gen_compatible_property $drv_handle
  gen_drv_prop_from_ip $drv_handle
  gen_interrupt_property $drv_handle

  report_driver_properties  $drv_handle
  # report_driver_peripherals $drv_handle


  ## ///////////////////////////////////////////////////////////////////////////
  ## //  DRV  //////////////////////////////////////////////////////////////////
  ##
  # set variables
  set drv_name [common::get_property NAME $drv_handle]
  set src_dir  [get_property "REPOSITORY" [get_sw_cores $drv_name]]
  set dst_dir  [get_source_path $drv_handle]
  set hw_cell  [get_cell [common::get_property HW_INSTANCE $drv_handle]]
  set ip_name  [get_property "IP_NAME" $hw_cell]


  array set sw {
    os_core     {$os_core_name}
    ip_name     {$ip_name}
    IP_NAME     {[string toupper $ip_name]}
    mod_name    {$drv_name}
    MOD_NAME    {[string toupper $drv_name]}
    hw_instance {[get_property HW_INSTANCE $drv_handle]}
    hw_version  {[get_property VERSION $drv_handle]}
    hw_name     {[get_property NAME $drv_handle]}
    compatible  {[get_property CONFIG.compatible $drv_handle]}
	  reg         {[get_property CONFIG.reg $drv_handle]}
    dev_type    {[get_property CONFIG.dev_type $drv_handle]}
  }

  
  parse_file $drv_handle "${src_dir}/src/axi_mmio.c" "src/${ip_name}.c" sw;
  parse_file $drv_handle "${src_dir}/src/axi_mmio.h" "src/${ip_name}.h" sw;
  parse_file $drv_handle "${src_dir}/src/Makefile.am" "src/Makefile.am" sw;

}







