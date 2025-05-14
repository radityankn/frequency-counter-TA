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
module control_unit(
    input ext_rst_i,
    input rst_i,
    input clk_i,
    output [31:0] addr_o,
    output [31:0] dat_o,
    input [31:0] dat_i,
    output we_o,
    output [3:0] sel_o,
    output cyc_o,
    output stb_o,
    output lock_o,
    input err_i,
    input rty_i,
    input ack_i,
    input tagn_i,
    output tagn_o,
    output [9:0] out_led,
    output [5:0] status_led,
    output blinker
    );

    reg [4:0] cu_fsm_internal;
    reg [4:0] next_fsm_step;
    reg [31:0] addr_o_internal;
    reg [31:0] dat_o_internal;
    reg [3:0] sel_o_internal;
    reg [31:0] counter_timer_internal;
    reg stb_o_internal;
    reg we_o_internal;
    reg [9:0] one_hot;
	reg [7:0] repetition;
    reg [31:0] sampled_data;
    reg blinker_reg;

    always @(posedge clk_i) begin
        if (rst_i == 1'b1 || ext_rst_i == 1'b0) begin
            cu_fsm_internal <= 5'd0;
            next_fsm_step <= 5'd0;
            addr_o_internal <= 32'd0;
            dat_o_internal <= 32'd0;
            counter_timer_internal <= 32'd0;
            stb_o_internal <= 0;
            we_o_internal <= 0;
            one_hot <= 10'd0;
			repetition <= 0;
            sampled_data <= 32'd0;
            sel_o_internal <= 4'b0000;
            blinker_reg <= 0;
        end else begin
            case (cu_fsm_internal)
                //fill the baud rate register
                5'd0 : begin
					we_o_internal <= 1;
					stb_o_internal <= 1;
					addr_o_internal <= 32'h4;
					dat_o_internal <= 32'h96feb5;
                    sel_o_internal <= 4'b1111;
                    one_hot <= 6'b000001;
					cu_fsm_internal <= 5'd2;//cu_fsm_internal + 1'b1;
				end
                //counter reset
                5'd1 : begin
					we_o_internal <= 1;
                    stb_o_internal <= 1;
                    addr_o_internal <= 32'h8;
                    dat_o_internal <= 32'd1;
                    sel_o_internal <= 4'b0001;
                    one_hot <= 6'b000010;
                    if (repetition == 8'b00001111) begin 
                        cu_fsm_internal <= cu_fsm_internal + 1'b1;
                        repetition <= 0;
                    end
                    else begin 
                        repetition <= repetition + 1'b1;
                        cu_fsm_internal <= cu_fsm_internal;
                    end
				end
                //counter start measurement
                5'd2 : begin
                    we_o_internal <= 1;
                    stb_o_internal <= 1;
                    addr_o_internal <= 32'h8;
                    dat_o_internal <= 32'h80;
                    sel_o_internal <= 4'b0001;
                    cu_fsm_internal <= cu_fsm_internal + 1'b1;
                    one_hot <= 6'b000100;
                end
                //poll until finish measuring
                5'd3 : begin
					we_o_internal <= 0;
					stb_o_internal <= 1;
					addr_o_internal <= 32'h8;
					dat_o_internal <= 32'h0;
                    sel_o_internal <= 4'b0001;
                    one_hot <= 6'b001000;
                    if (dat_i[6] == 1) cu_fsm_internal <= cu_fsm_internal + 1'b1;
                    else if (dat_i[6] == 0) cu_fsm_internal <= cu_fsm_internal;
                end
                //save the measurement result
                5'd4 : begin
                    we_o_internal <= 0;
                    stb_o_internal <= 1;
                    addr_o_internal <= 32'h9;
                    dat_o_internal <= 32'h0;
                    sel_o_internal <= 4'b0000;
                    one_hot <= 6'b010000;
                    if (repetition == 8'b00000011) begin
                        sampled_data <= dat_i;
                        cu_fsm_internal <= cu_fsm_internal + 1'b1;
                        repetition <= 0;
                    end
                    else begin
                        sampled_data <= dat_i;
                        cu_fsm_internal <= cu_fsm_internal;
                        repetition <= repetition + 1'b1;
                    end
                end
                //fill the TX buffer : part 1
                5'd5 : begin
					we_o_internal <= 1;
                    stb_o_internal <= 1;
                    addr_o_internal <= 32'h7;
                    dat_o_internal <= sampled_data;
                    sel_o_internal <= 4'b0001;
                    cu_fsm_internal <= 5'd9;
                    next_fsm_step <= 5'd6;
                end
                //fill the TX buffer : part 2
                5'd6 : begin
					we_o_internal <= 1;
                    stb_o_internal <= 1;
                    addr_o_internal <= 32'h7;
                    dat_o_internal <= sampled_data;
                    sel_o_internal <= 4'b0010;
                    cu_fsm_internal <= 5'd9;
                    next_fsm_step <= 5'd7;
                end
                //fill TX buffer : part 3
                5'd7 : begin
					we_o_internal <= 1;
                    stb_o_internal <= 1;
                    addr_o_internal <= 32'h7;
                    dat_o_internal <= sampled_data;
                    sel_o_internal <= 4'b0100;
                    cu_fsm_internal <= 5'd9;
                    next_fsm_step <= 5'd8;
                end
                //fill TX buffer : part 4
                5'd8 : begin
					we_o_internal <= 1;
                    stb_o_internal <= 1;
                    addr_o_internal <= 32'h7;
                    dat_o_internal <= sampled_data;
                    sel_o_internal <= 4'b1000;
                    cu_fsm_internal <= 5'd9;
                    next_fsm_step <= 5'd14;
                end
                //start UART TX sending
                5'd9 : begin
					we_o_internal <= 1;
                    stb_o_internal <= 1;
                    addr_o_internal <= 32'h3;
                    dat_o_internal <= 32'h80;
                    cu_fsm_internal <= cu_fsm_internal + 1'b1;
                end
                //poll TX frame send complete
                5'd10 : begin
					we_o_internal <= 0;
                    stb_o_internal <= 1;
                    addr_o_internal <= 32'h5;
                    dat_o_internal <= 32'd0;
                    if (dat_i[5] == 1) cu_fsm_internal <= cu_fsm_internal + 1'b1;
                    else cu_fsm_internal <= cu_fsm_internal;
                end
                //clear UART flag
                5'd11 : begin
					we_o_internal <= 1;
                    stb_o_internal <= 1;
                    addr_o_internal <= 32'h5;
                    dat_o_internal <= 32'd0;
                    cu_fsm_internal <= next_fsm_step;
                end
                //delay for 1 second
                5'd14 : begin
					one_hot <= 6'b100000;
                    if (counter_timer_internal[31] == 1'b1) begin 
                        cu_fsm_internal <= 5'd2;
                        counter_timer_internal <= 0;
								we_o_internal <= 0;
                        sel_o_internal <= 0;
								stb_o_internal <= 0;
								addr_o_internal <= 32'h0;
								dat_o_internal <= 32'h0;
                        blinker_reg <= ~blinker_reg;
                    end else begin 
                        counter_timer_internal <= counter_timer_internal + 32'h14f8b;
                        cu_fsm_internal <= cu_fsm_internal;
                        we_o_internal <= 0;
                        sel_o_internal <= 0;
								stb_o_internal <= 0;
								addr_o_internal <= 32'h0;
								dat_o_internal <= 32'h0;
                    end
                end
            endcase
        end
    end

    assign addr_o = addr_o_internal;
    assign dat_o = dat_o_internal;
    assign stb_o = stb_o_internal;
    assign we_o = we_o_internal;
    assign sel_o = sel_o_internal;
    assign out_led = sampled_data[9:0];
    assign status_led = one_hot;
    assign blinker = blinker_reg;
endmodule
