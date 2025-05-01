`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:45:47 02/20/2025 
// Design Name: 
// Module Name:    ALU 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ALU(
    input rst_i,
    input clk_i,
    input [7:0] addr_i,
    input [7:0] dat_i,
    output [7:0] dat_o,
    input we_i,
    input [7:0] sel_i,
    inout cyc_i,
    input stb_i,
    input lock_i,
    output err_o,
    output rty_o,
    output ack_o,
    input tagn_i,
    output tagn_o
    );

    reg operand_a;
    

endmodule
