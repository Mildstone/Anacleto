

############################################################################
# IO constraints                                                           #
############################################################################

#### DIO
#set_property PACKAGE_PIN G17 [get_ports {p[0]}]
#set_property PACKAGE_PIN H16 [get_ports {p[1]}]
#set_property PACKAGE_PIN J18 [get_ports {p[2]}]
#set_property PACKAGE_PIN K17 [get_ports {p[3]}]
#set_property PACKAGE_PIN L14 [get_ports {p[4]}]
#set_property PACKAGE_PIN L16 [get_ports {p[5]}]
#set_property PACKAGE_PIN K16 [get_ports {p[6]}]
#set_property PACKAGE_PIN M14 [get_ports {p[7]}]

#DIO0-1_P
set_property PACKAGE_PIN G17 [get_ports trig_in]
set_property PACKAGE_PIN H16 [get_ports clk_in]
set_property IOSTANDARD LVCMOS33 [get_ports trig_in]
set_property IOSTANDARD LVCMOS33 [get_ports clk_in]
set_property PULLDOWN true [get_ports trig_in]
set_property PULLDOWN true [get_ports clk_in]

#DIO2-7_P
set_property PACKAGE_PIN J18 [get_ports {state_inv[0]}]
set_property PACKAGE_PIN K17 [get_ports {state_inv[1]}]
set_property PACKAGE_PIN L14 [get_ports {state_inv[2]}]
set_property PACKAGE_PIN L16 [get_ports {state_inv[3]}]
set_property PACKAGE_PIN K16 [get_ports {state_inv[4]}]
set_property PACKAGE_PIN M14 [get_ports {state_inv[5]}]

#set_property PACKAGE_PIN G18 [get_ports {n[0]}]
#set_property PACKAGE_PIN H17 [get_ports {n[1]}]
#set_property PACKAGE_PIN H18 [get_ports {n[2]}]
#set_property PACKAGE_PIN K18 [get_ports {n[3]}]
#set_property PACKAGE_PIN L15 [get_ports {n[4]}]
#set_property PACKAGE_PIN L17 [get_ports {n[5]}]
#set_property PACKAGE_PIN J16 [get_ports {n[6]}]
#set_property PACKAGE_PIN M15 [get_ports {n[7]}]
#DIO0-7_N
set_property PACKAGE_PIN G18 [get_ports trig_out]
set_property PACKAGE_PIN H17 [get_ports clk_out]
set_property PACKAGE_PIN H18 [get_ports {state[2]}]
set_property PACKAGE_PIN K18 [get_ports {state[3]}]
set_property PACKAGE_PIN L15 [get_ports {state[4]}]
set_property PACKAGE_PIN L17 [get_ports {state[5]}]
set_property PACKAGE_PIN J16 [get_ports {state[6]}]
set_property PACKAGE_PIN M15 [get_ports {state[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {{state[*]} {state_inv[*]} trig_out clk_out}]
set_property SLEW FAST [get_ports {{state[*]} {state_inv[*]} trig_out clk_out}]
set_property DRIVE 8 [get_ports {{state[*]} {state_inv[*]} trig_out clk_out}]

#### LED PINS
# set_property PACKAGE_PIN F16    [get_ports {led[0]}]
# set_property PACKAGE_PIN F17    [get_ports {led[1]}]
# set_property PACKAGE_PIN G15    [get_ports {led[2]}]
# set_property PACKAGE_PIN H15    [get_ports {led[3]}]
# set_property PACKAGE_PIN K14    [get_ports {led[4]}]
# set_property PACKAGE_PIN G14    [get_ports {led[5]}]
# set_property PACKAGE_PIN J15    [get_ports {led[6]}]
# set_property PACKAGE_PIN J14    [get_ports {led[7]}]

set_property PACKAGE_PIN F16 [get_ports {state_leds[0]}]
set_property PACKAGE_PIN F17 [get_ports {state_leds[1]}]
set_property PACKAGE_PIN G15 [get_ports {state_leds[2]}]
set_property PACKAGE_PIN H15 [get_ports {state_leds[3]}]
set_property PACKAGE_PIN K14 [get_ports {state_leds[4]}]
set_property PACKAGE_PIN G14 [get_ports {state_leds[5]}]
set_property PACKAGE_PIN J15 [get_ports {state_leds[6]}]
set_property PACKAGE_PIN J14 [get_ports {state_leds[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {state_leds[*]}]
set_property SLEW SLOW [get_ports {state_leds[*]}]
set_property DRIVE 4 [get_ports {state_leds[*]}]



create_clock -period 100.000 -name clk_in -waveform {0.000 50.000} [get_ports clk_in]
set_clock_groups -name async -asynchronous -group clk_in -group clk_fpga_0
#
set_input_delay -clock [get_clocks clk_in] -min 0.000 [get_ports trig_in]
set_input_delay -clock [get_clocks clk_in] -max 10.000 [get_ports trig_in]
#
set_output_delay -clock [get_clocks clk_in] -min 0.000 [get_ports trig_out]
set_output_delay -clock [get_clocks clk_in] -max 10.000 [get_ports trig_out]
#
set_output_delay -clock [get_clocks clk_in] -min 0.000 [get_ports clk_out]
set_output_delay -clock [get_clocks clk_in] -max 10.000 [get_ports clk_out]
#
set_output_delay -clock [get_clocks clk_in] -min 0.000 [get_ports {state[*]}]
set_output_delay -clock [get_clocks clk_in] -max 10.000 [get_ports {state[*]}]
set_output_delay -clock [get_clocks clk_in] -min 0.000 [get_ports {state_inv[*]}]
set_output_delay -clock [get_clocks clk_in] -max 10.000 [get_ports {state_inv[*]}]
#
set_output_delay -clock [get_clocks clk_in] -min 0.000 [get_ports {state_leds[*]}]
set_output_delay -clock [get_clocks clk_in] -max 10.000 [get_ports {state_leds[*]}]

set_multicycle_path -from [get_clocks clk_fpga_0] -to [get_clocks clk_out1_system_clk_wiz_0_0] 1
