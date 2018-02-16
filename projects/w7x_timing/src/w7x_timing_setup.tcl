#-----------------------------------------------------------
# Vivado v2017.2 (64-bit)
# SW Build 1909853 on Thu Jun 15 18:39:10 MDT 2017
# IP Build 1909766 on Thu Jun 15 19:58:00 MDT 2017
# Start of session at: Tue Nov 21 15:52:01 2017
# Process ID: 17661
# Current directory: /home/andrea/devel/rfx/anacleto/build/projects/w7x_timing
# Command line: vivado -nolog -journal vivado_shell_jou.tcl -mode tcl -source /home/andrea/devel/rfx/anacleto/build/../fpga/vivado_make.tcl -tclargs edit_ip
# Log file: 
# Journal file: /home/andrea/devel/rfx/anacleto/build/projects/w7x_timing/vivado_shell_jou.tcl
#-----------------------------------------------------------



ipx::add_bus_interface BRAM_A [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:bram_rtl:1.0 [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:bram:1.0 [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
set_property interface_mode master [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
ipx::add_port_map RST [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
set_property physical_name bram_rsta [ipx::get_port_maps RST -of_objects [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]]
ipx::add_port_map CLK [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
set_property physical_name bram_clka [ipx::get_port_maps CLK -of_objects [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]]
ipx::add_port_map DIN [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
set_property physical_name bram_dina [ipx::get_port_maps DIN -of_objects [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]]
ipx::add_port_map EN [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
set_property physical_name bram_ena [ipx::get_port_maps EN -of_objects [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]]
ipx::add_port_map DOUT [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
set_property physical_name bram_douta [ipx::get_port_maps DOUT -of_objects [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]]
ipx::add_port_map WE [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
set_property physical_name bram_wea [ipx::get_port_maps WE -of_objects [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]]
ipx::add_port_map ADDR [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
set_property physical_name bram_addra [ipx::get_port_maps ADDR -of_objects [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]]




