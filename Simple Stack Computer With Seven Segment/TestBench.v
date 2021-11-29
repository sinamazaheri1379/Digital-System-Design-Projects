module TestBench();
	reg clk, reset, write;
	reg [7:0] Data_in;
	
	wire [7:0] stack_in;
	wire [7:0] top;
	wire [11:0] inst;
	wire [6:0] Digit0, Digit1, Digit2;
	wire Error;
	wire push, pop;
	
	BasicCPU myCPU(clk, reset, write, Data_in, Error, Digit0, Digit1, Digit2, stack_in, top, inst, push, pop);
	
	initial begin
		clk = 0;
		reset = 1;
		Data_in = 2;
		write = 1;
		#10
		reset = 0;
		write = 0;
		#10
		write = 0;
		#300
		$stop;
	end
	
	always #5 clk = ~clk;
endmodule