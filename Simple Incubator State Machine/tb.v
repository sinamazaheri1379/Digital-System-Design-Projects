`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2021 06:56:52 PM
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


module tb();
    reg clk, reset;
    reg [7:0] T;
    wire Cooler, Heater;
    wire [7:0] CRS;
    
    incubator incubator_test(
        .clk(clk),
        .reset(reset),
        .T(T),
        .Cooler(Cooler),
        .Heater(Heater),
        .CRS(CRS)
    );
    
    initial
    begin
        reset = 0;
        clk = 0;
        forever #10 clk = ~clk;
    end
    
    
    initial
    begin
        #5 reset = 1;
        #20 T = 10;
        #35 T = 60;
        #100 T = 18;
        #120 
        $finish;
                
    end
    initial
        $monitor("time=%d T=%d Cooler=%d Heater=%d CRS=%d ", $time, T, Cooler, Heater, CRS);
   
endmodule
