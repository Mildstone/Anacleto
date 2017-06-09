############################################################################
# IO constraints                                                           #
############################################################################


set_property IOSTANDARD BLVDS_25 [get_ports {SCLK_in_P[0]}]
set_property IOSTANDARD BLVDS_25 [get_ports {SDAT_in_P[0]}]
set_property IOSTANDARD TMDS_33 [get_ports {CNVST_out_P[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {CNVST_led[0]}]

set_property PACKAGE_PIN K17 [get_ports {SCLK_in_P[0]}]
set_property PACKAGE_PIN L16 [get_ports {SDAT_in_P[0]}]
set_property PACKAGE_PIN K16 [get_ports {CNVST_out_P[0]}]
set_property PACKAGE_PIN F17 [get_ports {CNVST_led[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports error_state_led]
set_property PACKAGE_PIN G15 [get_ports error_state_led]
set_property PULLDOWN true [get_ports error_state_led]

set_property IOSTANDARD LVCMOS33 [get_ports {RST_out_P[0]}]
set_property PACKAGE_PIN M14 [get_ports {RST_out_P[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {RST_out_N[0]}]
set_property PACKAGE_PIN M15 [get_ports {RST_out_N[0]}]


create_clock -period 24.000 -name {SCLK_in_P[0]} -waveform {0.000 12.000} [get_ports {SCLK_in_P[0]}]

set_false_path -from [get_clocks {SCLK_in_P[0]}] -to [get_clocks clk_fpga_0]
set_input_delay -clock [get_clocks {SCLK_in_P[0]}] -clock_fall -min -add_delay 3.000 [get_ports {SDAT_in_N[0]}]
set_input_delay -clock [get_clocks {SCLK_in_P[0]}] -clock_fall -max -add_delay 12.000 [get_ports {SDAT_in_N[0]}]
set_input_delay -clock [get_clocks {SCLK_in_P[0]}] -min -add_delay 3.000 [get_ports {SDAT_in_N[0]}]
set_input_delay -clock [get_clocks {SCLK_in_P[0]}] -max -add_delay 12.000 [get_ports {SDAT_in_N[0]}]
set_input_delay -clock [get_clocks {SCLK_in_P[0]}] -clock_fall -min -add_delay 3.000 [get_ports {SDAT_in_P[0]}]
set_input_delay -clock [get_clocks {SCLK_in_P[0]}] -clock_fall -max -add_delay 12.000 [get_ports {SDAT_in_P[0]}]
set_input_delay -clock [get_clocks {SCLK_in_P[0]}] -min -add_delay 3.000 [get_ports {SDAT_in_P[0]}]
set_input_delay -clock [get_clocks {SCLK_in_P[0]}] -max -add_delay 12.000 [get_ports {SDAT_in_P[0]}]
# set_property LOC ILOGIC_X0Y74 [get_cells {AD7641_i/rfx_AD7641_serial_slave_0/U0/AD7641_serial_slave_inst/data_0_reg[0]data_1_reg[0]}]

set_false_path -from [get_clocks clk_fpga_0] -to [get_clocks {SCLK_in_P[0]}]
