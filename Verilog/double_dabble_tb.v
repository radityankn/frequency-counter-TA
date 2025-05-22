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
	reg clk_i;
	reg [31:0] input_number;
	reg conversion_start;

	// Outputs
	wire [7:0] ones;
    wire [7:0] tens;
    wire [7:0] hundreds;
    wire [7:0] thousands;
    wire [7:0] ten_thousands;
    wire [7:0] hundred_thousands;
    wire [7:0] millions;
    wire [7:0] tenth_million;
    wire [7:0] hundred_millions;
    wire [7:0] billions;
	wire conversion_complete;

	// Instantiate the Unit Under Test (UUT)
    double_dabble my_module (  
        .input_number(input_number),
        .clk_i(clk_i),
        .conversion_start(conversion_start),
        .conversion_complete(conversion_complete),
        .ones(ones),
        .tens(tens),
        .hundreds(hundreds),
        .thousands(thousands),
        .ten_thousands(ten_thousands),
        .hundred_thousands(hundred_thousands),
        .millions(millions),
        .tenth_million(tenth_million),
        .hundred_millions(hundred_millions),
        .billions(billions)
        );
		
	initial begin
		$dumpfile("result_double_dabble.vcd");
		$dumpvars(0, freq_count_tb);
		// Initialize Inputs
		// Wait 10 ns for global reset to finish
		input_number = 32'h61626364;
        conversion_start = 1'b0;
        clk_i = 1'b0;
		//send to baud rate divider constant (0x04)
		#10 conversion_start = 1'b1;
        #2000 conversion_start = 1'b0;
        #100 $finish;
	end
	always #5 clk_i = !clk_i;

endmodule

