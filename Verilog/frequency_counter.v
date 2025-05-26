`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:53:19 02/20/2025 
// Design Name: 
// Module Name:    frequency_counter 
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
module frequency_counter(
    input ext_rst_i,
    input rst_i,
    input clk_i,
    input [31:0] addr_i,
    input [31:0] dat_i,
    input we_i,
    input [3:0] sel_i,
    input cyc_i,
    input stb_i,
    input lock_i,
    input tagn_i,
    input signal_input,                     //target signal input port
    input reference_clk_main,                  //reference clock, 100MHz, with different phase shift
    input [3:0] reference_clk_interpolate,
    output reg [31:0] dat_o,
    output reg err_o,
    output reg rty_o,
    output reg ack_o,
    output reg tagn_o,
    //for debugging purposes
    output reg blinker_3,
    output [9:0] register_window,
    output reg [1:0] status
    );
	
	reg [31:0] measurement_count_internal;       //front-end measurement counter register, where counting happens and data stored before being pushed to the bus-facing register
    reg [31:0] measurement_count_reg;            //bus-facing coarse counter data register, accessible through the wishbone bus
    reg [4:0] phase_count_internal;             //front-end measurement counter register, where counting happens and data stored before being pushed to the bus-facing register
    reg [9:0] phase_count_intermediate;
    reg [31:0] phase_count_reg;                  //bus-facing fine counter data register, accessible through the wishbone bus
    reg [7:0] counter_control_reg;               //counter control register, used to start the measurement and indicate whether a measurement has been finished or not
    reg [15:0] measurement_state_machine;        //state machine to indicate whether input signal rising edge is present or not
    reg measurement_begin;                       //state of the measurement state machine from the last clock cycle
    reg measurement_is_done;                     //register of whether a measurement has been done or not, useful when waiting for rising edge
    reg counter_ready;
    reg interpolation_in_beginning_done;
    reg [31:0] counter_pll_1;

    wire counter_reset_internal;                 //used to reset front-end counter register after each measurement

    //this is the input signal edge detection. used for gating the reference clock
    //so it doesn't increment when the signal is not present
    //also act as state machine to indicate whether to measure or to push the result to the main register

    always @(posedge signal_input) begin
        //Measurement flag controller, used for resetting flags in various condition
        //also used for controlling interpolation operation because of the FSM lagging by 1 signal cycle
        if (rst_i == 1 || ext_rst_i == 0 || counter_reset_internal == 1) begin 
            measurement_begin <= 0;
            measurement_is_done <= 0;
            counter_ready <= 0;
        end else if (counter_control_reg[7] == 1 && measurement_is_done == 0) begin
            measurement_begin <= 1;
            counter_ready <= 1'b0;
        end
        else if (measurement_is_done == 1'b1) begin 
            measurement_is_done <= 0;
            measurement_begin <= 0;
            counter_ready <= 1'b1;
        end else begin
            measurement_begin <= 0;
            counter_ready <= 1'b1;
        end
		
        //FSM driver code
        if (rst_i == 1 || ext_rst_i == 0 || counter_reset_internal == 1) begin 
            measurement_state_machine <= 10'd0;
        end else if (measurement_begin == 1 && measurement_is_done == 0) begin 
            if (measurement_state_machine == 16'd998) begin
                measurement_is_done <= 1'b1;
                measurement_state_machine <= 10'd0;
                status[0] <= 1'b1;
            end else begin 
                measurement_state_machine <= measurement_state_machine + 1'd1;
                status[0] <= 1'b0;
            end
        end
        else measurement_state_machine <= measurement_state_machine;
    end

    always @(posedge reference_clk_main) begin
        //push to bus-facing register if measurement is done
        if (rst_i == 1'b1 || counter_reset_internal == 1'b1) measurement_count_internal <= 32'd0;
        else if (measurement_begin == 1'b1) begin 
            status[1] <= 1'b1;
		    if (measurement_is_done == 1'b1) begin
				measurement_count_internal <= measurement_count_internal;
				//measurement_count_internal <= 32'd0;
            end else measurement_count_internal <= measurement_count_internal + 1'b1;
        end
        else begin 
            measurement_count_internal <= 32'd0;
            status[1] <= 1'b0;
        end
	
        //Interpolation register for the beginning of measurement, at rising edge of measurement_begin
        if (measurement_begin == 1'b1 && interpolation_in_beginning_done == 1'b0) begin 
            interpolation_in_beginning_done <= 1'b1;
            phase_count_intermediate[4] <= phase_count_internal[4];
            phase_count_intermediate[3] <= phase_count_internal[3];
            phase_count_intermediate[2] <= phase_count_internal[2];
            phase_count_intermediate[1] <= phase_count_internal[1];
            phase_count_intermediate[0] <= phase_count_internal[0];
        end

        //interplation for end of measurement, at rising edge of measurement_is_done
        if (measurement_is_done == 1'b1) begin
            interpolation_in_beginning_done <= 1'b0;
            phase_count_intermediate[9] <= phase_count_internal[4];
            phase_count_intermediate[8] <= phase_count_internal[3];
            phase_count_intermediate[7] <= phase_count_internal[2];
            phase_count_intermediate[6] <= phase_count_internal[1];
            phase_count_intermediate[5] <= phase_count_internal[0];
        end

        //if (counter_pll_1[31] == 1'b1) begin
			blinker_3 <= ~blinker_3;
			//counter_pll_1 <= 32'd0;
		//end else begin
			//counter_pll_1 <= counter_pll_1 + 32'h2b;
		//end
    end

    //internal interpolation measurement begins here, using flip-flop that goes 1 and 0 like waves
    always @(posedge reference_clk_main) begin
        phase_count_internal[4] <= ~phase_count_internal[4];
    end

    always @(posedge reference_clk_interpolate[3]) begin
        phase_count_internal[3] <= ~phase_count_internal[3];
    end

    always @(posedge reference_clk_interpolate[2]) begin
        phase_count_internal[2] <= ~phase_count_internal[2];
    end

    always @(posedge reference_clk_interpolate[1]) begin
        phase_count_internal[1] <= ~phase_count_internal[1];
    end

    always @(posedge reference_clk_interpolate[0]) begin
        phase_count_internal[0] <= ~phase_count_internal[0];
    end

    //this is the bus-facing interface, responsible for storing data and synchronizing with main control unit
    //it contains the register readily accessible by the control unit via wishbone
    //control register bit function : 
    // - bit 7 : measurement begin (1 for start, 0 for stop) 
    // - bit 6 : measurement is done flag (do not write 1, only write 0 for resetting)
    // - bit 0 : counter reset

    always @(posedge clk_i) begin
        if (rst_i == 1 || counter_control_reg[0] == 1 || ext_rst_i == 0) begin
            counter_control_reg <= 8'b00000000;
            dat_o <= 0;
			ack_o <= 0;
        end
        if (we_i == 1 && stb_i == 1) begin 
            if (addr_i == 32'h8) begin
                //update control register according to the data supplied from dat_i
				counter_control_reg <= dat_i[7:0];           
				ack_o <= 1;
            end else begin            
                ack_o <= 0;
            end
        end else if (we_i == 0 && stb_i == 1) begin 
            //counter control register (0x08)
            if (addr_i == 32'h8) begin
                dat_o[7:0] <= counter_control_reg;
                dat_o[31:8] <= 24'd0;
                ack_o <= 1;
            //counter counter result register (0x09)
            end else if (addr_i == 32'h9) begin
                dat_o <= measurement_count_reg;
                ack_o <= 1;
            //counter phase begin - end register (0x0a)
            end else if (addr_i == 32'ha) begin
                dat_o <= phase_count_reg;
                ack_o <= 1;
            end else begin 
                dat_o <= 32'd0;
                ack_o <= 0;
            end
        end
    
        if (measurement_is_done == 1) begin 
            counter_control_reg[6] <= 1;
            counter_control_reg[7] <= 0;
            measurement_count_reg <= measurement_count_internal;
            case (phase_count_intermediate[4:0]) 
                5'b10000 : phase_count_reg[4:0] <= 0;
                5'b11000 : phase_count_reg[4:0] <= 1;
                5'b11100 : phase_count_reg[4:0] <= 2;
                5'b11110 : phase_count_reg[4:0] <= 3;
                5'b11111 : phase_count_reg[4:0] <= 4;
                5'b01111 : phase_count_reg[4:0] <= 0;
                5'b00111 : phase_count_reg[4:0] <= 1;
                5'b00011 : phase_count_reg[4:0] <= 2;
                5'b00001 : phase_count_reg[4:0] <= 3;
                5'b00000 : phase_count_reg[4:0] <= 4;
            endcase
            case (phase_count_intermediate[9:5]) 
                5'b10000 : phase_count_reg[9:5] <= 0;
                5'b11000 : phase_count_reg[9:5] <= 1;
                5'b11100 : phase_count_reg[9:5] <= 2;
                5'b11110 : phase_count_reg[9:5] <= 3;
                5'b11111 : phase_count_reg[9:5] <= 4;
                5'b01111 : phase_count_reg[9:5] <= 0;
                5'b00111 : phase_count_reg[9:5] <= 1;
                5'b00011 : phase_count_reg[9:5] <= 2;
                5'b00001 : phase_count_reg[9:5] <= 3;
                5'b00000 : phase_count_reg[9:5] <= 4;
            endcase
        end else if (counter_control_reg[0] == 1) counter_control_reg <= 8'd0;

        counter_control_reg[5] <= counter_ready;
    end

    assign counter_reset_internal = counter_control_reg[0]; 
    assign register_window = measurement_count_internal[9:0];
endmodule  


//PR: 
// - working on the analysis of the FSM, whether it is capable of entering the unintended state or not
// - testing the behaviour of the module via simulation, for various condition
// - deciding whether the counter module is better to be separated futher as submodules or not