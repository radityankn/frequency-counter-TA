module double_dabble (  input [31:0] input_number,
                        input clk_i,
                        input conversion_start,
                        output reg conversion_complete,
                        output reg [7:0] ones,
                        output reg [7:0] tens,
                        output reg [7:0] hundreds,
                        output reg [7:0] thousands,
                        output reg [7:0] ten_thousands,
                        output reg [7:0] hundred_thousands,
                        output reg [7:0] millions,
                        output reg [7:0] tenth_million,
                        output reg [7:0] hundred_millions,
                        output reg [7:0] billions
                        );

    reg [31:0] input_space_internal;
    reg shift_after_add;
    reg [39:0] scratch_space;
    reg [5:0] repetition;

    always @(posedge clk_i) begin
        if (conversion_start == 1'b0) begin 
            conversion_complete <= 1'b0;
            repetition <= 6'd0;
            scratch_space <= 32'd0;
            shift_after_add <= 1'b0;
        end else if (conversion_start == 1'b1) begin
            if (repetition == 6'd0) begin
                input_space_internal <= input_number;
                repetition <= repetition + 1'b1;
            end else if (repetition < 6'd33) begin 
                if ((scratch_space[31:28] > 4'd4 || scratch_space[27:24] > 4'd4 || scratch_space[23:20] > 4'd4 || scratch_space[19:16] > 4'd4 || scratch_space[15:12] > 4'd4 || scratch_space[11:8] > 4'd4 || scratch_space[7:4] > 4'd4 || scratch_space[3:0] > 4'd4) && shift_after_add == 1'b0) begin
                    //8th digit
                    if (scratch_space[31:28] > 4'd4) begin 
                        scratch_space[31:28] <= scratch_space[31:28] + 4'd3; 
                        shift_after_add <= 1'b1;
                    end else scratch_space[31:28] <= scratch_space[31:28];
                    //7th digit
                    if (scratch_space[27:24] > 4'd4) begin
                        scratch_space[27:24] <= scratch_space[27:24] + 4'd3;
                        shift_after_add <= 1'b1;
                    end else scratch_space[27:24] <= scratch_space[27:24];
                    //6th digit
                    if (scratch_space[23:20] > 4'd4) begin 
                        scratch_space[23:20] <= scratch_space[23:20] + 4'd3;
                        shift_after_add <= 1'b1;
                    end else scratch_space[23:20] <= scratch_space[23:20];
                    //5th digit
                    if (scratch_space[19:16] > 4'd4) begin 
                        scratch_space[19:16] <= scratch_space[19:16] + 4'd3;
                        shift_after_add <= 1'b1;
                    end else scratch_space[19:16] <= scratch_space[19:16];
                    //4th digit
                    if (scratch_space[15:12] > 4'd4) begin 
                        scratch_space[15:12] <= scratch_space[15:12] + 4'd3;
                        shift_after_add <= 1'b1;
                    end else scratch_space[15:12] <= scratch_space[15:12];
                    //3rd digit
                    if (scratch_space[11:8] > 4'd4) begin 
                        scratch_space[11:8] <= scratch_space[11:8] + 4'd3;
                        shift_after_add <= 1'b1;
                    end else scratch_space[11:8] <= scratch_space[11:8];
                    //2nd digit
                    if (scratch_space[7:4] > 4'd4) begin 
                        scratch_space[7:4] <= scratch_space[7:4] + 4'd3;
                        shift_after_add <= 1'b1;
                    end else scratch_space[7:4] <= scratch_space[7:4];
                    //1st digit
                    if (scratch_space[3:0] > 4'd4) begin 
                        scratch_space[3:0] <= scratch_space[3:0] + 4'd3;
                        shift_after_add <= 1'b1;
                    end else scratch_space[3:0] <= scratch_space[3:0];
                end
                else begin
                    scratch_space <= scratch_space << 1'b1;
                    scratch_space[0] <= input_space_internal[31];
                    input_space_internal <= input_space_internal << 1'b1;
                    repetition <= repetition + 1'b1;
                    shift_after_add <= 1'b0;
                end
            end else begin
                repetition <= repetition;
                conversion_complete <= 1'b1;
                ones <= scratch_space[3:0];
                tens <= scratch_space[7:4];
                hundreds <= scratch_space[11:8];
                thousands <= scratch_space[15:12];
                ten_thousands <= scratch_space[19:16];
                hundred_thousands <= scratch_space[23:20];
                millions <= scratch_space[27:24];
                tenth_million <= scratch_space[31:28];
                hundred_millions <= scratch_space[35:32];
                billions <= scratch_space[39:36];
            end
        end
    end

endmodule