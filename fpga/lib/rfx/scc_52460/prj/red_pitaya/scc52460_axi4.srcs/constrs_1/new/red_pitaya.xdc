
set_property IOSTANDARD LVCMOS33 [get_ports RST_P]
set_property IOSTANDARD LVCMOS33 [get_ports RST_N]
set_property IOSTANDARD TMDS_33 [get_ports {CNVST_P[0]}]
set_property IOSTANDARD TMDS_33 [get_ports {CNVST_N[0]}]
set_property IOSTANDARD BLVDS_25 [get_ports {SDAT_P[0]}]
set_property IOSTANDARD BLVDS_25 [get_ports {SDAT_N[0]}]

# STORE LED
set_property IOSTANDARD LVCMOS33 [get_ports store]
set_property PULLDOWN true       [get_ports store]

# RESET
set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_property PULLDOWN true       [get_ports reset]

# TRIG
set_property IOSTANDARD LVCMOS33 [get_ports trig]
set_property PULLDOWN true       [get_ports trig]

set_property PACKAGE_PIN M14 [get_ports RST_P]
set_property PACKAGE_PIN M15 [get_ports RST_N]
set_property PACKAGE_PIN K16 [get_ports {CNVST_P[0]}]
set_property PACKAGE_PIN J16 [get_ports {CNVST_N[0]}]
set_property PACKAGE_PIN L17 [get_ports {SDAT_N[0]}]
set_property PACKAGE_PIN L16 [get_ports {SDAT_P[0]}]
set_property PACKAGE_PIN G15 [get_ports store]
set_property PACKAGE_PIN K17 [get_ports reset]
set_property PACKAGE_PIN K18 [get_ports trig]


set_property IOSTANDARD BLVDS_25 [get_ports {SCLK_P[0]}]
set_property PACKAGE_PIN J18 [get_ports {SCLK_P[0]}]

create_clock -period 24.000 -name {SCLK_P[0]} -waveform {0.000 12.000} [get_ports {SCLK_P[0]}]
set_input_delay -clock [get_clocks {SCLK_P[0]}] -clock_fall -min -add_delay 3.000 [get_ports {SDAT_N[0]}]
set_input_delay -clock [get_clocks {SCLK_P[0]}] -clock_fall -max -add_delay 6.000 [get_ports {SDAT_N[0]}]
set_input_delay -clock [get_clocks {SCLK_P[0]}] -min -add_delay 3.000 [get_ports {SDAT_N[0]}]
set_input_delay -clock [get_clocks {SCLK_P[0]}] -max -add_delay 6.000 [get_ports {SDAT_N[0]}]
set_input_delay -clock [get_clocks {SCLK_P[0]}] -clock_fall -min -add_delay 3.000 [get_ports {SDAT_P[0]}]
set_input_delay -clock [get_clocks {SCLK_P[0]}] -clock_fall -max -add_delay 6.000 [get_ports {SDAT_P[0]}]
set_input_delay -clock [get_clocks {SCLK_P[0]}] -min -add_delay 3.000 [get_ports {SDAT_P[0]}]
set_input_delay -clock [get_clocks {SCLK_P[0]}] -max -add_delay 6.000 [get_ports {SDAT_P[0]}]
set_false_path -from [get_clocks clk_fpga_0] -to [get_clocks {SCLK_P[0]}]
set_false_path -from [get_clocks {SCLK_P[0]}] -to [get_clocks clk_fpga_0]
