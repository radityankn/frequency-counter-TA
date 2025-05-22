`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:45:47 02/20/2025 
// Design Name: 
// Module Name:    ALU 
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
module ALU(
    input ext_rst_i,
    input rst_i,
    input clk_i,
    //input sign_flag,
    input carry_in_flag,
    input borrow_in_flag,
    input rotate_shift,
    input [31:0] operand_a,
    input [31:0] operand_b,
    input [4:0] selector,
    output [31:0] result,
    output carry_out_flag,
    output borrow_out_flag
    //output overflow_flag
    ); 

    wire [31:0] result_adder;
    wire [31:0] result_substract;
    wire [31:0] result_and;
    wire [31:0] result_or;
    wire [31:0] result_complement;
    wire [31:0] result_xor;
    wire [31:0] result_shift_left;
    wire [31:0] result_shift_right;

    full_scale_adder adder_one( .operand_a(operand_a), 
                                .operand_b(operand_b),
                                .carry_in(carry_in_flag),
                                .carry_out(carry_out_flag),
                                .result(result_adder)
    );

    full_scale_subtract subtract_one( .operand_a(operand_a), 
                                .operand_b(operand_b),
                                .borrow_in(borrow_in_flag),
                                .borrow_out(carry_out_flag),
                                .result(result_substract)
    );

    bit_shift_left shifter_left_one(.operand_a(operand_a),
                                    .rotate(rotate_shift),
                                    .result(result_shift_left)
    );

    bit_shift_right shifter_right_one(  .operand_a(operand_a),
                                        .rotate(rotate_shift),
                                        .result(result_shift_right)
    );

    bitwise_and and_one(.operand_a(operand_a), 
                        .operand_b(operand_b),
                        .result(result_and)
    );

    bitwise_or or_one(.operand_a(operand_a), 
                        .operand_b(operand_b),
                        .result(result_and)
    );

    bitwise_xor xor_one(.operand_a(operand_a), 
                        .operand_b(operand_b),
                        .result(result_and)
    );

    complement_op complement_one(.operand_a(operand_a), 
                        .result(result_and)
    );

    /*
    always @(*) begin
        case (selector)
            //add
            5'd0 : begin
                assign result = 
            end
            //substract
            5'd1 : begin
            end
            //bit shift right
            5'd2 : begin
            end
            //bit shift left
            5'd3 : begin
            end
            //and
            5'd4 : begin
            end
            //or
            5'd5 : begin
            end
            //not
            5'd6 : begin
            end
            //compare more to
            5'd7 : begin
            end
            //compare less to
            5'd8 : begin
            end
            //equal to
            5'd9 : begin
            end
            //not equal to
            5'd10 : begin
            end
            //multiply
            5'd11 : begin
            end
            //divide
            5'd12 : begin
            end

        endcase
    end
*/   

endmodule

module full_scale_adder (
    input [31:0] operand_a,
    input [31:0] operand_b,
    input carry_in,
    output carry_out,
    output [31:0] result
);

    assign result = operand_a + operand_b + carry_in;
    assign carry_out = (operand_a & operand_b) & carry_in;

endmodule

module full_scale_subtract (
    input [31:0] operand_a,
    input [31:0] operand_b,
    input borrow_in,
    output borrow_out,
    output [31:0] result
);

    assign result = operand_a - operand_b - borrow_in;
    assign borrow_out = (operand_a & (operand_b & (~borrow_in + borrow_in) | (~operand_b & borrow_in))) | (borrow_in & operand_a & operand_b);

endmodule

/*
module single_bit_adder (
    input operand_a,
    input operand_b,
    input carry_in,
    output carry_out,
    output result
);

    assign result = (operand_a & ((operand_b & carry_in) | (~operand_b & ~carry_in))) | (~operand_a & ((~operand_b & carry_in) | (operand_b & ~carry_in)));
    assign carry_out = (operand_a & ((~operand_b & ~carry_in) | (operand_b & carry_in))) | (carry_in & ((operand_a & ~operand_b) | (~operand_a & operand_b)));

endmodule

module full_scale_adder (
    input [31:0] operand_a,
    input [31:0] operand_b,
    input carry_in,
    output carry_out,
    output [31:0] result
);

    single_bit_adder adder1 (.operand_a(operand_a[0]), .operand_b(operand_b[0]), .carry_in(carry_in), .carry_out(carry_out));
    single_bit_adder adder2 ();
    single_bit_adder adder3 ();
    single_bit_adder adder4 ();
    single_bit_adder adder5 ();
    single_bit_adder adder6 ();
    single_bit_adder adder7 ();
    single_bit_adder adder8 ();
    single_bit_adder adder9 ();
    single_bit_adder adder10 ();
    single_bit_adder adder11 ();
    single_bit_adder adder12 ();
    single_bit_adder adder13 ();
    single_bit_adder adder14 ();
    single_bit_adder adder15 ();
    single_bit_adder adder16 ();
    single_bit_adder adder17 ();
    single_bit_adder adder18 ();
    single_bit_adder adder19 ();
    single_bit_adder adder20 ();
    single_bit_adder adder21 ();
    single_bit_adder adder22 ();
    single_bit_adder adder23 ();
    single_bit_adder adder24 ();
    single_bit_adder adder25 ();
    single_bit_adder adder26 ();
    single_bit_adder adder27 ();
    single_bit_adder adder28 ();
    single_bit_adder adder29 ();
    single_bit_adder adder30 ();
    single_bit_adder adder31 ();
    single_bit_adder adder32 ();

endmodule

module single_bit_substract (
    input operand_a,
    input operand_b,
    input borrow_in,
    output borrow_out,
    output result
);

    assign result = (operand_a & ((~operand_b & ~borrow_in) | (~operand_b & borrow_in))) | (~operand_a & ((operand_b & ~borrow_in) | (~operand_b & borrow_in)));
    assign borrow_out = (operand_a & (operand_b & (~borrow_in + borrow_in) | (~operand_b & borrow_in))) | (borrow_in & operand_a & operand_b);

endmodule

*/

module bit_shift_right (
    input [31:0] operand_a,
    input rotate,
    output [31:0] result
);
    assign result[31:1] = operand_a[30:0];
    assign result[0] = rotate & operand_a[31];

endmodule

module bit_shift_left (
    input [31:0] operand_a,
    input rotate,
    output [31:0] result
);
    assign result[30:0] = operand_a[31:1];
    assign result[31] = rotate & operand_a[0];

endmodule

module bitwise_and (
    input [31:0] operand_a,
    input [31:0] operand_b,
    output [31:0] result
);
    assign result = operand_a & operand_b;

endmodule

module bitwise_or (
    input [31:0] operand_a,
    input [31:0] operand_b,
    output [31:0] result
);
    assign result = operand_a | operand_b;

endmodule

module complement_op (
    input [31:0] operand_a,
    output [31:0] result
);
    assign result = ~operand_a;

endmodule

module bitwise_xor (
    input [31:0] operand_a,
    input [31:0] operand_b,
    output [31:0] result
);
    assign result = operand_a ^ operand_b;

endmodule

/*
module compare_op (
    input [31:0] operand_a,
    input [31:0] operand_b
    input [1:0] mode,
    output result,
);
    always @(*) begin
    case (mode)
        //more than 
        2'd0 : begin
            if (operand_a > operand_b) result = 1'b1;
            else result = 1'b0;
        end
        //less than
        2'd1 : begin
            if (operand_a < operand_b) result = 1'b1;
            else result = 1'b0;
        end
        //equals to
        2'd2 : begin
            if (operand_a == operand_b) result = 1'b1;
            else result = 1'b0;
        end
        //not equal to
        2'd3 : begin
            if (operand_a != operand_b) result = 1'b1;
            else result = 1'b0;
        end
    endcase
    end
endmodule
*/