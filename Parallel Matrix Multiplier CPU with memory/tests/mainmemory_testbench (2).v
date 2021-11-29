`include "mainmemory 1.v"
module mainmemory_testbench();
	reg write_readBar,clk,reset;
	reg [31:0] data_in;
	reg [9:0] address;
	wire [31:0] data_out;	
	mainMemory under_test(.write_readBar(write_readBar), .clk(clk), .reset(reset), .data_in(data_in), .address(address), .data_out(data_out));

	
	
	initial 
	begin
		clk = 1'b0;
		forever #5 clk = ~clk;
	end

	initial 
	begin

		reset = 1'b1;
		write_readBar = 1'b1;
		address = 16;
		data_in = 10;
		#10
		write_readBar = 1'b0;
		#10
		write_readBar = 1'b1;
		data_in = 50;
		#10
		write_readBar = 1'b0;
		#10
		reset = 1'b0;
		#10
		reset = 1'b1;
		#10
		write_readBar = 1'b1;
		address = 32;
		data_in = 100;
	end
		
endmodule