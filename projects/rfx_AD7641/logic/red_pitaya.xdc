

############################################################################
# IO constraints                                                           #
############################################################################


set_property IOSTANDARD LVCMOS33 [get_ports prescaler_output_clk]
set_property PACKAGE_PIN F16 [get_ports prescaler_output_clk]
set_property PACKAGE_PIN F17 [get_ports SCLK_out]
set_property IOSTANDARD LVCMOS33 [get_ports SCLK_out]
set_property PACKAGE_PIN G15 [get_ports SDAT_out]
set_property IOSTANDARD LVCMOS33 [get_ports SDAT_out]
set_property IOSTANDARD LVCMOS33 [get_ports CNVST_out]
set_property PACKAGE_PIN H15 [get_ports CNVST_out]
