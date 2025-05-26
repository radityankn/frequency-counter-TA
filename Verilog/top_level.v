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

module top_level(input rst_ext,
            	input clk_i_ext,
				input measure_signal_i,
				output measure_signal_debug,
            	input uart_rx_ext,
            	output uart_tx_ext,

				//for debugging purposes only
				output [9:0] led_port,
				output blinker,
				output blinker_2,
				output blinker_3,
				output reg blinker_4,
				output [4:0] phase_begin_led,
				output [4:0] phase_end_led,
				//output pll_1_locked,
				//output pll_2_locked,
				output [1:0] status_led
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
		.blinker(blinker),
		.blinker_2(blinker_2),
		.phase_begin(phase_begin_led),
		.phase_end(phase_end_led)
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
	wire [3:0] ref_measurement_clk_interpolate;
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
	.c1 (ref_measurement_clk_interpolate[3]),
	.c2 (ref_measurement_clk_interpolate[2]),
	.c3 (ref_measurement_clk_interpolate[1]),
	.c4 (ref_measurement_clk_interpolate[0]),
	.locked (pll_1_locked_dummy)
	);

	pll_sample_signal sample_pll_module (
	.inclk0 (clk_i_ext),
	.c0 (ref_measure_signal_internal),
	.locked (pll_2_locked_dummy)
	);
	
	reg [31:0] counter_pll_2;
	reg [31:0] counter_pll_divider_1;
	reg [31:0] counter_pll_divider_2;
	
	always @(posedge ref_measure_signal_internal) begin
		if (counter_pll_2[31] == 1'b1) begin
			blinker_4 <= ~blinker_4;
			counter_pll_2 <= 32'd0;
		end else begin
			counter_pll_2 <= counter_pll_2 + 32'h1ad;
		end
	end
	
	always @(posedge ref_measure_signal_internal) begin
		counter_pll_divider_2 <= counter_pll_divider_2 + 32'h1ad;
	end
	assign ref_measure_signal_internal_after_divided = counter_pll_divider_2[31];

	always @(posedge ref_measurement_clk_main) begin
		counter_pll_divider_1 <= counter_pll_divider_1 + 32'h1ad;
	end
	assign ref_measurement_clk_main_after_divided = counter_pll_divider_1[31];

	
	//assign measure_signal_i = ref_measure_signal_i;
	//assign measure_signal_debug = ref_measurement_clk_1;
	assign clk_i = clk_i_ext;
	assign dat_o = (uart_dat_o | counter_dat_o | 1'd0);
	assign err_o = (uart_err_o | counter_err_o | 1'd0);
	assign rty_o = (uart_rty_o | counter_rty_o | 1'd0);

endmodule


