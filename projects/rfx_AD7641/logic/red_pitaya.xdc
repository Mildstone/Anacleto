

############################################################################
# IO constraints                                                           #
############################################################################

### LED PINS
#set_property PACKAGE_PIN F16 [get_ports led_o]
#set_property PACKAGE_PIN F17 [get_ports {pwm_out_1[0]}]
#set_property PACKAGE_PIN G15 [get_ports {pwm_n_out_1[0]}]
# set_property PACKAGE_PIN H15     [get_ports {led_o[3]}]
# set_property PACKAGE_PIN K14     [get_ports {led_o[4]}]
# set_property PACKAGE_PIN G14     [get_ports {led_o[5]}]
# set_property PACKAGE_PIN J15     [get_ports {led_o[6]}]
# set_property PACKAGE_PIN J14     [get_ports {led_o[7]}]


set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

set_property IOSTANDARD LVCMOS33 [get_ports prescaler_output_clk]
set_property SLEW FAST [get_ports prescaler_output_clk]
set_property PULLDOWN true [get_ports prescaler_output_clk]
set_property PACKAGE_PIN G17 [get_ports prescaler_output_clk]

set_property IOSTANDARD LVCMOS33 [get_ports prescaler_output_clk_1]
set_property SLEW FAST [get_ports prescaler_output_clk_1]
set_property PULLDOWN true [get_ports prescaler_output_clk_1]
set_property PACKAGE_PIN F16 [get_ports prescaler_output_clk_1]

set_property PACKAGE_PIN F17 [get_ports {led_o[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_o[0]}]
set_property PULLDOWN true [get_ports {led_o[0]}]
