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
	reg [31:0] addr_i;
	reg [31:0] dat_i;
	reg we_i;
	reg [7:0] sel_i;
	reg cyc_i;
	reg stb_i;
	reg lock_i;
	reg tagn_i;
	reg uart_rx;

	// Outputs
	wire [31:0] dat_o;
	wire err_o;
	wire rty_o;
	wire ack_o;
	wire tagn_o;
    wire uart_tx;

	// Instantiate the Unit Under Test (UUT)
    uart_interface uut (
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
		.uart_rx(uart_rx),
		.uart_tx(uart_tx)
	);
		
	initial begin
		$dumpfile("result.vcd");
		$dumpvars(0, freq_count_tb);
		
		// Initialize Inputs
		// Wait 10 ns for global reset to finish
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
        uart_rx = 1; 
		#10 rst_i = 0;
		//send to baud rate divider constant H(0x04)
		#85 we_i = 1;
		stb_i = 1;
		addr_i = 32'h4;
		dat_i = 32'd32766;
		#5 stb_i = 0;
		//send to RX Control Register (0x02)
		#5 stb_i = 1;
		we_i = 1;
		addr_i = 32'h2;
		dat_i = 32'hc0;
		#5 stb_i = 0;
		#10 we_i = 0;
		addr_i = 32'h0;
		dat_i = 32'h0;
		//start bit
		#5 uart_rx = 0;
		//first data bit of the frame
		#20 uart_rx = 1;
		#20 uart_rx = 0;
		#20 uart_rx = 0;
		#20 uart_rx = 1;
		#20 uart_rx = 1;
		#20 uart_rx = 1;
		#20 uart_rx = 0;
		#20 uart_rx = 0;
		//parity
		#20 uart_rx = 1;
		//2 stop bit 
		#20 uart_rx = 1;
		#20 uart_rx = 1;
		//send to RX Control Register (0x02)
		#10 stb_i = 1;
		we_i = 1;
		addr_i = 32'h2;
		dat_i = 32'hc0;
		#5 stb_i = 0;
		#10 we_i = 0;
		addr_i = 32'h0;
		dat_i = 32'h0;
		//start bit
		#5 uart_rx = 0;
		//first data bit of the frame
		#20 uart_rx = 1;
		#20 uart_rx = 1;
		#20 uart_rx = 0;
		#20 uart_rx = 1;
		#20 uart_rx = 1;
		#20 uart_rx = 1;
		#20 uart_rx = 0;
		#20 uart_rx = 1;
		//parity
		#20 uart_rx = 1;
		//2 stop bit 
		#20 uart_rx = 1;
		#20 uart_rx = 1;
		//testing reset function
		#40 stb_i = 1;
		we_i = 1;
		addr_i = 32'h2;
		dat_i = 8'b01001000;
		#5 stb_i = 0;
		#5 we_i = 0;
		addr_i = 8'b00000000;
		dat_i = 8'b00000000;
		#500 $finish;
	end
	always #5 clk_i = !clk_i;
endmodule

