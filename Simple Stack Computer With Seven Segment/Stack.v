module Stack(reset_not,din,Push,Pop,dout,full,empty, T);
	input reset_not, Push, Pop;
	input [7:0] din;
	output reg [7:0] dout;
	output full, empty;
	output wire [7:0] T;
	
	reg [31:0] top;
	reg [7:0] mem[7:0];
	integer i;
	assign T = top;
	always @(Push, Pop, negedge reset_not) begin
		if(!reset_not)begin
			for(i = 0; i < 8; i = i + 1) begin
				mem[i] <= 0;
			end
			dout <= 0;
			top <= 0;
		end else begin
			case({Push, Pop})
				2'b10:begin
					if(!full) begin
						mem[top] <= din;
						top <= top+1;
					end
				end
				2'b01:begin
					if(!empty)begin
						dout <= mem[top-1];
						top <= top-1;
					end
				end
			endcase
		end
	end
	
	assign full = (top == 8);
	assign empty = (top == 0);
endmodule