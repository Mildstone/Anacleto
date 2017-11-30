
global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)


# create block design
create_bd_design "procsys"
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 ps7
set ps7 [get_bd_cells ps7]
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
					-config {make_external "FIXED_IO, DDR" Master "Disable" Slave "Disable" } $ps7

# apply preset
source $top_srcdir/fpga/red_pitaya_rfxpreset.tcl
set_property -dict [apply_preset $ps7] $ps7
set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {125} \
						 CONFIG.PCW_USE_M_AXI_GP0 {1} \
						 ] $ps7


#set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {125} \
#						 CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {142.86} \
#						 CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {200} \
#						 CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {166.67} \
#						 CONFIG.PCW_EN_CLK1_PORT {1} \
#						 CONFIG.PCW_EN_CLK2_PORT {1} \
#						 CONFIG.PCW_EN_CLK3_PORT {1} \
#						 CONFIG.PCW_USE_M_AXI_GP0 {1} \
#						 CONFIG.PCW_USE_S_AXI_HP0 {1}\
#						 ] $ps7
