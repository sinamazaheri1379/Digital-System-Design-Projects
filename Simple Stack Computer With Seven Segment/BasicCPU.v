module BasicCPU(Clock, reset, write ,din, err, digit_0, digit_1, digit_2, stack_input, T, inst, push, pop);
	
	
	output [6:0] digit_0, digit_1, digit_2;
	output wire err;
	output reg [7:0] stack_input;
	output wire [7:0] T;
	output wire [11:0] inst;
	output push, pop;
	input Clock, reset, write;
	input [7:0] din;
	
	reg [11:0] ram [255:0];
	reg [11:0] IR;
	reg [7:0] PC, A, B, result;
	reg push, pop, S, Z;
	reg T0, T1, T2, T3, T4;
	wire full, empty, reset_not;
	wire [7:0] stack_out;
	wire [3:0] d0, d1, d2;
	
	integer i;
	BCD bcd(stack_input,d2, d1, d0);
	Stack stack(reset_not, stack_input, push, pop, stack_out, full, empty, T);
	SevenSegment s0(digit_0, d0), s1(digit_1, d1), s2(digit_2, d2);

	
	assign inst = ram[PC];
	assign reset_not = ~reset;
	assign err = (stack_input >127) || (stack_input[7] == 1);
	always @(posedge Clock, posedge reset) begin
		if(reset) begin
			ram[0] <= 12'b_0000_00010111;	//push constant 23
			ram[1] <= 12'b_0001_11111111;	//push input data (saved in FF) to stack
			ram[2] <= 12'b_0110_00000000;	//add 
			ram[3] <= 12'b_0110_00000000;	//add again (multiply 2)
			ram[4] <= 12'b_0010_00000000;	//save to memory
			ram[5] <= 12'b_0000_00001100;	//push constant 12
			ram[6] <= 12'b_0001_00000000;	//load saved number
			ram[7] <= 12'b_0111_00000000;	//subtract
			for(i = 8; i < 8'hFF; i = i+1)
				ram[i] <= 12'hF_00;
			ram[255] <= (write)? {4'b0, din} : 12'b_1111_00000101;
			
			T0 <= 1;  //first clock
			T1 <= 0;  //second clock
			T2 <= 0;  //third clock
			T3 <= 0;  //fourth clock
			T4 <= 0;  //fifth clock
			
			S <= 0;  //sign flag
			Z <= 0;		//zero flag
			PC <= 0;
			IR <= ram[0];
			stack_input <= 0;
		end else begin
				case(IR[11:8])
					4'b0000: begin	//push constant
						pop <= 0;
						push <= 1;
						stack_input <= IR[7:0];
						IR <= ram[PC+1];
						PC <= PC+1;
					end
					4'b0001: begin //push from memory
						if(T0) begin
						    push <= 0;
						    pop <= 0;
							stack_input <= ram[IR[7:0]];
							T0 <= 0;
							T1 <= 1;
						end else if (T1) begin
                            push <= 1;
                            pop <= 0;
							IR <= ram[PC+1];
							PC <= PC+1;
							T0 <= 1;
							T1 <= 0;
						end
					end
					4'b0010: begin //pop to memory
						if(T0) begin
							pop <= 1;
							push <= 0;
							T0 <= 0;
							T1 <= 1;
						end else if (T1)begin
						    push <= 0;
						    pop <= 0;
                            ram[IR[7:0]] <= stack_out;
							T0 <= 1;
							T1 <= 0;
							IR <= ram[PC+1];
							PC <= PC+1;	
						end 
					end
					4'b0011: begin //jump
						if(T0) begin
							pop <= 1;
							push <= 0;
							T0 <= 0;
							T1 <= 1;
						end else if (T1)begin
						    push <= 0;
						    pop <= 0;
                            PC <= stack_out;
							T0 <= 1;
							T1 <= 0;
							IR <= ram[PC+1];
							PC <= PC+1;
						end 
					end
					4'b0100: begin //jump if zero
						if(Z)begin
							if(T0) begin
								pop <= 1;
								push <= 0;
								T0 <= 0;
								T1 <= 1;
							end else if (T1)begin
    							push <= 0;
	       					    pop <= 0;
								PC <= stack_out;
								T0 <= 1;
								T1 <= 0;
								IR <= ram[PC+1];
								PC <= PC+1;
							end 
						end else begin
							pop <= 0;
							push <= 0;
							IR <= ram[PC+1];
							PC <= PC+1;
						end
					end
					4'b0101: begin //jump if negative
						if(S)begin
							if(T0) begin
								pop <= 1;
								push <= 0;
								T0 <= 0;
								T1 <= 1;
							end else if (T1)begin
							    push <= 0;
						        pop <= 0;
								PC <= stack_out;
								T0 <= 1;
								T1 <= 0;
								IR <= ram[PC+1];
								PC <= PC+1;
							end 
						end else begin
							pop <= 0;
							push <= 0;
							IR <= ram[PC+1];
							PC <= PC+1;
						end
					end
					4'b0110: begin //add 
						if(T0) begin
							pop <= 1;
							push <= 0;
							T0 <= 0;
							T1 <= 1;
						end else if (T1)begin
						    push <= 0;
						    pop <= 0;
						    A <= stack_out;
							T1 <= 0;
							T2<= 1;
						end else if (T2) begin
						    pop <= 1;
							push <= 0;
							T2 <= 0;
							T3<= 1;
						end else if(T3) begin
						    push <= 0;
						    pop <= 0;
						    B <= stack_out;
							T3 <= 0;
							T4 <= 1;
						end else if (T4) begin
							pop <= 0;
							push <= 0;
							stack_input <= A+B;
							T4 = 0;
						end 
						else begin
						    push = 1;
						    pop = 0;
							T0 <= 1;
							if((A+B) == 0)
								Z <= 1;
							else
								Z <= 0;
							if((A+B) < 0)
								S <= 1;
							else
								S <= 0;
							IR <= ram[PC+1];
							PC <= PC+1;
						end
					end
					
					4'b0111: begin //sub
							if(T0) begin
							pop <= 1;
							push <= 0;
							T0 <= 0;
							T1 <= 1;
						end else if (T1)begin
						    push <= 0;
						    pop <= 0;
						    A <= stack_out;
							T1 <= 0;
							T2<= 1;
						end else if (T2) begin
						    pop <= 1;
							push <= 0;
							T2 <= 0;
							T3<= 1;
						end else if(T3) begin
						    push <= 0;
						    pop <= 0;
						    B <= stack_out;
							T3 <= 0;
							T4 <= 1;
						end else if (T4) begin
							pop <= 0;
							push <= 0;
							stack_input <= A - B;
							T4 = 0;
						end 
						else begin
						    push = 1;
						    pop = 0;
							T0 <= 1;
							if((A+B) == 0)
								Z <= 1;
							else
								Z <= 0;
							if((A+B) < 0)
								S <= 1;
							else
								S <= 0;
							IR <= ram[PC+1];
							PC <= PC+1;
						end
					
					end
				endcase
				
			end
	end

endmodule
