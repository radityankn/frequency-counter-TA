`timescale 1ns / 1ps

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
	reg rst_i;
	reg clk_i;
	reg tagn_i;
    reg [31:0] dat_o;

	// Outputs
    wire [31:0] addr_i;
	wire [31:0] dat_i;
	wire we_i;
	wire [7:0] sel_i;
	wire cyc_i;
	wire stb_i;
	wire lock_i;
	wire err_o;
	wire rty_o;
	wire ack_o;
	wire tagn_o;

	// Instantiate the Unit Under Test (UUT)
    control_unit uut (
		.rst_i(rst_i), 
		.clk_i(clk_i), 
		.addr_o(addr_i), 
		.dat_o(dat_i), 
		.dat_i(dat_o), 
		.we_o(we_i), 
		.sel_o(sel_i), 
		.cyc_o(cyc_i), 
		.stb_o(stb_i), 
		.lock_o(lock_i), 
		.err_i(err_o), 
		.rty_i(rty_o), 
		.ack_i(ack_o), 
		.tagn_i(tagn_i), 
		.tagn_o(tagn_o)
	);
		
	initial begin
		$dumpfile("result_cu.vcd");
		$dumpvars(0, freq_count_tb);
		// Initialize Inputs
		// Wait 10 ns for global reset to finish
		rst_i = 1;
		clk_i = 0;
		dat_o = 0; 
		#10 rst_i = 0;
		//send to addr_o
		#105 dat_o[5] = 1;
        #500 $finish;
	end
	always #5 clk_i = !clk_i;
endmodule

