`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2021 08:17:02 PM
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
    reg clk, reset, seed_value;
    reg [8:1] load_seed;
    wire [8:1] output_value;
    
    
    lfsr #(8) lfsr0(.reset(reset), .clk(clk), .output_value(output_value), .seed_value(load_seed), .load_seed(seed_value));
    
    initial
        begin
            clk = 1'b0;
            forever #5 clk = ~clk;
        end
     
     
     
     initial
        begin
            load_seed = $urandom($time);
            seed_value = 1'b0;
            reset = 1'b0;
            #2 reset = 1'b1;
               seed_value = 1'b1;
            #4 seed_value = 1'b0;
            
        end
        
    initial
        $monitor($time, " ns feedback = %b,  lfsr_reg = %b,  lfsr_out = %b", output_value[8], output_value, output_value[1]);
        
        
     
endmodule
