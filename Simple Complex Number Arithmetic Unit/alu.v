`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/10/2021 11:27:49 AM
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu(
    input wire  [9:0] op_A,
    input wire  [9:0] op_B,
    input wire [1:0] select,   
    output reg  [21:0] result,
    output wire overflow_imaginary,
    output wire overflow_real
    );
    
    wire [9:0] result_adder_subtractor;
    wire [1:0] carry_out_result_adder, carry_out_result_multiplier;
    wire [19:0] result_multiplier;
    wire overflow_adder_sub_imaginary, overflow_adder_sub_real, overflow_multiply_imaginary, overflow_multiply_real;
    wire sign_bit_low, sign_bit_high;
    adder_subtractor addsub0(.op_A(op_A), .op_B(op_B), .select(select[0]), .result(result_adder_subtractor), .carry_out(carry_out_result_adder), .overflow_imaginary(overflow_adder_sub_imaginary), .overflow_real(overflow_adder_sub_real));
    multiplier mul0(.op_A(op_A), .op_B(op_B), .result(result_multiplier), .overflow_imaginary(overflow_multiply_imaginary), .overflow_real(overflow_multiply_real) ,.carry_out(carry_out_result_multiplier));
    assign sign_bit_low = result_adder_subtractor[4];
    assign sign_bit_high = result_adder_subtractor[9];
    assign overflow_real = (select[1]) ? overflow_multiply_real:overflow_adder_sub_real;
    assign overflow_imaginary = (select[1]) ? overflow_multiply_imaginary:overflow_adder_sub_imaginary;
     always @(*)
        begin
            result = 21'b0;
            case(select[1])
                1'b0:
                    begin
                        if (!overflow_adder_sub_imaginary && !overflow_adder_sub_real)
                            begin
                                {result[15:11], result[4:0]} = {result_adder_subtractor[9:5], result_adder_subtractor[4:0]};
                                {result[21:16], result[10:5]} = {sign_bit_high, sign_bit_high, sign_bit_high, sign_bit_high, sign_bit_high, sign_bit_high, sign_bit_low, sign_bit_low, sign_bit_low, sign_bit_low, sign_bit_low, sign_bit_low};
                            end
                        else if (overflow_adder_sub_imaginary && !overflow_adder_sub_real)
                             begin
                                 {result[15:11], result[4:0]} = {result_adder_subtractor[9:5], result_adder_subtractor[4:0]};
                                 {result[21:16], result[10:5]} = {sign_bit_high, sign_bit_high, sign_bit_high, sign_bit_high, sign_bit_high, sign_bit_high, carry_out_result_adder[0], carry_out_result_adder[0], carry_out_result_adder[0], carry_out_result_adder[0], carry_out_result_adder[0], carry_out_result_adder[0]};                           
                             end
                        else if (!overflow_adder_sub_imaginary && overflow_adder_sub_real)
                             begin
                                {result[15:11], result[4:0]} = {result_adder_subtractor[9:5], result_adder_subtractor[4:0]};
                                {result[21:16], result[10:5]} = {carry_out_result_adder[1], carry_out_result_adder[1], carry_out_result_adder[1], carry_out_result_adder[1], carry_out_result_adder[1], carry_out_result_adder[1], sign_bit_low, sign_bit_low, sign_bit_low, sign_bit_low, sign_bit_low, sign_bit_low};
                             end
                        else
                            begin
                               {result[15:11], result[4:0]} = {result_adder_subtractor[9:5], result_adder_subtractor[4:0]};
                               {result[21:16], result[10:5]} = {carry_out_result_adder[1], carry_out_result_adder[1], carry_out_result_adder[1], carry_out_result_adder[1], carry_out_result_adder[1], carry_out_result_adder[1],  carry_out_result_adder[0],  carry_out_result_adder[0],  carry_out_result_adder[0],  carry_out_result_adder[0],  carry_out_result_adder[0],  carry_out_result_adder[0]};
                            end
                    end
                1'b1:
                    begin
                        if (!overflow_multiply_imaginary && !overflow_multiply_real)
                            begin
                                {result[20:11], result[9:0]} = {result_multiplier[19:10], result_multiplier[9:0]};
                                {result[21], result[10]} = {result_multiplier[19], result_multiplier[9]};
                            end
                        else if (overflow_multiply_imaginary && !overflow_multiply_real)
                             begin
                                {result[20:11], result[9:0]} = {result_multiplier[19:10], result_multiplier[9:0]};
                                {result[21], result[10]} = {result_multiplier[19], carry_out_result_multiplier[0]};
                             end
                        else if (!overflow_multiply_imaginary && overflow_multiply_real)
                             begin
                               {result[20:11], result[9:0]} = {result_multiplier[19:10], result_multiplier[9:0]};
                                {result[21], result[10]} = {carry_out_result_multiplier[1], result_multiplier[9]};
                             end
                        else
                            begin
                              {result[20:11], result[9:0]} = {result_multiplier[19:10], result_multiplier[9:0]};
                                {result[21], result[10]} = {carry_out_result_multiplier[1], carry_out_result_multiplier[0]};
                            end
                    end         
                default: result = 21'bz;
            endcase
        end
    
endmodule


module adder_subtractor(
    input wire [9:0] op_A,
    input wire [9:0] op_B,
    input wire select,
    output wire [9:0] result,
    output wire [1:0] carry_out,
    output wire overflow_imaginary,
    output wire overflow_real
    );
    wire [4:0] complement_B_imaginary,complement_B_real, final_real, final_imaginary;
    assign complement_B_imaginary = ~op_B[4:0] + 1'b1;
    assign complement_B_real = ~op_B[9:5] + 1'b1;
    assign final_real = (select) ? complement_B_real:op_B[9:5];
    assign final_imaginary = (select) ? complement_B_imaginary:op_B[4:0];
    assign result[4:0] = (select) ? op_A[4:0] + complement_B_imaginary : op_A[4:0] + op_B[4:0];
    assign result[9:5] = (select) ? op_A[9:5] + complement_B_real : op_A[9:5] + op_B[9:5];
    assign overflow_imaginary = result[4] & ~op_A[4] & ~final_imaginary[4] | ~result[4] & op_A[4] & final_imaginary[4]; 
    assign overflow_real = result[9] & ~op_A[9] & ~final_real[4] | ~result[9] & op_A[9] & final_real[4]; 
    assign carry_out[0] = (op_A[4] & final_imaginary[4]) | ((op_A[3] & final_imaginary[3]) | ((op_A[2] & final_imaginary[2]) | ((op_A[1] & final_imaginary[1]) | (op_A[0] & final_imaginary[0]) & (op_A[1] ^ final_imaginary[1])) & (op_A[2] ^ final_imaginary[2])) & (op_A[3] ^ final_imaginary[3])) & (op_A[4] ^ final_imaginary[4]);
    assign carry_out[1] = (op_A[9] & final_real[4]) | ((op_A[8] & final_real[3]) | ((op_A[7] & final_real[2]) | ((op_A[6] & final_real[1]) | (op_A[5] & final_real[0]) & (op_A[6] ^ final_real[1])) & (op_A[7] ^ final_real[2])) & (op_A[8] ^ final_real[3])) & (op_A[9] ^ final_real[4]);  
endmodule


module multiplier(                                                                                                                                                                                                                                                                                               
    input wire [9:0] op_A,
    input wire [9:0] op_B,
    output wire [1:0] carry_out,
    output wire [19:0] result,
    output wire overflow_imaginary,
    output wire overflow_real
    );
    
    wire signed [9:0] temp_imaginary_1, temp_imaginary_2, temp_real_1, temp_real_2, temp_sub;
    assign temp_imaginary_1 = $signed(op_A[9:5]) * $signed(op_B[4:0]);
    assign temp_imaginary_2 = $signed(op_A[4:0]) * $signed(op_B[9:5]);
    assign temp_real_1 = $signed(op_A[9:5]) * $signed(op_B[9:5]);
    assign temp_real_2 = $signed(op_A[4:0]) * $signed(op_B[4:0]);
    assign  result[9:0] = temp_imaginary_1 + temp_imaginary_2;
    assign  result[19:10] = temp_real_1 + temp_sub;
    assign overflow_imaginary = result[9] & ~temp_imaginary_1[9] & ~temp_imaginary_2[9] | ~result[9] & temp_imaginary_1[9] & temp_imaginary_2[9]; 
    assign overflow_real = result[19] & ~temp_real_1[9] & ~temp_sub[9] | ~result[19] & temp_real_1[9] & temp_sub[9]; 
    assign temp_sub = ~temp_real_2 + 1'b1;
    assign carry_out[0] = (temp_imaginary_1[9] & temp_imaginary_2[9]) | ((temp_imaginary_1[8] & temp_imaginary_2[8]) | ((temp_imaginary_1[7] & temp_imaginary_2[7]) | ((temp_imaginary_1[6] & temp_imaginary_2[6]) | ((temp_imaginary_1[5] & temp_imaginary_2[5]) | ((temp_imaginary_1[4] & temp_imaginary_2[4]) | ((temp_imaginary_1[3] & temp_imaginary_2[3]) | ((temp_imaginary_1[2] & temp_imaginary_2[2]) | ((temp_imaginary_1[1] & temp_imaginary_2[1]) | (temp_imaginary_1[0] & temp_imaginary_2[0]) & (temp_imaginary_1[1] ^ temp_imaginary_2[1])) & (temp_imaginary_1[2] ^ temp_imaginary_2[2])) & (temp_imaginary_1[3] ^ temp_imaginary_2[3])) & (temp_imaginary_1[4] ^ temp_imaginary_2[4])) & (temp_imaginary_1[5] ^ temp_imaginary_2[5])) & (temp_imaginary_1[6] ^ temp_imaginary_2[6])) & (temp_imaginary_1[7] ^ temp_imaginary_2[7])) & (temp_imaginary_1[8] ^ temp_imaginary_2[8])) & (temp_imaginary_1[9] ^ temp_imaginary_2[9]);
    assign carry_out[1] = (temp_real_1[9] & temp_sub[9]) | ((temp_real_1[8] & temp_sub[8]) | ((temp_real_1[7] & temp_sub[7]) | ((temp_real_1[6] & temp_sub[6]) | ((temp_real_1[5] & temp_sub[5]) | ((temp_real_1[4] & temp_sub[4]) | ((temp_real_1[3] & temp_sub[3]) | ((temp_real_1[2] & temp_sub[2]) | ((temp_real_1[1] & temp_sub[1]) | (temp_real_1[0] & temp_sub[0]) & (temp_real_1[1] ^ temp_sub[1])) & (temp_real_1[2] ^ temp_sub[2])) & (temp_real_1[3] ^ temp_sub[3])) & (temp_real_1[4] ^ temp_sub[4])) & (temp_real_1[5] ^ temp_sub[5])) & (temp_real_1[6] ^ temp_sub[6])) & (temp_real_1[7] ^ temp_sub[7])) & (temp_real_1[8] ^ temp_sub[8])) & (temp_real_1[9] ^ temp_sub[9]);
endmodule
