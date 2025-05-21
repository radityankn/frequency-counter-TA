create_clock -add -name clk_i -period 20ns [get_ports clk_i_ext]
create_clock -add -name measure_clk_ref_1 -period 10ns [get_ports ref_measurement_clk_1]
create_clock -add -name measure_clk_ref_2 -period 10ns [get_ports ref_measurement_clk_2]
create_clock -add -name measure_clk_ref_3 -period 10ns [get_ports ref_measurement_clk_3]
create_clock -add -name measure_clk_ref_4 -period 10ns [get_ports ref_measurement_clk_4]
create_clock -add -name measure_clk_ref_5 -period 10ns [get_ports ref_measurement_clk_5]
create_clock -add -name measure_signal_i -period 20ns [get_ports measure_signal_i]

 