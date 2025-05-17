`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:56:56 02/20/2025 
// Design Name: 
// Module Name:    control_unit 
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

module top_level(input rst_ext,
            	input clk_i_ext,
				input measure_signal_i,
				output measure_signal_debug,
            	input uart_rx_ext,
            	output uart_tx_ext,
            	output [9:0] led_port,
				output [5:0] status_led,
				output [3:0] counter_status_led,
				output [1:0] counter_flags_led,
				output blinker
);

   // WB interconnect definition
	wire rst_i;
	wire clk_i;
	wire tagn_i;
	wire [31:0] dat_o;
	wire [31:0] addr_i;
	wire [31:0] dat_i;
	wire we_i;
	wire [3:0] sel_i;
	wire cyc_i;
	wire stb_i;
	wire lock_i;
	wire err_o;
	wire rty_o;
	wire ack_o;
	wire tagn_o;

    control_unit control_module (
    	.ext_rst_i(rst_ext),
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
		.tagn_o(tagn_o),
    	.out_led(led_port),
		.status_led(status_led),
		.blinker(blinker)
    );
	
	wire [31:0] uart_dat_o;
	wire uart_ack_o;
	wire uart_rty_o;
	wire uart_err_o;

    uart_interface uart_module (
        .ext_rst_i(rst_ext),
		.rst_i(rst_i), 
		.clk_i(clk_i), 
		.addr_i(addr_i), 
		.dat_i(dat_i), 
		.dat_o(uart_dat_o), 
		.we_i(we_i), 
		.sel_i(sel_i), 
		.cyc_i(cyc_i), 
		.stb_i(stb_i), 
		.lock_i(lock_i), 
		.err_o(uart_err_o), 
		.rty_o(uart_rty_o), 
		.ack_o(uart_ack_o), 
		.tagn_i(tagn_i), 
		.tagn_o(tagn_o), 
		.uart_rx(uart_rx_ext),
		.uart_tx(uart_tx_ext)
	);

	wire [31:0] counter_dat_o;
	wire counter_ack_o;
	wire counter_rty_o;
	wire counter_err_o;
	wire ref_clk_coarse;
	wire ref_clk_fine;
	wire measure_signal_internal;

	frequency_counter counter_module(
	.ext_rst_i(rst_ext),
    .rst_i(rst_i),
    .clk_i(clk_i),
    .addr_i(addr_i),
    .dat_i(dat_i),
    .dat_o(counter_dat_o),
    .we_i(we_i),
    .sel_i(sel_i),
    .cyc_i(cyc_i),
    .stb_i(stb_i),
    .lock_i(lock_i),
    .err_o(counter_err_o),
    .rty_o(counter_rty_o),
    .ack_o(counter_ack_o),
    .tagn_i(tagn_i),
    .tagn_o(tagn_o),
    .signal_input(measure_signal_i),                     //target signal input port
    .reference_clk_1(ref_clk_coarse),                  //coarse reference clock
    .reference_clk_2(ref_clk_fine),                   //fine reference clock, must be slightly different than the coarse reference clock
    .counter_fsm_status(counter_status_led),
	 .counter_flags(counter_flags_led),
	 .counter_control_reg_out(led_port_dummy)
	);

	alu_module 

	pll_module	pll_module_inst (
	.areset (~rst_ext),
	.inclk0 (clk_i_ext),
	.c0 (ref_clk_coarse),
	.c1 (ref_clk_fine),
	.c2 (measure_signal_internal),
	.locked ( locked_sig )
	);
	
	assign measure_signal_debug = measure_signal_internal;
	assign clk_i = clk_i_ext;
	assign dat_o = (uart_dat_o | counter_dat_o | 1'd0);
	assign err_o = (uart_err_o | counter_err_o | 1'd0);
	assign rty_o = (uart_rty_o | counter_rty_o | 1'd0);

endmodule
