

############################################################################
# IO constraints                                                           #
############################################################################

#### DIO
#p->in
#set_property PACKAGE_PIN G17 [get_ports {p[0]}]
#set_property PACKAGE_PIN H16 [get_ports {p[1]}]
#set_property PACKAGE_PIN J18 [get_ports {p[2]}]
#set_property PACKAGE_PIN K17 [get_ports {p[3]}]
#set_property PACKAGE_PIN L14 [get_ports {p[4]}]
#set_property PACKAGE_PIN L16 [get_ports {p[5]}]
#set_property PACKAGE_PIN K16 [get_ports {p[6]}]
#set_property PACKAGE_PIN M14 [get_ports {p[7]}]
#DIO0_P
set_property PACKAGE_PIN G17     [get_ports trig]
set_property IOSTANDARD LVCMOS33 [get_ports trig]
set_property PULLTYPE PULLDOWN   [get_ports trig]
#DIO1_P
set_property PACKAGE_PIN H16     [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PULLTYPE PULLDOWN   [get_ports clk]

#n->out
#set_property PACKAGE_PIN G18 [get_ports {n[0]}]
#set_property PACKAGE_PIN H17 [get_ports {n[1]}]
#set_property PACKAGE_PIN H18 [get_ports {n[2]}]
#set_property PACKAGE_PIN K18 [get_ports {n[3]}]
#set_property PACKAGE_PIN L15 [get_ports {n[4]}]
#set_property PACKAGE_PIN L17 [get_ports {n[5]}]
#set_property PACKAGE_PIN J16 [get_ports {n[6]}]
#set_property PACKAGE_PIN M15 [get_ports {n[7]}]
#DIO0-5_N
set_property PACKAGE_PIN G18     [get_ports {state[0]}]
set_property PACKAGE_PIN H17     [get_ports {state[1]}]
set_property PACKAGE_PIN H18     [get_ports {state[2]}]
set_property PACKAGE_PIN K18     [get_ports {state[3]}]
set_property PACKAGE_PIN L15     [get_ports {state[4]}]
set_property PACKAGE_PIN L17     [get_ports {state[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {state[*]}]
set_property SLEW FAST           [get_ports {state[*]}]
set_property DRIVE 8             [get_ports {state[*]}]


#### LED PINS
# set_property PACKAGE_PIN F16    [get_ports {led[0]}]
# set_property PACKAGE_PIN F17    [get_ports {led[1]}]
# set_property PACKAGE_PIN G15    [get_ports {led[2]}]
# set_property PACKAGE_PIN H15    [get_ports {led[3]}]
# set_property PACKAGE_PIN K14    [get_ports {led[4]}]
# set_property PACKAGE_PIN G14    [get_ports {led[5]}]
# set_property PACKAGE_PIN J15    [get_ports {led[6]}]
# set_property PACKAGE_PIN J14    [get_ports {led[7]}]

set_property PACKAGE_PIN F16     [get_ports {state_leds[0]}]
set_property PACKAGE_PIN F17     [get_ports {state_leds[1]}]
set_property PACKAGE_PIN G15     [get_ports {state_leds[2]}]
set_property PACKAGE_PIN H15     [get_ports {state_leds[3]}]
set_property PACKAGE_PIN K14     [get_ports {state_leds[4]}]
set_property PACKAGE_PIN G14     [get_ports {state_leds[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {state_leds[*]}]
set_property SLEW SLOW           [get_ports {state_leds[*]}]
set_property DRIVE 4             [get_ports {state_leds[*]}]

set_property PACKAGE_PIN J15     [get_ports clk_led]
set_property IOSTANDARD LVCMOS33 [get_ports clk_led]
set_property SLEW SLOW           [get_ports clk_led]
set_property DRIVE 4             [get_ports clk_led]

set_property PACKAGE_PIN J14     [get_ports trig_led]
set_property IOSTANDARD LVCMOS33 [get_ports trig_led]
set_property SLEW SLOW           [get_ports trig_led]
set_property DRIVE 4             [get_ports trig_led]


create_clock -period 100.000 -name clk -waveform {0.0 50.0} [get_ports clk]
set_clock_groups -name async -asynchronous -group {clk,clk_in} -group {clk_fpga_0,s00_axi_aclk, clk_fpga_1}
#
set_input_delay  -clock [get_clocks clk] -min  0.0 [get_ports trig]
set_input_delay  -clock [get_clocks clk] -max 10.0 [get_ports trig]
#
set_output_delay -clock [get_clocks clk] -min  0.0 [get_ports {state[*]}]
set_output_delay -clock [get_clocks clk] -max 10.0 [get_ports {state[*]}]
#
set_output_delay -clock [get_clocks clk] -min  0.0 [get_ports {state_leds[*]}]
set_output_delay -clock [get_clocks clk] -max 50.0 [get_ports {state_leds[*]}]
