`timescale 10ns / 1ns

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

	// Outputs
    wire uart_rx;
    wire uart_tx;
    wire [9:0] led_output;

	// Instantiate the Unit Under Test (UUT)
    top_level uut (
		.clk_i_ext(clk_i_ext),
        .async_rst_ext(async_rst_i),
        .uart_rx_ext(uart_rx),
        .uart_tx_ext(uart_tx),
        .led_port(led_output)
	);
		
	initial begin
		$dumpfile("result_cu.vcd");
		$dumpvars(0, freq_count_tb);
		// Initialize Inputs
		// Wait 10 ns for global reset to finish
		async_rst_i = 1;
        clk_i_ext = 0;
        #1 async_rst_i = 0;
        #10 async_rst_i = 1;
        #2000000 $finish;
	end
	always #5 clk_i_ext = !clk_i_ext;
endmodule

