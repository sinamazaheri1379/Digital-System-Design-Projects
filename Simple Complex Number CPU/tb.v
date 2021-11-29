`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/11/2021 12:13:28 PM
// Design Name: 
// Module Name: tb
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


module tb(

    );
    
    reg [9:0] op_A, op_B;
    reg clk, reset, write;
    reg [1:0] select;
    reg [4:0] address_A, address_B;
    wire [21:0] result;
    wire overflow_imaginary, overflow_real;
    
    complexnumber_computer comp0(.clk(clk), .write(write), .reset(reset), .select(select), .op_A(op_A), .op_B(op_B), .address_A(address_A), .address_B(address_B), .result(result), .overflow_imaginary(overflow_imaginary), .overflow_real(overflow_real));
    
    initial 
        begin
            reset = 1'b0;
            clk = 1'b0;
            forever #5 clk = ~clk;
        end
     
     
     
    initial
        begin
               write = 1'b1;
               select = 2'b00;
               address_A = 4'b0010;
               address_B = 4'b0011;
               op_A = 10'b01001_10011; // 9 - 13i
               op_B = 10'b00100_00110; // 4 + 6i            
               #1; // t = 1ns
               reset = 1'b1;
               #5; // t = 6ns
               address_A = 4'b0100;
               address_B = 4'b0101;
               op_A = 10'b01101_11011; // 13 - 5i
               op_B = 10'b11101_11011; // -3 -5i
               #50; // t = 16ns
               write = 1'b0;
               select = 2'b01;
               address_A = 4'b0010;
               address_B = 4'b0011;
               #50;
               address_A = 4'b0100;
               address_B = 4'b0101;
               #50;
               select = 2'b11;
               address_A = 4'b0010;
               address_B = 4'b0011;
               #50;
               address_A = 4'b0100;
               address_B = 4'b0101;
       end
    
    
    
    
    
    
    
    
    
    
    
    
    
endmodule
