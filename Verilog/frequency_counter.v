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
    input reference_clk_1,                  //reference clock, 100MHz
    input reference_clk_2,                  //refence clock, 100MHz, subsequent clock are shifted 72 degrees to each other in a succession order
    input reference_clk_3,                  
    input reference_clk_4,
    input reference_clk_5,
    output [31:0] dat_o,
    output err_o,
    output rty_o,
    output ack_o,
    output tagn_o,
    output [1:0] counter_flags
    );
	
	reg [31:0] measurement_count_internal;       //front-end measurement counter register, where counting happens and data stored before being pushed to the bus-facing register
    reg [31:0] measurement_count_reg;            //bus-facing coarse counter data register, accessible through the wishbone bus
    reg [31:0] phase_count_reg;              //bus-facing fine counter data register, accessible through the wishbone bus
    reg [7:0] counter_control_reg;                  //counter control register, used to start the measurement and indicate whether a measurement has been finished or not
    reg [9:0] measurement_state_machine;          //state machine to indicate whether input signal rising edge is present or not
    reg measurement_begin;             //state of the measurement state machine from the last clock cycle
    reg measurement_is_done;                //register of whether a measurement has been done or not, useful when waiting for rising edge
    reg [31:0] counter_read_buffer;
	reg bus_acknowledge;

    wire reference_clk_1_internal;          //coarse clock, as intended from a vernier reciprocal counter
    wire reference_clk_2_internal;          //fine clock, as intended from a vernier reciprocal counter
    wire counter_reset_internal;            //used to reset front-end counter register after each measurement

    //this is the input signal edge detection. used for gating the reference clock
    //so it doesn't increment when the signal is not present
    //also act as state machine to indicate whether to measure or to push the result to the main register

    always @(posedge signal_input) begin
        if (rst_i == 1 || ext_rst_i == 0 || counter_reset_internal == 1) begin 
            measurement_begin <= 0;
            measurement_is_done <= 0;
        end
        else if (counter_control_reg[7] == 1 && measurement_is_done == 0) measurement_begin <= 1;
        else if (counter_control_reg[6] == 1) begin 
            measurement_is_done <= 0;
            measurement_begin <= 0;
        end
        else measurement_begin <= 0;
		  
        if (rst_i == 1 || ext_rst_i == 0 || counter_reset_internal == 1) measurement_state_machine <= 10'd0;
        else if (measurement_begin == 1 && measurement_is_done == 0) begin 
            if (measurement_state_machine == 10'd999) begin
                measurement_is_done <= 1;
                measurement_state_machine <= 10'd0;
            end
            else measurement_state_machine <= measurement_state_machine + 1'd1;
        end
        else measurement_state_machine <= measurement_state_machine;
    end

    //the code below is the counter front-end. clocked by the reference clock, this is 
    //where we are going to get our initial result before being pushed to the data register
    //there are 2 register, for coarse and fine counter respectively

    always @(posedge reference_clk_1) begin
        if (rst_i == 1 || counter_reset_internal == 1) measurement_count_internal <= 32'd0;
        else if (measurement_begin == 1 && measurement_is_done == 0) measurement_count_internal <= measurement_count_internal + 1'b1;
		  else if (measurement_is_done == 1) begin
				measurement_count_reg <= measurement_count_internal;
				measurement_count_internal <= 32'd0;
		  end
        else measurement_count_internal <= measurement_count_internal;
    end
	
    //Interpolation register for the beginning of measurement, at rising edge of measurement_begin
	always @(posedge measurement_begin) begin
        phase_count_reg[9] <= reference_clk_1; 
        phase_count_reg[8] <= reference_clk_2;
        phase_count_reg[7] <= reference_clk_3;
        phase_count_reg[6] <= reference_clk_4;
        phase_count_reg[5] <= reference_clk_5;
	end

    //interplation for end of measurement, at rising edge of measurement_is_done
    always @(posedge measurement_is_done) begin
        phase_count_reg[4] <= reference_clk_1; 
        phase_count_reg[3] <= reference_clk_2;
        phase_count_reg[2] <= reference_clk_3;
        phase_count_reg[1] <= reference_clk_4;
        phase_count_reg[0] <= reference_clk_5;
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
            counter_read_buffer <= 0;
			bus_acknowledge <= 0;
        end
        if (we_i == 1 && stb_i == 1) begin 
            if (addr_i == 32'h8) begin
                //update control register according to the data supplied from dat_i
				counter_control_reg <= dat_i[7:0];           
				bus_acknowledge <= 1;
            end else begin            
                bus_acknowledge <= 0;
            end
        end else if (we_i == 0 && stb_i == 1) begin 
            //counter control register (0x08)
            if (addr_i == 32'h8) begin
                counter_read_buffer[7:0] <= counter_control_reg;
                counter_read_buffer[31:8] <= 24'd0;
                bus_acknowledge <= 1;
            //counter counter result register (0x09)
            end else if (addr_i == 32'h9) begin
                counter_read_buffer <= measurement_count_reg;
                bus_acknowledge <= 1;
            //counter phase begin - end register (0x0a)
            end else if (addr_i == 32'ha) begin
                counter_read_buffer <= phase_count_reg;
                bus_acknowledge <= 1;
            end else begin 
                counter_read_buffer <= 32'd0;
                bus_acknowledge <= 0;
            end
        end
    
        if (measurement_is_done == 1) begin 
            counter_control_reg[6] <= 1;
            counter_control_reg[7] <= 0;
        end else if (counter_control_reg[0] == 1) counter_control_reg <= 8'd0;
    end

    assign dat_o = counter_read_buffer;
    assign counter_reset_internal = counter_control_reg[0]; 
    assign counter_flags[1] = measurement_begin;
    assign counter_flags[0] = measurement_is_done;
	assign ack_o = bus_acknowledge;
endmodule  


//PR: 
// - working on the analysis of the FSM, whether it is capable of entering the unintended state or not
// - testing the behaviour of the module via simulation, for various condition
// - deciding whether the counter module is better to be separated futher as submodules or not