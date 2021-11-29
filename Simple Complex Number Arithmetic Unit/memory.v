`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2021 09:55:38 PM
// Design Name: 
// Module Name: memory
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


module memory(
    input wire clk, write, reset,
    input wire [9:0] data_in_A,
    input wire [9:0] data_in_B,
    input wire [4:0] address_A,
    input wire [4:0] address_B,
    output wire [9:0] data_out_A,
    output wire [9:0] data_out_B
    );
    
    reg [9:0] data_registers [0:31];  // MBR
    reg [4:0] address_register_A; // MAR  
    reg [4:0] address_register_B;  
    integer i;



    always @(posedge clk or negedge reset)
        begin
            if (!reset)
                begin
                    for (i = 0; i < 32; i = i + 1)
                        data_registers[i] <= 0;
                    address_register_A <= 0;
                    address_register_B <= 0;
                end
            else
                begin
                    if (write)
                        begin
                            data_registers[address_A] <= data_in_A;
                            data_registers[address_B] <= data_in_B;
                        end
                    address_register_A <= address_A;
                    address_register_B <= address_B;
                end
                
                
        end
        
        
        
        assign data_out_A[9:0] = data_registers[address_register_A][9:0];
        assign data_out_B[9:0] = data_registers[address_register_B][9:0];
                
endmodule
