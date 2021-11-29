`include "cellcalc.v"
module cellcalc_testbench();
 	
	parameter common_factor = 1;
	reg [130*common_factor-1:0] matrix_A,matrix_B;
	reg a_stb,b_stb,a_ack,b_ack,z_ack,load_fp,load_2by2,result_ack,result_ack_2by2;
	wire z_stb2,result_ready,result_ready_2by;
	reg reset,clk;
	reg [$clog2(common_factor)-1:0] select_matrix;
	reg [1:0] select_A_2by2;
	reg [1:0] select_B_2by2;
	reg [1:0] select_demux;
	wire [129:0] cell_out;
	
	cellcalc #(.common_factor(2))under_test(.matrixA(matrixA), .matrixB(matrixB), .a_stb(a_stb), .b_stb(b_stb), 
	.z_stb(z_stb), .a_ack(a_ack), .b_ack(b_ack), .z_ack(z_ack), .load_fp(load_fp), 
	.load_2by2(load_2by2), .result_ack(result_ack), .result_ack_2by2(result_ack_2by), 
	.result_ready(result_ready), .result_ready_2by2(result_ready_2by2), .reset(reset), .clk(clk), 
	.select_A_2by2(select_A_2by2), .select_B_2by2(select_B_2by2), .select_demux(select_demux), .cell_out(cell_out));
	
	initial 
	begin
		clk = 1'b0;
		forever #5 clk = ~clk;
	end
	
	initial
	begin
		reset = 1'b1;
		a_stb = 1'b1;
		b_stb = 1'b1;
		load_fp = 1'b1;
		select_matrix = 0;
		select_A_2by2 = 0;
		select_B_2by2 = 0;
		matrix_A = 130'h40A0000000000000000000000000000000;
		matrix_B = 130'h4040000000000000000000000000000000;
		select_demux = 0;

	end

		

endmodule
