set_time_format -unit ns -decimal_places 3

create_clock -name clk_i -period 20.000 -waveform {0.000 10.000} [get_ports clk_i_ext]
derive_pll_clocks -create_base_clocks -use_net_name
derive_clock_uncertainty 

#create_generated_clock -add -duty_cycle 50.000 -source [get_ports clk_i_ext] [get_ports ref_measurement_clk_interpolate]

create_clock -add -name measure_signal_i -period 100.000 [get_ports measure_signal_i]

#create_clock -add -name ref_measurement_clk_main -period 10.000 -waveform {0.000 5.000} [get_ports {ref_measurement_clk_main}] 

#create_clock -add -name ref_measurement_clk_main -period 2.500 -waveform {0.000 1.250} [get_ports {ref_measurement_clk_interpolate}]