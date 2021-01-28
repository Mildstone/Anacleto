


puts " ------------------ "
puts " SETTING BRAM PORTS "
puts " ------------------ "


# BRAM_A
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


# BRAM_B
ipx::add_bus_interface BRAM_B [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:bram_rtl:1.0 [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:bram:1.0 [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]
set_property interface_mode master [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]
set_property display_name BRAM_B [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]
set_property description BRAM_B [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]
ipx::add_port_map DOUT [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]
set_property physical_name bram_doutb [ipx::get_port_maps DOUT -of_objects [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]]
ipx::add_port_map RST [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]
set_property physical_name bram_rstb [ipx::get_port_maps RST -of_objects [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]]
ipx::add_port_map CLK [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]
set_property physical_name bram_clkb [ipx::get_port_maps CLK -of_objects [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]]
ipx::add_port_map ADDR [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]
set_property physical_name bram_addrb [ipx::get_port_maps ADDR -of_objects [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]]


