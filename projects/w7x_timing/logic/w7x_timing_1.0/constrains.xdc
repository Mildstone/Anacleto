create_clock -period 100 -name clk_in       -waveform {0 50} [get_ports clk_in]
create_clock -period   8 -name s00_axi_aclk -waveform {0  4} [get_ports s00_axi_aclk]
set_clock_groups -name async -asynchronous -group {clk_in} -group {s00_axi_aclk}

set_input_delay  -clock [get_clocks s00_axi_aclk] -min  2 [get_ports s00_axi_* -filter {DIRECTION==IN && NAME!~*clk}]
set_input_delay  -clock [get_clocks s00_axi_aclk] -max  4 [get_ports s00_axi_* -filter {DIRECTION==IN && NAME!~*clk}]

set_output_delay -clock [get_clocks s00_axi_aclk] -min  0 [get_ports s00_axi_* -filter {DIRECTION==OUT && NAME!~*clk}]
set_output_delay -clock [get_clocks s00_axi_aclk] -max  1 [get_ports s00_axi_* -filter {DIRECTION==OUT && NAME!~*clk}]

set_input_delay  -clock [get_clocks clk_in]       -min  2 [get_ports trig_in]
set_input_delay  -clock [get_clocks clk_in]       -max 10 [get_ports trig_in]

set_output_delay -clock [get_clocks clk_in]       -min  1 [get_ports state_out[*]]
set_output_delay -clock [get_clocks clk_in]       -max 10 [get_ports state_out[*]]
