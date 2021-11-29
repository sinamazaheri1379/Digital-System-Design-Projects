`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/12/2021 12:41:05 PM
// Design Name: 
// Module Name: register
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


module register(
    input wire [9:0] data_in_A,
    input wire [9:0] data_in_B,
    input wire clk,
    input wire reset,
    output wire [9:0] data_out_A,
    output wire [9:0] data_out_B
    );
    
    reg [9:0] register_A, register_B;
    assign data_out_A = register_A;
    assign data_out_B = register_B;
    
    always @(posedge clk or negedge reset)
        begin
            if (!reset)
                begin
                    register_A <= 0;
                    register_B <= 0;
                end
            else
                begin
                    register_A <= data_in_A;
                    register_B <= data_in_B;
                end
        end 
    
    
    
    
    
    
endmodule
