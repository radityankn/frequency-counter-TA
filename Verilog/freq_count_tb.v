`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:43:37 02/20/2025
// Design Name:   frequency_counter
// Module Name:   /home/raditya/Documents/Projects/Coding/Verilog/frequency_counter/freq_count_tb.v
// Project Name:  frequency_counter
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: frequency_counter
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
	reg [31:0] addr_i;
	reg [31:0] dat_i;
	reg we_i;
	reg [3:0] sel_i;
	reg cyc_i;
	reg stb_i;
	reg lock_i;
	reg tagn_i;
	reg signal_input;
	reg reference_clk_1;
	reg reference_clk_2;

	// Outputs
	wire [31:0] dat_o;
	wire err_o;
	wire rty_o;
	wire ack_o;
	wire tagn_o;

	// Instantiate the Unit Under Test (UUT)
	frequency_counter uut (
		.rst_i(rst_i), 
		.clk_i(clk_i), 
		.addr_i(addr_i), 
		.dat_i(dat_i), 
		.dat_o(dat_o), 
		.we_i(we_i), 
		.sel_i(sel_i), 
		.cyc_i(cyc_i), 
		.stb_i(stb_i), 
		.lock_i(lock_i), 
		.err_o(err_o), 
		.rty_o(rty_o), 
		.ack_o(ack_o), 
		.tagn_i(tagn_i), 
		.tagn_o(tagn_o), 
		.signal_input(signal_input),
		.reference_clk_1(reference_clk_1),
		.reference_clk_2(reference_clk_2)
	);
		
	initial begin
		$dumpfile("result_counter.vcd");
		$dumpvars(0, freq_count_tb);
		
		// Initialize Inputs
		rst_i = 1;
		clk_i = 0;
		addr_i = 0;
		dat_i = 0;
		we_i = 0;
		sel_i = 0;
		cyc_i = 0;
		stb_i = 0;
		lock_i = 0;
		tagn_i = 0;
		signal_input = 0;
		reference_clk_1 = 0;
		reference_clk_2 = 0;
		#100 rst_i = 0;
		#85 we_i = 1;
		stb_i = 1;
		addr_i = 32'h8;
		dat_i = 8'b00000001;
		#10 we_i = 0;
		stb_i = 0;
		addr_i = 8'b0000000;
		dat_i = 8'b00000000;
		#10 we_i = 1;
		stb_i = 1;
		addr_i = 32'h8;
		dat_i = 8'b10000000;
		#10 we_i = 0;
		stb_i = 0;
		addr_i = 32'd0;
		dat_i = 8'b00000000;
		#800 we_i = 0;
		stb_i = 1;
		addr_i = 32'd9;
		dat_i = 32'd0;
		#10 we_i = 1;
		stb_i = 1;
		addr_i = 32'h8;
		dat_i = 8'b00000001;
		#10 we_i = 0;
		stb_i = 0;
		addr_i = 8'b0000000;
		dat_i = 8'b00000000;
		#10 we_i = 1;
		stb_i = 1;
		addr_i = 32'h8;
		dat_i = 8'b10000000;
		#10 we_i = 0;
		stb_i = 0;
		addr_i = 32'd0;
		dat_i = 8'b00000000;
		#850 we_i = 0;
		stb_i = 1;
		addr_i = 32'd9;
		dat_i = 32'd0;
		#30 $finish;
		// Wait 100 ns for global reset to finish
	end
	always #5 clk_i = !clk_i;
	always #40 signal_input = !signal_input;
	always #2 reference_clk_1 = !reference_clk_1;
endmodule

