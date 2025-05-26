set_time_format -unit ns -decimal_places 3

create_clock -name clk_i -period 20.000 -waveform {0.000 10.000} [get_ports clk_i_ext]
derive_pll_clocks -create_base_clocks
derive_clock_uncertainty

create_clock -add -name measure_signal_i -period 100.000 [get_ports {ref_measure_signal_internal}]
create_clock -add -name ref_measurement_clk_main -period 10.000 -waveform {0.000 5.000} [get_ports {ref_measurement_clk_main}] 
create_clock -add -name ref_measurement_clk_main -period 10.000 -waveform {0.000 5.000} [get_ports {ref_measurement_clk_interpolate[3]}]
create_clock -add -name ref_measurement_clk_main -period 10.000 -waveform {0.000 5.000} [get_ports {ref_measurement_clk_interpolate[2]}]
create_clock -add -name ref_measurement_clk_main -period 10.000 -waveform {0.000 5.000} [get_ports {ref_measurement_clk_interpolate[1]}]
create_clock -add -name ref_measurement_clk_main -period 10.000 -waveform {0.000 5.000} [get_ports {ref_measurement_clk_interpolate[0]}]