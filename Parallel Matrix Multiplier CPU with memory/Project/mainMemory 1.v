`timescale 1ns / 1ps
module mainMemory(
input write_readBar,clk,reset,
input [31:0] data_in,
input [9:0] address,//1024*32
output [31:0] data_out
    );
    reg [31:0] memory [0:1023];
    integer i;
    reg [9:0] temp_address;
    always @(posedge clk, negedge reset)begin
        if(!reset)begin
            $readmemh("data.mem", memory);
            for(i=11;i<1024;i=i+1)begin
                memory[i]<=0;
            end
            temp_address <= 0;
        end
        else begin
            if(write_readBar)begin
               memory[address]<=data_in; 
            end
            temp_address<=address;    
        end
    end
    assign data_out=memory[temp_address];
endmodule
