`timescale 1us / 100ns

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:43:37 02/20/2025
// Design Name:   frequency_counter
// Module Name:   /home/raditya/Documents/Projects/Coding/Verilog/frequency_counter/uart_interface_tb.v
// Project Name:  frequency_counter
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: uart_interface
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module freq_count_tb;

	// Inputs
	reg clk_i_ext;
    reg async_rst_i;
	reg ref_clk_coarse;
	reg ref_clk_fine;
	reg measure_signal;

	// Outputs
    wire uart_rx;
    wire uart_tx;
    wire [9:0] led_output;

	// Instantiate the Unit Under Test (UUT)
    top_level uut (
		.clk_i_ext(clk_i_ext),
        .rst_ext(async_rst_i),
        .uart_rx_ext(uart_rx),
        .uart_tx_ext(uart_tx),
		.measure_signal_i(measure_signal),
		.ref_clk_coarse(ref_clk_coarse),
		.ref_clk_fine(ref_clk_fine),
        .led_port(led_output)
	);
		
	initial begin
		$dumpfile("result_toplevel.vcd");
		$dumpvars(0, freq_count_tb);
		// Initialize Inputs
		// Wait 10 ns for global reset to finish
		async_rst_i = 0;
        clk_i_ext = 0;
		ref_clk_coarse = 0;
		ref_clk_fine = 0;
		measure_signal = 0;
        #25 async_rst_i = 1;
        //#10 async_rst_i = 1;
		#4000000 $finish;
	end
	always #5 clk_i_ext = !clk_i_ext;
	always #2 ref_clk_coarse = !ref_clk_coarse;
	always #1 ref_clk_fine = !ref_clk_fine;
	always #25 measure_signal = !measure_signal;
endmodule

