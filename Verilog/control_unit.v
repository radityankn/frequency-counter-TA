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
    output reg [31:0] addr_o,
    output reg [31:0] dat_o,
    input [31:0] dat_i,
    output reg we_o,
    output reg [3:0] sel_o,
    output reg cyc_o,
    output reg stb_o,
    output reg lock_o,
    input err_i,
    input rty_i,
    input ack_i,
    input tagn_i,
    output reg tagn_o,
    output [9:0] out_led,
    output reg blinker,
    output reg blinker_2,
	output [4:0] phase_begin,
	output [4:0] phase_end
    );

    reg [4:0] cu_fsm_internal;
    reg [4:0] next_fsm_step;
    reg [31:0] counter_timer_internal;
	reg [31:0] counter_timer_internal_2;
    reg [31:0] general_purpose_reg_a;
    reg [31:0] general_purpose_reg_b;
    reg [31:0] general_purpose_reg_1;
    reg [31:0] general_purpose_reg_2;
    reg [31:0] general_purpose_reg_3;
    reg [31:0] general_purpose_reg_4;
    reg [31:0] general_purpose_reg_5;
    reg [5:0] one_hot;
	reg [7:0] repetition;

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
    reg bcd_conversion_start;
    wire bcd_conversion_complete;
	 
	wire [31:0] multiplier_result;
	wire [31:0] divider_result;
    wire [31:0] divider_remain;
	
	/*
    multiplier_module multiplier_module_internal(
	.clock(clk_i),
	.dataa(general_purpose_reg_a),
	.datab(general_purpose_reg_b),
	.result(multiplier_result)
	);
	*/

    divider_module divider_module_internal(
	.clock (clk_i),
	.denom (general_purpose_reg_b),
	.numer (general_purpose_reg_a),
	.quotient (divider_result),
	.remain (divider_remain)
	);

    double_dabble decimal_converter(  
        .input_number(general_purpose_reg_3),
        .clk_i(clk_i),
        .conversion_start(bcd_conversion_start),
        .conversion_complete(bcd_conversion_complete),
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

    always @(posedge clk_i) begin
        if (rst_i == 1'b1 || ext_rst_i == 1'b0) begin
            bcd_conversion_start <= 1'b0;
            cu_fsm_internal <= 5'd0;
            next_fsm_step <= 5'd0;
            addr_o <= 32'd0;
            dat_o <= 32'd0;
            counter_timer_internal <= 32'd0;
            counter_timer_internal_2 <= 32'd0;
            stb_o <= 1'b0;
            we_o <= 1'b0;
            one_hot <= 6'd0;
			repetition <= 1'b0;
            sel_o <= 4'b0000;
            blinker_2 <= 1'b0;
            blinker <= 1'b0;
        end else begin
            case (cu_fsm_internal)
                //fill the baud rate register
                5'd0 : begin
					we_o <= 1'b1;
					stb_o <= 1'b1;
					addr_o <= 32'h4;
					dat_o <= 32'h4b7f5b;
                    sel_o <= 4'b1111;
                    one_hot <= 6'b000001;
					cu_fsm_internal <= 5'd2;
				end
                //counter reset
                5'd1 : begin
					we_o <= 1'b1;
                    stb_o <= 1'b1;
                    addr_o <= 32'h8;
                    dat_o <= 32'd1;
                    sel_o <= 4'b0001;
                    one_hot <= 6'b000010;
                    if (repetition == 8'b00001111) begin 
                        cu_fsm_internal <= cu_fsm_internal + 1'b1;
                        repetition <= 1'b0;
                    end
                    else begin 
                        repetition <= repetition + 1'b1;
                        cu_fsm_internal <= cu_fsm_internal;
                    end
				end
                //counter start measurement
                5'd2 : begin
                    we_o <= 1'b1;
                    stb_o <= 1'b1;
                    addr_o <= 32'h8;
                    dat_o <= 32'h80;
                    sel_o <= 4'b0001;
                    cu_fsm_internal <= cu_fsm_internal + 1'b1;
                    one_hot <= 6'b000100;
                end
                //poll until finish measuring
                5'd3 : begin
					we_o <= 1'b0;
					stb_o <= 1'b1;
					addr_o <= 32'h8;
					dat_o <= 32'h0;
                    sel_o <= 4'b0001;
                    one_hot <= 6'b001000;
                    if (dat_i[6] == 1'b1 && dat_i[5] == 1'b1) cu_fsm_internal <= cu_fsm_internal + 1'b1;
                    else cu_fsm_internal <= cu_fsm_internal;
                end
                //save the measurement result
                5'd4 : begin
                    we_o <= 1'b0;
                    stb_o <= 1'b1;
                    addr_o <= 32'h9;
                    dat_o <= 32'h0;
                    sel_o <= 4'b0000;
                    one_hot <= 6'b010000;
                    if (repetition == 8'b00000011) begin
                        general_purpose_reg_1 <= dat_i;
                        cu_fsm_internal <= cu_fsm_internal + 5'd1;
                        repetition <= 1'b0;
                    end
                    else begin
                        general_purpose_reg_1 <= dat_i;
                        cu_fsm_internal <= cu_fsm_internal;
                        repetition <= repetition + 1'b1;
                    end
                end
                //save the interpolation unit
                5'd5 : begin
                    we_o <= 1'b0;
                    stb_o <= 1'b1;
                    addr_o <= 32'ha;
                    dat_o <= 32'h0;
                    sel_o <= 4'b0000;
                    one_hot <= 6'b010000;
                    if (repetition == 8'b00000011) begin
                        general_purpose_reg_4 <= dat_i;
                        cu_fsm_internal <= cu_fsm_internal + 5'd1;
                        repetition <= 1'b0;
                    end
                    else begin
                        general_purpose_reg_2 <= dat_i;
                        cu_fsm_internal <= cu_fsm_internal;
                        repetition <= repetition + 1'b1;
                    end
                end
                //move to divider 
                5'd6 : begin
                    if (repetition == 8'd21) begin
                        general_purpose_reg_2 <= divider_result;
                        cu_fsm_internal <= cu_fsm_internal + 1'b1;
                        repetition <= 1'b0;
                    end else if (repetition == 8'd0) begin
                        general_purpose_reg_a <= 32'd1000000000;
                        general_purpose_reg_b <= general_purpose_reg_1;
                        cu_fsm_internal <= cu_fsm_internal;
                        repetition <= repetition + 1'b1;
					end else begin
                        cu_fsm_internal <= cu_fsm_internal;
                        repetition <= repetition + 1'b1;
					end
                end
                //multiply by 100 to get frequency
                5'd7 : begin
                    general_purpose_reg_3 <= general_purpose_reg_2 * 32'd100;
                    cu_fsm_internal <= cu_fsm_internal + 5'd2;
                    repetition <= 1'b0;
                end
                //get the frequency result
                5'd8 : begin 
                    cu_fsm_internal <= cu_fsm_internal + 5'd1;
                    general_purpose_reg_1 <= general_purpose_reg_3;
                end
                //convert to BCD, poll until done
                5'd9 : begin
                    one_hot <= 6'b001111;
					we_o <= 1'b0;
                    stb_o <= 1'b0;
                    addr_o <= 32'h0;
                    dat_o <= 32'd0;
                    bcd_conversion_start <= 1'b1;
                    if (bcd_conversion_complete == 1'b1) begin
                        cu_fsm_internal <= cu_fsm_internal + 5'd1;
                        bcd_conversion_start <= 1'b0;
                    end else begin 
                        cu_fsm_internal <= cu_fsm_internal;
                    end
                end
                //fill the TX buffer : part 1
                5'd10 : begin
                    one_hot <= 6'b011000;
					we_o <= 1'b1;
                    stb_o <= 1'b1;
                    addr_o <= 32'h7;
                    dat_o <= tenth_million + 32'h30;
                    sel_o <= 4'b0001;
                    cu_fsm_internal <= 5'd20;
                    next_fsm_step <= 5'd11;
                end
                //fill the TX buffer : part 2
                5'd11 : begin
                    one_hot <= 6'b001100;
					we_o <= 1'b1;
                    stb_o <= 1'b1;
                    addr_o <= 32'h7;
                    dat_o <= millions + 32'h30;
                    sel_o <= 4'b0001;
                    cu_fsm_internal <= 5'd20;
                    next_fsm_step <= 5'd12;
                end
                //fill TX buffer : part 3
                5'd12 : begin
					we_o <= 1'b1;
                    stb_o <= 1'b1;
                    addr_o <= 32'h7;
                    dat_o <= hundred_thousands + 32'h30;
                    sel_o <= 4'b0001;
                    cu_fsm_internal <= 5'd20;
                    next_fsm_step <= 5'd13;
                end
                //fill TX buffer : part 4
                5'd13 : begin
					we_o <= 1'b1;
                    stb_o <= 1'b1;
                    addr_o <= 32'h7;
                    dat_o <= ten_thousands + 32'h30;
                    sel_o <= 4'b0001;
                    cu_fsm_internal <= 5'd20;
                    next_fsm_step <= 5'd14;
                end
                //fill the TX buffer : part 1
                5'd14 : begin
					we_o <= 1'b1;
                    stb_o <= 1'b1;
                    addr_o <= 32'h7;
                    dat_o <= thousands + 32'h30;
                    sel_o <= 4'b0001;
                    cu_fsm_internal <= 5'd20;
                    next_fsm_step <= 5'd15;
                end
                //fill the TX buffer : part 2
                5'd15 : begin
					we_o <= 1'b1;
                    stb_o <= 1'b1;
                    addr_o <= 32'h7;
                    dat_o <= hundreds + 32'h30;
                    sel_o <= 4'b0001;
                    cu_fsm_internal <= 5'd20;
                    next_fsm_step <= 5'd16;
                end
                //fill TX buffer : part 3
                5'd16 : begin
					we_o <= 1'b1;
                    stb_o <= 1'b1;
                    addr_o <= 32'h7;
                    dat_o <= tens + 32'h30;
                    sel_o <= 4'b0001;
                    cu_fsm_internal <= 5'd20;
                    next_fsm_step <= 5'd17;
                end
                //fill TX buffer : part 4
                5'd17 : begin
					we_o <= 1'b1;
                    stb_o <= 1'b1;
                    addr_o <= 32'h7;
                    dat_o <= ones + 32'h30;
                    sel_o <= 4'b0001;
                    cu_fsm_internal <= 5'd20;
                    next_fsm_step <= 5'd18;
                end
                //newline
                5'd18 : begin
					we_o <= 1'b1;
                    stb_o <= 1'b1;
                    addr_o <= 32'h7;
                    dat_o <= 32'd10;
                    sel_o <= 4'b0001;
                    cu_fsm_internal <= 5'd20;
                    next_fsm_step <= 5'd19;
                end
                //carriage return
                5'd19 : begin
					we_o <= 1'b1;
                    stb_o <= 1'b1;
                    addr_o <= 32'h7;
                    dat_o <= 32'd13;
                    sel_o <= 4'b0001;
                    cu_fsm_internal <= 5'd20;
                    next_fsm_step <= 5'd2;
                end
                //start UART TX sending
                5'd20 : begin
                    one_hot <= 6'b111000;
					we_o <= 1'b1;
                    stb_o <= 1'b1;
                    addr_o <= 32'h3;
                    dat_o <= 32'h80;
                    cu_fsm_internal <= cu_fsm_internal + 1'b1;
                end
                //poll TX frame sent complete
                5'd21 : begin
                    one_hot <= 6'b011100;
					we_o <= 1'b0;
                    stb_o <= 1'b1;
                    addr_o <= 32'h5;
                    dat_o <= 32'd0;
                    if (dat_i[5] == 1'b0) cu_fsm_internal <= cu_fsm_internal + 5'd1;
                    else cu_fsm_internal <= cu_fsm_internal;
                end
                //poll TX ready
                5'd22 : begin
					we_o <= 1'b0;
                    stb_o <= 1'b1;
                    addr_o <= 32'h5;
                    dat_o <= 32'd0;
                    if (dat_i[4] == 1) cu_fsm_internal <= cu_fsm_internal + 1'b1;
                    else cu_fsm_internal <= cu_fsm_internal;
                end
                //clear UART flag
                5'd23 : begin
                    one_hot <= 6'b001110;
					we_o <= 1'b1;
                    stb_o <= 1'b1;
                    addr_o <= 32'h5;
                    dat_o <= 32'd0;
                    //cu_fsm_internal <= next_fsm_step;
                    cu_fsm_internal <= cu_fsm_internal + 1'b1;
                end
                //delay for 1 second
                5'd24 : begin
					one_hot <= 6'b100000;
                    bcd_conversion_start <= 1'b0;
                    if (counter_timer_internal[31] == 1'b1) begin 
                        //cu_fsm_internal <= 5'd4;
                        cu_fsm_internal <= next_fsm_step;
                        counter_timer_internal <= 1'b0;
						we_o <= 1'b0;
                        sel_o <= 1'b0;
						stb_o <= 1'b0;
						addr_o <= 32'h0;
						dat_o <= 32'h0;
                        blinker <= ~blinker;
                    end else begin 
                        counter_timer_internal <= counter_timer_internal + 32'h14f8b;
                        cu_fsm_internal <= cu_fsm_internal;
                        we_o <= 1'b0;
                        sel_o <= 1'b0;
						stb_o <= 1'b0;
						addr_o <= 32'h0;
						dat_o <= 32'h0;
                    end
                end
            endcase

            if (counter_timer_internal_2[31] == 1'b1) begin 
                counter_timer_internal_2 <= 1'b0;
                blinker_2 <= ~blinker_2;
            end else begin 
                counter_timer_internal_2 <= counter_timer_internal_2 + 32'h56;
            end
        end
    end

    assign out_led = general_purpose_reg_4;
	assign phase_begin = general_purpose_reg_2[4:0];
	assign phase_end = general_purpose_reg_2[9:5];
endmodule
