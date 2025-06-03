`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:57:16 12/28/2024 
// Design Name: 
// Module Name:    uart_interface 
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
module uart_interface(
    input ext_rst_i,
    output uart_tx,
    input uart_rx,
    input rst_i,
    input clk_i,
    input [31:0] addr_i,
    input [31:0] dat_i,
    output reg [31:0] dat_o,
    input we_i,
    input [3:0] sel_i,
    input cyc_i,
    input stb_i,
	input lock_i,
	output reg err_o,
	output reg rty_o,
    output reg ack_o,
    input tagn_i,
    output reg tagn_o
    );

    //Below is functional register. That is, the one that we are going to access using the bus
    reg [8:0] uart_buffer_tx;
    reg [7:0] uart_buffer_rx;
    reg [7:0] uart_rx_ctrl_reg;
    reg [7:0] uart_tx_ctrl_reg;
    reg [7:0] uart_status_reg;
    reg [31:0] baud_rate_divider_constant;
    reg [31:0] uart_read_buffer_internal;
    reg bus_acknowledge;
    reg [7:0] uart_status_indicator;
	
    //below is the buffer register used for interfacing between clock domains of the UART modules and top level
    reg uart_status_frame_sent_complete_buffer_1;
    reg uart_status_frame_sent_complete_buffer_2;
    reg uart_status_tx_ready_buffer_1;
    reg uart_status_tx_ready_buffer_2;

    //below is the wires used for connection between modules and top level integration
    wire uart_frame_receive_complete;
    wire uart_parity_error_flag;
    wire uart_frame_sent_clear;
    wire [8:0] uart_rx_data_out;
    wire uart_status_frame_sent_complete;
    wire uart_status_tx_ready;

    //Below is the modules instantiated for UART top level 
    uart_tx_module tx_module(
        .tx_data_line(uart_tx),
        .clk_i(clk_i),
        .rst_i(rst_i),
        .ext_rst_i(ext_rst_i),
        .tx_ctrl_reg(uart_tx_ctrl_reg),
        .baud_rate_divider_constant(baud_rate_divider_constant),
        .tx_data_in(uart_buffer_tx),
        .tx_module_ready(uart_status_tx_ready),
        .frame_sent_complete(uart_status_frame_sent_complete)
    );

    //address for UART Registers : 
    //UART RX Control : 0x02
    //UART TX Control : 0x03
    //UART Baud Rate Divider : 0x04
    //UART Status : 0x05
    //UART RX Buffer : 0x06
    //UART TX Buffer : 0x07

    //UART status register bit mapping
    //- Bit 7 : RX Frame receive complete
    //- Bit 6 : RX Parity error
    //- Bit 5 : TX Frame sent complete
    //- Bit 4 : TX Ready (after transmitting)

    always @(posedge clk_i) begin
        //below is the code for writing the register
        if (rst_i == 1 || ext_rst_i == 0) begin
            baud_rate_divider_constant <= 0;
            uart_buffer_tx <= 9'b000000000;
            uart_rx_ctrl_reg <= 8'b00000000;
            uart_tx_ctrl_reg <= 8'b00000000;
            uart_read_buffer_internal <= 8'b00000000;
            uart_status_reg <= 8'b00000000;
            uart_status_indicator <= 8'b00000000;
        end
        
        else if (we_i == 1 && stb_i == 1) begin 
            if (addr_i == 32'h2) begin
                uart_rx_ctrl_reg <= dat_i[7:0];
                ack_o <= 1;
                uart_status_indicator <= 8'b10000010;
            end else if (addr_i == 32'h3) begin 
                uart_tx_ctrl_reg <= dat_i[7:0];
                ack_o <= 1;
                uart_status_indicator <= 8'b10000011;
            end else if (addr_i == 32'h4) begin 
                baud_rate_divider_constant <= dat_i;
                ack_o <= 1;
                uart_status_indicator <= 8'b10000100;
            end else if (addr_i == 32'h5) begin 
                uart_status_reg <= dat_i[7:0];
                ack_o <= 1;
            end else if (addr_i == 32'h6) begin 
                uart_buffer_rx <= dat_i[7:0];
                ack_o <= 1;
            end else if (addr_i == 32'h7) begin 
                case (sel_i) 
                    4'b0001 : begin 
                        uart_buffer_tx <= dat_i[7:0];
                        ack_o <= 1;
                    end
                    4'b0010 : begin 
                        uart_buffer_tx <= dat_i[15:8];
                        ack_o <= 1;
                    end
                    4'b0100 : begin 
                        uart_buffer_tx <= dat_i[23:16];
                        ack_o <= 1;
                    end
                    4'b1000 : begin 
                        uart_buffer_tx <= dat_i[31:24];
                        ack_o <= 1;
                    end
                endcase
            end else begin
                ack_o <= 0;
                //uart_status_indicator <= 8'b11111111;
            end
        end 
        
        //below is the code for reading the register
        else if (we_i == 0 && stb_i == 1) begin 
            if (addr_i == 32'h2) begin 
                dat_o[7:0] <= uart_rx_ctrl_reg;
                dat_o[31:8] <= 24'd0;
                ack_o <= 1;
                uart_status_indicator <= 8'b00000010;
            end else if (addr_i == 32'h3) begin 
                dat_o[7:0] <= uart_tx_ctrl_reg;
                ack_o <= 1;
                dat_o[31:8] <= 24'd0;
                uart_status_indicator <= 8'b00000011;
            end else if (addr_i == 32'h4) begin 
                dat_o[15:0] <= baud_rate_divider_constant[15:0];
                dat_o[31:16] <= 16'd0; 
                ack_o <= 1;
                uart_status_indicator <= 8'b00000100;
            end else if (addr_i == 32'h5) begin 
                dat_o[7:0] <= uart_status_reg;
                dat_o[31:8] <= 24'd0;
                ack_o <= 1;
                uart_status_indicator <= 8'b00000101;
            end else if (addr_i == 32'h6) begin 
                dat_o[7:0] <= uart_buffer_rx;
                dat_o[31:8] <= 24'd0;
                ack_o <= 1;
                uart_status_indicator <= 8'b00000110;
            end else if (addr_i == 32'h7) begin 
                dat_o[7:0] <= uart_buffer_tx[7:0];
                dat_o[31:8] <= 24'd0;
                ack_o <= 1;
                uart_status_indicator <= 8'b00000111;
            end else begin
                dat_o <= 32'd0;
                ack_o <= 0;
                //uart_status_indicator <= 8'b10000001;
            end
        end else begin 
            dat_o <= 32'd0;
            ack_o <= 0;
        end
 
        if (uart_rx_ctrl_reg[3] == 1) begin
            uart_rx_ctrl_reg[3] <= 0;
        end 
        if (uart_frame_receive_complete == 1 && uart_status_reg[7] == 0) begin 
            uart_buffer_rx <= uart_rx_data_out[7:0];
            uart_rx_ctrl_reg[7] <= 0;
            uart_status_reg[7] <= 1;
        end 
        if (uart_parity_error_flag == 1 && uart_status_reg[6] == 0) begin 
            uart_status_reg[6] <= 1;
        end 
        if (uart_status_frame_sent_complete == 1 && uart_status_reg[5] == 0) begin
            uart_status_reg[5] <= 1'b1;
            uart_tx_ctrl_reg[7] <= 0;
        end
        
        uart_status_reg[4] <= uart_status_tx_ready;
        /*
        buffering for UART TX module
        //buffering begins here
        uart_status_reg[4] <= uart_status_tx_ready_buffer_2;
        uart_status_tx_ready_buffer_2 <= uart_status_tx_ready_buffer_1;
        uart_status_tx_ready_buffer_1 <= uart_status_tx_ready;

        uart_status_frame_sent_complete_buffer_2 <= uart_status_frame_sent_complete_buffer_1;
        uart_status_frame_sent_complete_buffer_1 <= uart_status_frame_sent_complete;
        //buffering ends here
        */
    end
endmodule

//the module below is for TX functionality. we try to standardize each module format so that it can be easily understandable. 
//however, it is still possible for each module to have some peculiarity caused by their specific function. so non-conformant
//module will be occasionaly seen

module uart_tx_module(  output reg tx_data_line,
                        input ext_rst_i,
                        input clk_i, 
                        input rst_i,
                        input [7:0] tx_ctrl_reg,
                        input [31:0] baud_rate_divider_constant, 
                        input [8:0] tx_data_in, 
                        output reg tx_module_ready,
                        output reg frame_sent_complete
                        );

    //tx_ctrl_reg register control operation such as send start, parity bit odd/even, data bit numbers (8 or 9)
    //bit 7 is send start, bit 6 is parity enable, bit 5 is parity odd/even, bit 4 is data length (0 -> 8b, 1 -> 9b)\
    //bit 3 is tx_reset, bit 2 is address/data bits (for 9 bit operation)
    //tx_status_reg is a register containing the operational status of the UART TX Module
    //bit 7 is frame_sent_complete,

	//reg [9:0] data_sent_internal;
    reg [31:0] baud_rate_counter_internal;
    reg [3:0] tx_fsm_internal;

    wire tx_rst_i;
    wire parity_internal;

    /*
    parity_detector parity_module(.data(tx_data_in), 
                                    .mode_bits(tx_ctrl_reg[4]),
                                    .mode_odd_even(tx_ctrl_reg[5]),
                                    .result(parity_internal)
    );
    */

	always @(posedge clk_i) begin 
        if (rst_i == 1 || tx_rst_i == 1 || ext_rst_i == 0) baud_rate_counter_internal = 32'd0;
        else if (baud_rate_counter_internal[31] == 1'b1) baud_rate_counter_internal = 32'd0;
        else baud_rate_counter_internal = baud_rate_counter_internal + baud_rate_divider_constant;
    
        if (baud_rate_counter_internal[31] == 1'b1) begin 
            if (tx_ctrl_reg[7] == 1) begin 
                if (tx_ctrl_reg[4] == 1) begin
                    case (tx_fsm_internal)
                        //start bit
                        4'b0000: begin
                            tx_module_ready <= 0;
                            frame_sent_complete <= 0;
                            tx_data_line <= 0; 
                            tx_fsm_internal <= tx_fsm_internal + 1'b1;
                        end
                        //data bits 1-9
                        4'b0001 : begin
                            tx_data_line <= tx_data_in[0]; 
                            tx_fsm_internal <= tx_fsm_internal + 1'b1;
                        end
                        4'b0010 : begin
                            tx_data_line <= tx_data_in[1]; 
                            tx_fsm_internal <= tx_fsm_internal + 1'b1;
                        end
                        4'b0011 : begin
                            tx_data_line <= tx_data_in[2]; 
                            tx_fsm_internal <= tx_fsm_internal + 1'b1;
                        end
                        4'b0100 : begin
                            tx_data_line <= tx_data_in[3]; 
                            tx_fsm_internal <= tx_fsm_internal + 1'b1;
                        end
                        4'b0101 : begin
                            tx_data_line <= tx_data_in[4]; 
                            tx_fsm_internal <= tx_fsm_internal + 1'b1;
                        end
                        4'b0110 : begin
                            tx_data_line <= tx_data_in[5]; 
                            tx_fsm_internal <= tx_fsm_internal + 1'b1;
                        end
                        4'b0111 : begin
                            tx_data_line <= tx_data_in[6]; 
                            tx_fsm_internal <= tx_fsm_internal + 1'b1;
                        end
                        4'b1000 : begin
                            tx_data_line <= tx_data_in[7]; 
                            tx_fsm_internal <= tx_fsm_internal + 1'b1;
                        end
                        4'b1001 : begin
                            tx_data_line <= tx_data_in[8]; 
                            tx_fsm_internal <= tx_fsm_internal + 1'b1;
                        end
                        4'b1010 : begin
                            case (tx_ctrl_reg[6])
                                1'b1 : begin
                                    tx_data_line <= ((((tx_data_in[7] ^ tx_data_in[6])^(tx_data_in[5] ^ tx_data_in[4]))^((tx_data_in[3] ^ tx_data_in[2])^(tx_data_in[1] ^ tx_data_in[0]))) ^ tx_data_in[8]) & tx_ctrl_reg[5]; 
                                    tx_fsm_internal <= tx_fsm_internal + 1'b1;
                                end
                                1'b0 : begin
                                    tx_data_line <= 1; 
                                    frame_sent_complete <= 1;
                                    tx_fsm_internal <= 4'b0000;
                                end
                            endcase
                        end
                        4'b1011 : begin
                            tx_data_line <= 1; 
                            frame_sent_complete <= 1;
                            tx_fsm_internal <= 4'b0000;
                        end
                    endcase
                //if it is a 8 bit data frame, then do below : 
                end else if (tx_ctrl_reg[4] == 0) begin
                    case (tx_fsm_internal)
                        //start bit
                        4'b0000: begin
                            tx_module_ready <= 0;
                            frame_sent_complete <= 0;
                            tx_data_line <= 0; 
                            tx_fsm_internal <= tx_fsm_internal + 1'b1;
                        end
                        //data bits 1-8
                        4'b0001 : begin
                            tx_data_line <= tx_data_in[0]; 
                            tx_fsm_internal <= tx_fsm_internal + 1'b1;
                        end
                        4'b0010 : begin
                            tx_data_line <= tx_data_in[1]; 
                            tx_fsm_internal <= tx_fsm_internal + 1'b1;
                        end
                        4'b0011 : begin
                            tx_data_line <= tx_data_in[2]; 
                            tx_fsm_internal <= tx_fsm_internal + 1'b1;
                        end
                        4'b0100 : begin
                            tx_data_line <= tx_data_in[3]; 
                            tx_fsm_internal <= tx_fsm_internal + 1'b1;
                        end
                        4'b0101 : begin
                            tx_data_line <= tx_data_in[4]; 
                            tx_fsm_internal <= tx_fsm_internal + 1'b1;
                        end
                        4'b0110 : begin
                            tx_data_line <= tx_data_in[5]; 
                            tx_fsm_internal <= tx_fsm_internal + 1'b1;
                        end
                        4'b0111 : begin
                            tx_data_line <= tx_data_in[6]; 
                            tx_fsm_internal <= tx_fsm_internal + 1'b1;
                        end
                        4'b1000 : begin
                            tx_data_line <= tx_data_in[7]; 
                            tx_fsm_internal <= tx_fsm_internal + 1'b1;
                        end
                        4'b1001 : begin
                            case (tx_ctrl_reg[6])
                                1'b1 : begin
                                    tx_data_line <= (((tx_data_in[7] ^ tx_data_in[6])^(tx_data_in[5] ^ tx_data_in[4]))^((tx_data_in[3] ^ tx_data_in[2])^(tx_data_in[1] ^ tx_data_in[0]))) & tx_ctrl_reg[5]; 
                                    tx_fsm_internal <= tx_fsm_internal + 1'b1;
                                end
                                1'b0 : begin
                                    tx_data_line <= 1; 
                                    frame_sent_complete <= 1;
                                    tx_fsm_internal <= 4'b0000;
                                end
                            endcase
                        end
                        4'b1010 : begin
                            tx_data_line <= 1; 
                            frame_sent_complete <= 1;
                            tx_fsm_internal <= 4'b0000;
                        end
                    endcase
                end
            end else if (tx_ctrl_reg[7] == 0) begin
                tx_fsm_internal <= 4'b0000;
                tx_module_ready <= 1;
                frame_sent_complete <= 0;
                tx_data_line <= 1;
            end
        end
	end

    assign tx_rst_i = tx_ctrl_reg[3];
endmodule

//PR : 
//- implementation of 9 bit UART (address/data bit activation is not yet known)
//- tidying up to improve format consistency between modules
//- state machine analysis to assess flaws and/or bugs