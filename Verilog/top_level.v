`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:56:56 02/20/2025 
// Design Name: 
// Module Name:    top_level 
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

module top_level(input rst_ext_unbuffered,
            	input clk_i_ext,
				input measure_signal_i,
            	//input uart_rx_ext,
            	output uart_tx_ext,

				//for debugging purposes only
				output [9:0] led_port,
				output blinker,
				output blinker_2,
				output blinker_3,
				//output reg blinker_4,
				output [1:0] status_led
				//output [4:0] phase_shift_pin
);

   // WB interconnect definition
   	wire rst_ext;
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
		.blinker(blinker),
		.blinker_2(blinker_2),
		.register_window(led_port)
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
	wire ref_measurement_clk_interpolate;
	wire ref_measurement_clk_main;
	wire ref_measure_signal_internal;
	wire ref_measurement_clk_main_after_divided;
	wire ref_measure_signal_internal_after_divided;

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
	 //.signal_input(ref_measure_signal_internal),
    .signal_input(measure_signal_i),                     //target signal input port
    .reference_clk_interpolate(ref_measurement_clk_interpolate),                  //coarse reference clock
	.reference_clk_main(ref_measurement_clk_main),
	.blinker_3(blinker_3),
	//.register_window(led_port),
	.status(status_led)
	);

	pll_module ref_pll_module (
	.inclk0 (clk_i_ext),
	.c0 (ref_measurement_clk_main),
	.locked (pll_1_locked_dummy)
	);
	
	pll_interpolate ref_pll_interpolate (
	.inclk0 (clk_i_ext),
	.c0 (ref_measurement_clk_interpolate),
	.locked (pll_2_locked_dummy)
	);
	
	reg [2:0] rst_ext_buffered;

	always @(posedge clk_i_ext) begin
		rst_ext_buffered[0] <= rst_ext_unbuffered;
		rst_ext_buffered[1] <= rst_ext_buffered[0];
		rst_ext_buffered[2] <= rst_ext_buffered[1];
	end
	
	assign rst_ext = rst_ext_buffered[2];
	assign clk_i = clk_i_ext;
	assign dat_o = (uart_dat_o | counter_dat_o | 1'd0);
	assign err_o = (uart_err_o | counter_err_o | 1'd0);
	assign rty_o = (uart_rty_o | counter_rty_o | 1'd0);

endmodule


