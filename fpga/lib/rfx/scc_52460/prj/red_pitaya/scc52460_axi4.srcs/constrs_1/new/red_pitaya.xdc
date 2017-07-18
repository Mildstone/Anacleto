
set_property IOSTANDARD LVCMOS33 [get_ports RST_P]
set_property IOSTANDARD LVCMOS33 [get_ports RST_N]
set_property IOSTANDARD TMDS_33 [get_ports {CNVST_P[0]}]
set_property IOSTANDARD TMDS_33 [get_ports {CNVST_N[0]}]
set_property IOSTANDARD BLVDS_25 [get_ports {SDAT_P[0]}]
set_property IOSTANDARD BLVDS_25 [get_ports {SDAT_N[0]}]
set_property IOSTANDARD BLVDS_25 [get_ports {SCLK_D_clk_p[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports store]
set_property PULLDOWN true [get_ports store]

set_property PACKAGE_PIN M14 [get_ports RST_P]
set_property PACKAGE_PIN M15 [get_ports RST_N]
set_property PACKAGE_PIN K16 [get_ports {CNVST_P[0]}]
set_property PACKAGE_PIN L16 [get_ports {SDAT_P[0]}]
set_property PACKAGE_PIN L14 [get_ports {SCLK_D_clk_p[0]}]
set_property PACKAGE_PIN G15 [get_ports store]

create_clock -period 24.000 -name {SCLK_D_clk_p[0]} -waveform {0.000 12.000} [get_ports {SCLK_D_clk_p[0]}]
set_input_delay -clock [get_clocks {SCLK_D_clk_p[0]}] -clock_fall -min -add_delay 3.000 [get_ports {SDAT_N[0]}]
set_input_delay -clock [get_clocks {SCLK_D_clk_p[0]}] -clock_fall -max -add_delay 12.000 [get_ports {SDAT_N[0]}]
set_input_delay -clock [get_clocks {SCLK_D_clk_p[0]}] -min -add_delay 3.000 [get_ports {SDAT_N[0]}]
set_input_delay -clock [get_clocks {SCLK_D_clk_p[0]}] -max -add_delay 12.000 [get_ports {SDAT_N[0]}]
set_input_delay -clock [get_clocks {SCLK_D_clk_p[0]}] -clock_fall -min -add_delay 3.000 [get_ports {SDAT_P[0]}]
set_input_delay -clock [get_clocks {SCLK_D_clk_p[0]}] -clock_fall -max -add_delay 12.000 [get_ports {SDAT_P[0]}]
set_input_delay -clock [get_clocks {SCLK_D_clk_p[0]}] -min -add_delay 3.000 [get_ports {SDAT_P[0]}]
set_input_delay -clock [get_clocks {SCLK_D_clk_p[0]}] -max -add_delay 12.000 [get_ports {SDAT_P[0]}]
set_false_path -from [get_clocks {SCLK_D_clk_p[0]}] -to [get_clocks clk_fpga_0]

set_false_path -from [get_clocks clk_fpga_0] -to [get_clocks {SCLK_D_clk_p[0]}]

