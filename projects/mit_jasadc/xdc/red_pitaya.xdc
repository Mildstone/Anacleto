



### LED PINS
# set_property PACKAGE_PIN F16 [get_ports led_o]
# set_property PACKAGE_PIN F17 [get_ports {pwm_out_1[0]}]
# set_property PACKAGE_PIN G15 [get_ports {pwm_n_out_1[0]}]
# set_property PACKAGE_PIN H15     [get_ports {led_o[3]}]
# set_property PACKAGE_PIN K14     [get_ports {led_o[4]}]
# set_property PACKAGE_PIN G14     [get_ports {led_o[5]}]
# set_property PACKAGE_PIN J15     [get_ports {led_o[6]}]
# set_property PACKAGE_PIN J14     [get_ports {led_o[7]}]


#  // XADC from red pitaya map
#  .Vaux0_v_n (vinn_i[1]),  .Vaux0_v_p (vinp_i[1]),
#  .Vaux1_v_n (vinn_i[2]),  .Vaux1_v_p (vinp_i[2]),
#  .Vaux8_v_n (vinn_i[0]),  .Vaux8_v_p (vinp_i[0]),
#  .Vaux9_v_n (vinn_i[3]),  .Vaux9_v_p (vinp_i[3]),
#  .Vp_Vn_v_n (vinn_i[4]),  .Vp_Vn_v_p (vinp_i[4]),

### XADC
set_property IOSTANDARD LVCMOS33 [get_ports {Vaux0_v_p}]
set_property IOSTANDARD LVCMOS33 [get_ports {Vaux0_v_n}]
set_property IOSTANDARD LVCMOS33 [get_ports {Vaux1_v_p}]
set_property IOSTANDARD LVCMOS33 [get_ports {Vaux1_v_n}]
set_property IOSTANDARD LVCMOS33 [get_ports {Vaux8_v_p}]
set_property IOSTANDARD LVCMOS33 [get_ports {Vaux8_v_n}]
set_property IOSTANDARD LVCMOS33 [get_ports {Vaux9_v_p}]
set_property IOSTANDARD LVCMOS33 [get_ports {Vaux9_v_n}]

#AD0
set_property PACKAGE_PIN C20 [get_ports {Vaux0_v_p}]
set_property PACKAGE_PIN B20 [get_ports {Vaux0_v_n}]
#AD1
set_property PACKAGE_PIN E17 [get_ports {Vaux1_v_p}]
set_property PACKAGE_PIN D18 [get_ports {Vaux1_v_n}]
#AD8
set_property PACKAGE_PIN B19 [get_ports {Vaux8_v_p}]
set_property PACKAGE_PIN A20 [get_ports {Vaux8_v_n}]
#AD9
set_property PACKAGE_PIN E18 [get_ports {Vaux9_v_p}]
set_property PACKAGE_PIN E19 [get_ports {Vaux9_v_n}]





