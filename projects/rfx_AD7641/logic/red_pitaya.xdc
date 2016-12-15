

############################################################################
# IO constraints                                                           #
############################################################################

### LED
set_property IOSTANDARD LVCMOS33 [get_ports led_o]
set_property SLEW SLOW [get_ports led_o]
set_property DRIVE 4 [get_ports led_o]

### PWM
set_property IOSTANDARD LVCMOS33 [get_ports {pwm_out[0]}]
set_property SLEW FAST [get_ports {pwm_out[0]}]
set_property DRIVE 4 [get_ports {pwm_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pwm_n_out[0]}]
set_property SLEW FAST [get_ports {pwm_n_out[0]}]
set_property DRIVE 4 [get_ports {pwm_n_out[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {pwm_out_1[0]}]
set_property SLEW FAST [get_ports {pwm_out_1[0]}]
set_property DRIVE 4 [get_ports {pwm_out_1[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pwm_n_out_1[0]}]
set_property SLEW FAST [get_ports {pwm_n_out_1[0]}]
set_property DRIVE 4 [get_ports {pwm_n_out_1[0]}]

### IO PINS
set_property PACKAGE_PIN G17 [get_ports {pwm_out[0]}]


### LED PINS
set_property PACKAGE_PIN F16 [get_ports led_o]
set_property PACKAGE_PIN G15 [get_ports {pwm_n_out_1[0]}]
# set_property PACKAGE_PIN H15     [get_ports {led_o[3]}]
# set_property PACKAGE_PIN K14     [get_ports {led_o[4]}]
# set_property PACKAGE_PIN G14     [get_ports {led_o[5]}]
# set_property PACKAGE_PIN J15     [get_ports {led_o[6]}]
# set_property PACKAGE_PIN J14     [get_ports {led_o[7]}]


set_property IOSTANDARD LVCMOS33 [get_ports prescaler_output_LED_clk]
set_property IOSTANDARD LVCMOS33 [get_ports prescaler_output_clk_negato_2]
set_property PACKAGE_PIN H15 [get_ports prescaler_output_LED_clk]
set_property PACKAGE_PIN K14 [get_ports prescaler_output_clk_negato_2]

set_property IOSTANDARD LVCMOS33 [get_ports prescaler_output_clk_1]
set_property PACKAGE_PIN H16 [get_ports prescaler_output_clk_1]
set_property PACKAGE_PIN G18 [get_ports {pwm_n_out[0]}]
set_property PACKAGE_PIN F17 [get_ports {pwm_out_1[0]}]

set_property IOSTANDARD TMDS_33 [get_ports {clock_out_P[0]}]
set_property PACKAGE_PIN K17 [get_ports {clock_out_P[0]}]
set_property PACKAGE_PIN K18 [get_ports {clock_out_N[0]}]

set_property PACKAGE_PIN L14 [get_ports {IDS_P[0]}]
set_property IOSTANDARD MINI_LVDS_25 [get_ports {IDS_P[0]}]
set_property PACKAGE_PIN G14 [get_ports {IDS_led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {IDS_led[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports test_speed_out_led]
set_property PACKAGE_PIN J15 [get_ports test_speed_out_led]


set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets system_i/util_ds_buf_1/U0/IBUF_OUT_0__s_net_1]

set_property SLEW FAST [get_ports {IDS_led[0]}]

set_property IBUF_LOW_PWR FALSE [get_ports {IDS_P[0]}]
set_property IBUF_LOW_PWR FALSE [get_ports {IDS_N[0]}]

set_property OFFCHIP_TERM NONE [get_ports IDS_led[0]]
set_property OFFCHIP_TERM NONE [get_ports clock_out_P[0]]
set_property OFFCHIP_TERM NONE [get_ports prescaler_output_LED_clk]
set_property OFFCHIP_TERM NONE [get_ports prescaler_output_clk_1]
set_property OFFCHIP_TERM NONE [get_ports prescaler_output_clk_negato_2]
set_property OFFCHIP_TERM NONE [get_ports test_speed_out_led]
