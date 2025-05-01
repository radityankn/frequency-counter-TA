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
    input async_rst_i,
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
    output [9:0] out_led
    );

    reg [4:0] cu_fsm_internal;
    reg [4:0] next_fsm_step;
    reg [31:0] addr_o_internal;
    reg [31:0] dat_o_internal;
    reg [31:0] counter_timer_internal;
    reg stb_o_internal;
    reg we_o_internal;
    reg [9:0] one_hot;
	reg repetition;

    always @(posedge (clk_i ^ ~async_rst_i)) begin
        if (rst_i == 1'b1) begin
            cu_fsm_internal <= 5'd0;
            next_fsm_step <= 5'd0;
            addr_o_internal <= 32'd0;
            dat_o_internal <= 32'd0;
            counter_timer_internal <= 32'd0;
            stb_o_internal <= 0;
            we_o_internal <= 0;
            one_hot <= 10'd0;
				repetition <= 0;
        end else if (async_rst_i == 1'b0) begin
            cu_fsm_internal <= 5'd0;
            next_fsm_step <= 5'd0;
            addr_o_internal <= 32'd0;
            dat_o_internal <= 32'd0;
            counter_timer_internal <= 32'd0;
            stb_o_internal <= 0;
            we_o_internal <= 0;
            one_hot <= 10'd0;
				repetition <= 0;
        end else begin
            case (cu_fsm_internal)
                //fill the baud rate register
                5'd0 : begin
					if (repetition == 0) begin
						we_o_internal <= 1;
						stb_o_internal <= 1;
						addr_o_internal <= 32'h4;
						dat_o_internal <= 32'h1d7dbf5a;
						cu_fsm_internal <= cu_fsm_internal;
						repetition <= 1; 
						one_hot <= 10'b0000000001;
					end else if (repetition == 1) begin 
						we_o_internal <= 1;
						stb_o_internal <= 1;
						addr_o_internal <= 32'h4;
						dat_o_internal <= 32'h1d7dbf5a;
						cu_fsm_internal <= cu_fsm_internal + 1'b1;
						repetition <= 0; 
						one_hot <= 10'b0000000001;
					end
                end
                //display buffer
                5'd1 : begin
                    we_o_internal <= 0;
                    stb_o_internal <= 1;
                    addr_o_internal <= 32'h7;
                    dat_o_internal <= 32'h0;
                    one_hot <= 32'd65;
                    cu_fsm_internal <= cu_fsm_internal + 1'b1;
                end
                //fill the TX buffer
                5'd2 : begin
					if (repetition == 0) begin
					    we_o_internal <= 1;
                        stb_o_internal <= 1;
                        addr_o_internal <= 32'h7;
                        dat_o_internal <= one_hot;
                        cu_fsm_internal <= cu_fsm_internal;
					    repetition <= 1;
                        //one_hot <= 10'b0000000010;
					end else if (repetition == 1) begin
					    we_o_internal <= 1;
                        stb_o_internal <= 1;
                        addr_o_internal <= 32'h7;
                        dat_o_internal <= one_hot;
                        cu_fsm_internal <= cu_fsm_internal + 1'b1;
						repetition <= 0;
                        //one_hot <= 10'b0000000010;
					end
                end
                //start sending
                5'd3 : begin
					if (repetition == 0) begin
						we_o_internal <= 1;
						stb_o_internal <= 1;
						addr_o_internal <= 32'h3;
						dat_o_internal <= 32'h80;
						repetition <= 1;
						cu_fsm_internal <= cu_fsm_internal;
						//one_hot <= 10'b1000000000;
					end else if (repetition == 1) begin
						we_o_internal <= 1;
						stb_o_internal <= 1;
						addr_o_internal <= 32'h3;
						dat_o_internal <= 32'h80;
						repetition <= 0;
						cu_fsm_internal <= cu_fsm_internal + 1'b1;
						//one_hot <= 10'b1000000000;
					end
                end
                //poll the status register
                5'd4 : begin
                    we_o_internal <= 0;
                    stb_o_internal <= 1;
                    addr_o_internal <= 32'h5;
                    dat_o_internal <= 32'h0;
                    //one_hot <= 10'b0000000011;
                    if (dat_i[5] == 1) cu_fsm_internal <= cu_fsm_internal + 1'b1;
                    else if (dat_i[5] == 0) cu_fsm_internal <= cu_fsm_internal;
                end
                //clear UART flag
                5'd5 : begin
					if (repetition == 0) begin
                        we_o_internal <= 1;
                        stb_o_internal <= 1;
                        addr_o_internal <= 32'h5;
                        dat_o_internal <= 32'h0;
                        //one_hot <= 10'b100000001;
						repetition <= 1;
                        cu_fsm_internal <= cu_fsm_internal;
                    end else if (repetition == 1) begin
                        we_o_internal <= 1;
                        stb_o_internal <= 1;
                        addr_o_internal <= 32'h5;
                        dat_o_internal <= 32'h0;
                        //one_hot <= 10'b100000001;
						repetition <= 0;
                        cu_fsm_internal <= cu_fsm_internal + 1'b1;
                    end
                end
                //display buffer
                5'd6 : begin
                    we_o_internal <= 0;
                    stb_o_internal <= 1;
                    addr_o_internal <= 32'h7;
                    dat_o_internal <= 32'h0;
                    one_hot <= 32'd82;
                    cu_fsm_internal <= cu_fsm_internal + 1'b1;
                end
                //fill the TX buffer
                5'd7 : begin
						if (repetition == 0) begin
						    we_o_internal <= 1;
                            stb_o_internal <= 1;
                            addr_o_internal <= 32'h7;
                            dat_o_internal <= one_hot;
                            cu_fsm_internal <= cu_fsm_internal;
						    repetition <= 1;
                            //one_hot <= 10'b0000000010;
						end else if (repetition == 1) begin
						    we_o_internal <= 1;
                            stb_o_internal <= 1;
                            addr_o_internal <= 32'h7;
                            dat_o_internal <= one_hot;
                            cu_fsm_internal <= cu_fsm_internal + 1'b1;
						    repetition <= 0;
                            //one_hot <= 10'b0000000010;
						end
                end
                //start sending
                5'd8 : begin
					if (repetition == 0) begin
                        we_o_internal <= 1;
                        stb_o_internal <= 1;
                        addr_o_internal <= 32'h3;
                        dat_o_internal <= 32'h80;
						repetition <= 1;
                        cu_fsm_internal <= cu_fsm_internal;
                        //one_hot <= 10'b1000000000;
					end else if (repetition == 1) begin
					    we_o_internal <= 1;
                        stb_o_internal <= 1;
                        addr_o_internal <= 32'h3;
                        dat_o_internal <= 32'h80;
						repetition <= 0;
                        cu_fsm_internal <= cu_fsm_internal + 1'b1;
                        //one_hot <= 10'b1000000000;
					end
                end
                //poll the status register
                5'd9 : begin
                    we_o_internal <= 0;
                    stb_o_internal <= 1;
                    addr_o_internal <= 32'h5;
                    dat_o_internal <= 32'h0;
                    //one_hot <= 10'b0000000011;
                    if (dat_i[5] == 1) cu_fsm_internal <= cu_fsm_internal + 1'b1;
                    else if (dat_i[5] == 0) cu_fsm_internal <= cu_fsm_internal;
                end
                //clear UART flag
                5'd10 : begin
					if (repetition == 0) begin
                        we_o_internal <= 1;
                        stb_o_internal <= 1;
                        addr_o_internal <= 32'h5;
                        dat_o_internal <= 32'h0;
                        //one_hot <= 10'b100000001;
						repetition <= 1;
                        cu_fsm_internal <= cu_fsm_internal;
                    end else if (repetition == 1) begin
                        we_o_internal <= 1;
                        stb_o_internal <= 1;
                        addr_o_internal <= 32'h5;
                        dat_o_internal <= 32'h0;
                        //one_hot <= 10'b100000001;
					    repetition <= 0;
                        cu_fsm_internal <= cu_fsm_internal + 1'b1;
                    end
                end
                //display buffer
                5'd11 : begin
                    we_o_internal <= 0;
                    stb_o_internal <= 1;
                    addr_o_internal <= 32'h7;
                    dat_o_internal <= 32'h0;
                    one_hot <= 32'd85;
                    cu_fsm_internal <= cu_fsm_internal + 1'b1;
                end
                //fill the TX buffer
                5'd12 : begin
						if (repetition == 0) begin
						    we_o_internal <= 1;
                            stb_o_internal <= 1;
                            addr_o_internal <= 32'h7;
                            dat_o_internal <= one_hot;
                            cu_fsm_internal <= cu_fsm_internal;
						    repetition <= 1;
                            //one_hot <= 10'b0000000010;
						end else if (repetition == 1) begin
						    we_o_internal <= 1;
                            stb_o_internal <= 1;
                            addr_o_internal <= 32'h7;
                            dat_o_internal <= one_hot;
                            cu_fsm_internal <= cu_fsm_internal + 1'b1;
						    repetition <= 0;
                            //one_hot <= 10'b0000000010;
						end
                end
                //start sending
                5'd13 : begin
					if (repetition == 0) begin
                        we_o_internal <= 1;
                        stb_o_internal <= 1;
                        addr_o_internal <= 32'h3;
                        dat_o_internal <= 32'h80;
						repetition <= 1;
                        cu_fsm_internal <= cu_fsm_internal;
                        //one_hot <= 10'b1000000000;
					end else if (repetition == 1) begin
						we_o_internal <= 1;
                        stb_o_internal <= 1;
                        addr_o_internal <= 32'h3;
                        dat_o_internal <= 32'h80;
					    repetition <= 0;
                        cu_fsm_internal <= cu_fsm_internal + 1'b1;
                        //one_hot <= 10'b1000000000;
					end
                end
                //poll the status register
                5'd14 : begin
                    we_o_internal <= 0;
                    stb_o_internal <= 1;
                    addr_o_internal <= 32'h5;
                    dat_o_internal <= 32'h0;
                    //one_hot <= 10'b0000000011;
                    if (dat_i[5] == 1) cu_fsm_internal <= cu_fsm_internal + 1'b1;
                    else if (dat_i[5] == 0) cu_fsm_internal <= cu_fsm_internal;
                end
                //clear UART flag
                5'd15 : begin
					if (repetition == 0) begin
                        we_o_internal <= 1;
                        stb_o_internal <= 1;
                        addr_o_internal <= 32'h5;
                        dat_o_internal <= 32'h0;
                        //one_hot <= 10'b100000001;
					    repetition <= 1;
                        cu_fsm_internal <= cu_fsm_internal;
                    end else if (repetition == 1) begin
                        we_o_internal <= 1;
                        stb_o_internal <= 1;
                        addr_o_internal <= 32'h5;
                        dat_o_internal <= 32'h0;
                        //one_hot <= 10'b100000001;
					    repetition <= 0;
                        cu_fsm_internal <= cu_fsm_internal + 1'b1;
                    end
                end
                //delay for 1 second
                5'd16 : begin
                    //one_hot <= 10'b100100101;
                    counter_timer_internal <= counter_timer_internal + 32'h10cc;
                    if (counter_timer_internal[31] == 1'b1) begin 
                        cu_fsm_internal <= 5'd1;
                        counter_timer_internal <= 0;
						we_o_internal <= 0;
						stb_o_internal <= 0;
						addr_o_internal <= 32'h0;
						dat_o_internal <= 32'h0;
                    end
                    else begin 
                        cu_fsm_internal <= cu_fsm_internal;
                        we_o_internal <= 0;
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
    assign out_led = one_hot;
endmodule
