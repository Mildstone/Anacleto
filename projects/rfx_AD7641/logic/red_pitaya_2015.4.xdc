

############################################################################
# IO constraints                                                           #
############################################################################

### LED
set_property IOSTANDARD LVCMOS33 [get_ports {led_o}]
set_property SLEW       SLOW     [get_ports {led_o}]
set_property DRIVE      4        [get_ports {led_o}]

### PWM
set_property IOSTANDARD LVCMOS33 [get_ports {pwm_out}]
set_property SLEW       FAST     [get_ports {pwm_out}]
set_property DRIVE      4        [get_ports {pwm_out}]
set_property IOSTANDARD LVCMOS33 [get_ports {pwm_n_out}]
set_property SLEW       FAST     [get_ports {pwm_n_out}]
set_property DRIVE      4        [get_ports {pwm_n_out}]

set_property IOSTANDARD LVCMOS33 [get_ports {pwm_out_1}]
set_property SLEW       FAST     [get_ports {pwm_out_1}]
set_property DRIVE      4        [get_ports {pwm_out_1}]
set_property IOSTANDARD LVCMOS33 [get_ports {pwm_n_out_1}]
set_property SLEW       FAST     [get_ports {pwm_n_out_1}]
set_property DRIVE      4        [get_ports {pwm_n_out_1}]

### IO PINS
set_property PACKAGE_PIN G17     [get_ports {pwm_out}]
set_property PACKAGE_PIN G18     [get_ports {pwm_n_out}]


### LED PINS
set_property PACKAGE_PIN F16     [get_ports {led_o}]
set_property PACKAGE_PIN F17     [get_ports {pwm_out_1}]
set_property PACKAGE_PIN G15     [get_ports {pwm_n_out_1}]
# set_property PACKAGE_PIN H15     [get_ports {led_o[3]}]
# set_property PACKAGE_PIN K14     [get_ports {led_o[4]}]
# set_property PACKAGE_PIN G14     [get_ports {led_o[5]}]
# set_property PACKAGE_PIN J15     [get_ports {led_o[6]}]
# set_property PACKAGE_PIN J14     [get_ports {led_o[7]}]

