

############################################################################
# IO constraints                                                           #
############################################################################


set_property IOSTANDARD BLVDS_25 [get_ports {CNVST_in_P[0]}]
set_property IOSTANDARD BLVDS_25 [get_ports {CNVST_in_N[0]}]
set_property IOSTANDARD BLVDS_25 [get_ports {SCLK_in_P[0]}]
set_property IOSTANDARD BLVDS_25 [get_ports {SDAT_in_P[0]}]
set_property PACKAGE_PIN M14 [get_ports {CNVST_in_P[0]}]
set_property PACKAGE_PIN G17 [get_ports {SCLK_in_P[0]}]
set_property PACKAGE_PIN H16 [get_ports {SDAT_in_P[0]}]
set_property PACKAGE_PIN L16 [get_ports {CNVST_out_P[0]}]
set_property IOSTANDARD TMDS_33 [get_ports {CNVST_out_P[0]}]
set_property PACKAGE_PIN J18 [get_ports {SCLK_out_P[0]}]
set_property IOSTANDARD TMDS_33 [get_ports {SCLK_out_P[0]}]
set_property PACKAGE_PIN K17 [get_ports {SDAT_out_P[0]}]
set_property IOSTANDARD TMDS_33 [get_ports {SDAT_out_P[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {CNVST_led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports prescaler_output_clk]
set_property IOSTANDARD LVCMOS33 [get_ports {SCLK_led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SDAT_led[0]}]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets AD7641_i/SCLK_in_buf/U0/IBUF_OUT_0__s_net_1]

set_property PACKAGE_PIN F16 [get_ports prescaler_output_clk]
set_property PACKAGE_PIN F17 [get_ports {CNVST_led[0]}]
set_property PACKAGE_PIN G15 [get_ports {SCLK_led[0]}]
set_property PACKAGE_PIN H15 [get_ports {SDAT_led[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports error_state_led]
set_property PACKAGE_PIN J14 [get_ports error_state_led]

create_clock -period 10.000 -name {SCLK_in_P[0]} -waveform {0.000 5.000} [get_ports {SCLK_in_P[0]}]
create_generated_clock -name AD7641_i/prescaler_clock_0/U0/prescaler_inst/prescaler_output_clk -source [get_pins {AD7641_i/processing_system7_0/inst/PS7_i/FCLKCLK[0]}] -divide_by 5 [get_pins AD7641_i/prescaler_clock_0/U0/prescaler_inst/prescaler_output_reg/Q]
set_false_path -from [get_clocks {SCLK_in_P[0]}] -to [get_clocks clk_fpga_0]

set_property OFFCHIP_TERM NONE [get_ports CNVST_out_P[0]]
set_property OFFCHIP_TERM NONE [get_ports SCLK_out_P[0]]
set_property OFFCHIP_TERM NONE [get_ports SDAT_out_P[0]]
set_property IOSTANDARD LVCMOS33 [get_ports CNVST_out_led]
set_property PACKAGE_PIN J15 [get_ports CNVST_out_led]
