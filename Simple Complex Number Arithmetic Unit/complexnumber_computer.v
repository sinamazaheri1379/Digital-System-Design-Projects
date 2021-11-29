`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/10/2021 10:05:35 PM
// Design Name: 
// Module Name: complexnumber_computer
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


module complexnumber_computer(
    input wire clk,
    input wire reset,
    input wire write,
    input wire [1:0] select,
    input wire [4:0] address_A,
    input wire [4:0] address_B,
    input wire signed [9:0] op_A,
    input wire signed [9:0] op_B,
    output wire signed [21:0] result,
    output wire overflow_imaginary,
    output wire overflow_real
    );
    
    wire [9:0] data_out_A, data_out_B, data_out_reg_A, data_out_reg_B;
    
    memory mem0(.address_A(address_A), .address_B(address_B), .data_in_A(op_A), .data_in_B(op_B), .data_out_A(data_out_A), .data_out_B(data_out_B), .clk(clk), .reset(reset), .write(write));    
    register register0(.clk(clk), .reset(reset), .data_in_A(data_out_A), .data_in_B(data_out_B), .data_out_A(data_out_reg_A), .data_out_B(data_out_reg_B));
    alu alu0(.op_A(data_out_reg_A), .op_B(data_out_reg_B), .select(select), .result(result), .overflow_imaginary(overflow_imaginary), .overflow_real(overflow_real));
    
endmodule
