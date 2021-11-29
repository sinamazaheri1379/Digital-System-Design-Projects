module SevenSegment(ssOut, nIn);
	output reg [6:0] ssOut;
	input [3:0] nIn;

	always @(nIn)
		case (nIn)
			4'h0: ssOut = 7'b1000000;
			4'h1: ssOut = 7'b1111001;
			4'h2: ssOut = 7'b0100100;
			4'h3: ssOut = 7'b0110000;
			4'h4: ssOut = 7'b0011001;
			4'h5: ssOut = 7'b0010010;
			4'h6: ssOut = 7'b0000010;
			4'h7: ssOut = 7'b1111000;
			4'h8: ssOut = 7'b0000000;
			4'h9: ssOut = 7'b0011000;
			4'hA: ssOut = 7'b0001000;
			4'hB: ssOut = 7'b0000011;
			4'hC: ssOut = 7'b1000110;
			4'hD: ssOut = 7'b0100001;
			4'hE: ssOut = 7'b0000110;
			default: ssOut = 7'b0110110;
    endcase
endmodule
