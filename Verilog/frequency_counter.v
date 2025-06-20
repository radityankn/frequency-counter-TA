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
    input reference_clk_interpolate,
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
	
	
    reg [31:0] measurement_count_reg;            //bus-facing coarse counter data register, accessible through the wishbone bus
    reg [7:0] phase_count_reg;                  //bus-facing fine counter data register, accessible through the wishbone bus
    reg [7:0] counter_control_reg;               //counter control register, used to start the measurement and indicate whether a measurement has been finished or not

    wire counter_reset_internal;                 //used to reset front-end counter register after each measurement

    //this is the bus-facing interface, responsible for storing data and synchronizing with main control unit
    //it contains the register readily accessible by the control unit via wishbone
    //control register bit function : 
    // - bit 7 : measurement begin (1 for start, 0 for stop) 
    // - bit 6 : measurement is done flag (do not write 1, only write 0 for resetting)
    // - bit 5 : counter ready flag
    // - bit 0 : counter reset signal

    reg measurement_end_buffer_1;
    reg measurement_end_buffer_2;
    reg counter_ready_buffer_1;
    reg counter_ready_buffer_2;

    //buffer block goes here
    //for synchronization between clock domains

    always @(posedge clk_i) begin
        measurement_end_buffer_1 <= measurement_end;
        measurement_end_buffer_2 <= measurement_end_buffer_1;
        counter_ready_buffer_1 <= counter_ready;
        counter_ready_buffer_2 <= counter_ready_buffer_1;
    end

    always @(posedge clk_i) begin
        if (rst_i == 1 || counter_control_reg[0] == 1 || ext_rst_i == 0) begin
            counter_control_reg <= 8'b00000000;
            dat_o <= 0;
			ack_o <= 0;
        end
        if (we_i == 1 && stb_i == 1) begin 
            case (addr_i)
                32'h8 : begin
                    //update control register according to the data supplied from dat_i
                    counter_control_reg <= dat_i[7:0];           
                    ack_o <= 1;
                end 
                default :  begin            
                    ack_o <= 0;
                end
            endcase
        end else if (we_i == 0 && stb_i == 1) begin 
            //counter control register (0x08)
            case (addr_i)
                32'h8 : begin
                    dat_o[7:0] <= counter_control_reg;
                    dat_o[31:8] <= 24'd0;
                    ack_o <= 1;
                //counter counter result register (0x09)
                end 
                32'h9 : begin
                    dat_o <= measurement_count_reg;
                    ack_o <= 1;
                //counter phase begin - end register (0x0a)
                end 
                32'ha : begin
                    dat_o <= phase_count_reg;
                    ack_o <= 1;
                end
                default : begin 
                    dat_o <= 32'd0;
                    ack_o <= 0;
                end
            endcase
        end
    
        if (measurement_end_buffer_2 == 1 & counter_control_reg[6] == 0) begin 
            counter_control_reg[6] <= 1;
            counter_control_reg[7] <= 0;
            measurement_count_reg <= measurement_count_internal;
            if (phase_count_intermediate[5:4] > phase_count_intermediate[1:0]) begin
                phase_count_reg <= 8'd4 - (phase_count_intermediate[7:4] - phase_count_intermediate[3:0]);
            end else if (phase_count_intermediate[5:4] == phase_count_intermediate[1:0]) begin 
                phase_count_reg <= 8'd4 - (phase_count_intermediate[3:0] - phase_count_intermediate[7:4]);
            end else begin 
                phase_count_reg <= 8'd4 - (phase_count_intermediate[3:0] - phase_count_intermediate[7:4]);
            end
            //phase_count_reg <= phase_count_intermediate;
        end else if (counter_control_reg[0] == 1) counter_control_reg <= 8'd0;

        counter_control_reg[5] <= counter_ready_buffer_2;
    end

    /*
    Counter front-end begins here
    used to interact with the input signal and reference clock
    */

    reg [31:0] measurement_count_internal;       //front-end measurement counter register, where counting happens and data stored before being pushed to the bus-facing register
    reg [1:0] phase_count_internal;             //front-end measurement counter register, where counting happens and data stored before being pushed to the bus-facing register
    reg [7:0] phase_count_intermediate;
    reg [15:0] measurement_state_machine;        //state machine to indicate whether input signal rising edge is present or not
    reg measurement_began;                       //state of the measurement state machine from the last clock cycle
    reg measurement_end;                     //register of whether a measurement has been done or not, useful when waiting for rising edge
    reg counter_ready;
    reg [31:0] counter_pll_1;

    reg measurement_begin_buffer_1;
    reg measurement_begin_buffer_2;

    //buffer blocks here, it simply uses the incoming clock signal to propagates the input
    always @(posedge signal_input) begin
        measurement_begin_buffer_1 <= counter_control_reg[7];
        measurement_begin_buffer_2 <= measurement_begin_buffer_1;
    end

    //interpolation bits
    reg interpolation_in_beginning_done;
    reg interpolation_in_end_done;

    always @(posedge signal_input) begin
        case (measurement_state_machine)
            16'd0 : begin
                if (rst_i == 1 || ext_rst_i == 0 || counter_reset_internal == 1) begin 
                    measurement_state_machine <= 16'd0;
                    counter_ready <= 1'b0;
                    measurement_began <= 1'b0;
                    measurement_end <= 1'b0;
                end else if (measurement_begin_buffer_2 == 1) begin
                    measurement_began <= 1'b1;
                    counter_ready <= 1'b0;
                    measurement_state_machine <= measurement_state_machine + 1'b1;
                end else begin
                    counter_ready <= 1'b1;
                    measurement_began <= 1'b0;
                    measurement_end <= 1'b0;
                    measurement_state_machine <= measurement_state_machine;
                end
            end
            16'd1000 : begin //16'd1000
                if (rst_i == 1 || ext_rst_i == 0 || counter_reset_internal == 1) begin 
                    measurement_state_machine <= 16'd0;
                end else if (measurement_begin_buffer_2 == 1'b0) begin
                    measurement_state_machine <= 16'd0;
                end else begin 
                    measurement_state_machine <= measurement_state_machine;
                    measurement_end <= 1'b1;
                end
            end
            default : begin 
                if (rst_i == 1 || ext_rst_i == 0 || counter_reset_internal == 1) begin 
                    measurement_state_machine <= 16'd0;
                end else measurement_state_machine <= measurement_state_machine + 1'b1;
            end
        endcase

        //interpolation begins here
        //Interpolation register for the beginning of measurement, at rising edge of measurement_begin
        if (measurement_begin_buffer_2 == 1'b1 && interpolation_in_beginning_done == 1'b0) begin 
            interpolation_in_beginning_done <= 1'b1;
            phase_count_intermediate[1:0] <= phase_count_internal;
        end

        //interplation for end of measurement, at the end of measurement_state_machine
        else if (measurement_state_machine == 16'd1000 & interpolation_in_end_done == 1'b0) begin
            interpolation_in_end_done <= 1'b1;
            phase_count_intermediate[5:4] <= phase_count_internal;
        end

        else if (rst_i == 1 || ext_rst_i == 0 || counter_reset_internal == 1) begin 
            phase_count_intermediate[7:0] <= 8'b0;
            interpolation_in_beginning_done = 1'b0;
            interpolation_in_end_done <= 1'b0;
        end

        else if (measurement_begin_buffer_2 == 1'b0 && measurement_end == 0) begin 
            interpolation_in_beginning_done = 1'b0;
            interpolation_in_end_done <= 1'b0;
        end

        else begin
            phase_count_intermediate[7:0] <= phase_count_intermediate[7:0];
        end 
        //if (counter_pll_1[31] == 1'b1) begin
			blinker_3 <= ~blinker_3;
			//counter_pll_1 <= 32'd0;
		//end else begin
			//counter_pll_1 <= counter_pll_1 + 32'h2b;
		//end
    end

    //main clock measurement block here
    always @(posedge reference_clk_main) begin
        //push to bus-facing register if measurement is done
        if (rst_i == 1'b1 || counter_reset_internal == 1'b1) measurement_count_internal <= 32'd0;
        else if (measurement_began == 1'b1) begin 
            status[1] <= 1'b1;
		    if (measurement_end == 1'b1) begin
				measurement_count_internal <= measurement_count_internal;
            end else measurement_count_internal <= measurement_count_internal + 1'b1;
        end else begin 
            measurement_count_internal <= 32'd0;
            status[1] <= 1'b0;
        end
    end

    //internal interpolation measurement begins here, using registers
    always @(posedge reference_clk_interpolate) begin
        if (rst_i == 1 || ext_rst_i == 0 || counter_reset_internal == 1) phase_count_internal <= 2'b0;
        else phase_count_internal <= phase_count_internal + 1'b1;
    end

    assign counter_reset_internal = counter_control_reg[0]; 
    //assign register_window = phase_count_intermediate;
endmodule  


//PR: 
// - working on the analysis of the FSM, whether it is capable of entering the unintended state or not
// - testing the behaviour of the module via simulation, for various condition
// - deciding whether the counter module is better to be separated futher as submodules or not