# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set C_S00_AXI_DATA_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH" -parent ${Page_0} -widget comboBox]
  set_property tooltip {Width of S_AXI data bus} ${C_S00_AXI_DATA_WIDTH}
  set C_S00_AXI_ADDR_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of S_AXI address bus} ${C_S00_AXI_ADDR_WIDTH}
  ipgui::add_param $IPINST -name "C_S00_AXI_BASEADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S00_AXI_HIGHADDR" -parent ${Page_0}

  ipgui::add_param $IPINST -name "IN_AXI"
  ipgui::add_param $IPINST -name "OUT_DATA_SIZE"
  ipgui::add_param $IPINST -name "OUT_DATA_WIDTH"
  ipgui::add_param $IPINST -name "IN_DATA_MAX"

}

proc update_PARAM_VALUE.IN_AXI { PARAM_VALUE.IN_AXI } {
	# Procedure called to update IN_AXI when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IN_AXI { PARAM_VALUE.IN_AXI } {
	# Procedure called to validate IN_AXI
	return true
}

proc update_PARAM_VALUE.IN_DATA_MAX { PARAM_VALUE.IN_DATA_MAX } {
	# Procedure called to update IN_DATA_MAX when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IN_DATA_MAX { PARAM_VALUE.IN_DATA_MAX } {
	# Procedure called to validate IN_DATA_MAX
	return true
}

proc update_PARAM_VALUE.OUT_DATA_SIZE { PARAM_VALUE.OUT_DATA_SIZE } {
	# Procedure called to update OUT_DATA_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT_DATA_SIZE { PARAM_VALUE.OUT_DATA_SIZE } {
	# Procedure called to validate OUT_DATA_SIZE
	return true
}

proc update_PARAM_VALUE.OUT_DATA_WIDTH { PARAM_VALUE.OUT_DATA_WIDTH } {
	# Procedure called to update OUT_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT_DATA_WIDTH { PARAM_VALUE.OUT_DATA_WIDTH } {
	# Procedure called to validate OUT_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to update C_S00_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S00_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S00_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S00_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_BASEADDR { PARAM_VALUE.C_S00_AXI_BASEADDR } {
	# Procedure called to update C_S00_AXI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_BASEADDR { PARAM_VALUE.C_S00_AXI_BASEADDR } {
	# Procedure called to validate C_S00_AXI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_HIGHADDR { PARAM_VALUE.C_S00_AXI_HIGHADDR } {
	# Procedure called to update C_S00_AXI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_HIGHADDR { PARAM_VALUE.C_S00_AXI_HIGHADDR } {
	# Procedure called to validate C_S00_AXI_HIGHADDR
	return true
}


proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.OUT_DATA_WIDTH { MODELPARAM_VALUE.OUT_DATA_WIDTH PARAM_VALUE.OUT_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT_DATA_WIDTH}] ${MODELPARAM_VALUE.OUT_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.OUT_DATA_SIZE { MODELPARAM_VALUE.OUT_DATA_SIZE PARAM_VALUE.OUT_DATA_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT_DATA_SIZE}] ${MODELPARAM_VALUE.OUT_DATA_SIZE}
}

proc update_MODELPARAM_VALUE.IN_AXI { MODELPARAM_VALUE.IN_AXI PARAM_VALUE.IN_AXI } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IN_AXI}] ${MODELPARAM_VALUE.IN_AXI}
}

proc update_MODELPARAM_VALUE.IN_DATA_MAX { MODELPARAM_VALUE.IN_DATA_MAX PARAM_VALUE.IN_DATA_MAX } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IN_DATA_MAX}] ${MODELPARAM_VALUE.IN_DATA_MAX}
}

