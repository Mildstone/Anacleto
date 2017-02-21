

############################################################################
# IO constraints                                                           #
############################################################################

#### DIO
#DIO0-7_P
set_property PACKAGE_PIN G17 [get_ports trig_in]
set_property PACKAGE_PIN H16 [get_ports  clk_in]
set_property PACKAGE_PIN J18 [get_ports {state1[2]}]
set_property PACKAGE_PIN K17 [get_ports {state1[3]}]
set_property PACKAGE_PIN L14 [get_ports {state1[4]}]
set_property PACKAGE_PIN L16 [get_ports {state1[5]}]
set_property PACKAGE_PIN K16 [get_ports {state1[6]}]
set_property PACKAGE_PIN M14 [get_ports {state1[7]}]
#DIO0-7_N
set_property PACKAGE_PIN G18 [get_ports {state0[0]}]
set_property PACKAGE_PIN H17 [get_ports {state0[1]}]
set_property PACKAGE_PIN H18 [get_ports {state0[2]}]
set_property PACKAGE_PIN K18 [get_ports {state0[3]}]
set_property PACKAGE_PIN L15 [get_ports {state0[4]}]
set_property PACKAGE_PIN L17 [get_ports {state0[5]}]
set_property PACKAGE_PIN J16 [get_ports {state0[6]}]
set_property PACKAGE_PIN M15 [get_ports {state0[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {state0[*] state1[*] trig_in clk_in}]
set_property PULLDOWN true       [get_ports {trig_in clk_in}]
set_property SLEW FAST [get_ports {state0[*] state1[*]}]
set_property DRIVE 8   [get_ports {state0[*] state1[*]}]

#### LED PINS
set_property PACKAGE_PIN F16 [get_ports {state_leds[0]}]
set_property PACKAGE_PIN F17 [get_ports {state_leds[1]}]
set_property PACKAGE_PIN G15 [get_ports {state_leds[2]}]
set_property PACKAGE_PIN H15 [get_ports {state_leds[3]}]
set_property PACKAGE_PIN K14 [get_ports {state_leds[4]}]
set_property PACKAGE_PIN G14 [get_ports {state_leds[5]}]
set_property PACKAGE_PIN J15 [get_ports {state_leds[6]}]
set_property PACKAGE_PIN J14 [get_ports {state_leds[7]}]
set_property SLEW SLOW       [get_ports {state_leds[*]}]
set_property DRIVE 4         [get_ports {state_leds[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {state_leds[*]}]

create_clock -period 100.000 -name clk_in -waveform {0.000 50.000} [get_ports clk_in]
set_clock_groups -name async -asynchronous -group clk_in -group clk_fpga_0
#
set_output_delay -clock [get_clocks clk_in] -min  0 [get_ports {state0[*] state1[*] state_leds[*]}]
set_output_delay -clock [get_clocks clk_in] -max 10 [get_ports {state0[*] state1[*] state_leds[*]}]
set_input_delay  -clock [get_clocks clk_in] -min  0 [get_ports {trig_in}]
set_input_delay  -clock [get_clocks clk_in] -max 10 [get_ports {trig_in}]
