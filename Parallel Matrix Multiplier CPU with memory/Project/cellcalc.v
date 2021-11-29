`timescale 1ns / 1ps

module cellcalc #(parameter common_factor=8)(
input fp_2by2_ready,
input [130*common_factor-1:0] matrix_A,matrix_B,
input reset_FP_Out,
input a_stb,b_stb,load_fp,load_2by2,result_ack,result_ack_2by2,
input reset,clk,
input [31:0] select_matrix,
input [1:0] select_A_2by2, 
input [1:0] select_B_2by2,
input [1:0] select_demux,
input cell_ready,enable_decoder,
output reg [129:0] cell_out,
output wire a_ack,b_ack,z_ack,result_ready,result_ready_2by2,z_stb
      );
    wire [31:0] mux_A_2by2;
    wire [31:0] mux_B_2by2;
    reg [129:0] mux_A;
    reg [129:0] mux_B;
    wire [31:0] mult_out;
    reg [31:0] ff_out;
    reg [31:0] ff11_out;
    reg [31:0] ff12_out;
    reg [31:0] ff21_out;
    reg [31:0] ff22_out;
    wire [31:0] adder_num2_in;
    wire [31:0] adder11_num2_in;
    wire [31:0] adder12_num2_in;
    wire [31:0] adder21_num2_in;
    wire [31:0] adder22_num2_in;
    wire [31:0] adder_out;
    wire [31:0] adder11_out;
    wire [31:0] adder12_out;
    wire [31:0] adder21_out;
    wire [31:0] adder22_out;
    reg [31:0] c_1_1;
    reg [31:0] c_1_2;
    reg [31:0] c_2_1;
    reg [31:0] c_2_2;
    
    
    assign adder_num2_in = ff_out;
    assign adder11_num2_in = ff11_out;
    assign adder12_num2_in = ff12_out;
    assign adder21_num2_in = ff21_out;
    assign adder22_num2_in = ff22_out;
    assign mux_A_2by2=select_A_2by2[1] ? (select_A_2by2[0] ? mux_A[127:96] : mux_A[95:64]) : (select_A_2by2[0] ? mux_A[63:32] : mux_A[31:0]);
    assign mux_B_2by2=select_B_2by2[1] ? (select_B_2by2[0] ? mux_B[127:96] : mux_B[95:64]) : (select_B_2by2[0] ? mux_B[63:32] : mux_B[31:0]);
    
    single_multiplier single_mult(.input_a(mux_A_2by2),.input_b(mux_B_2by2),.input_a_stb(a_stb),.input_b_stb(b_stb),.rst(reset),.clk(clk),.input_a_ack(a_ack),.input_b_ack(b_ack),.output_z(mult_out),.output_z_stb(z_stb),.output_z_ack(z_ack));
    adder fp_adder(.clk(clk),.reset(reset),.load(load_fp),.result_ack(result_ack),.Result(adder_out),.result_ready(result_ready),.Number1(mult_out),.Number2(adder_num2_in));
    
    adder fp_adder11(.clk(clk),.reset(reset),.load(load_2by2),.result_ack(result_ack_2by2),.Result(adder11_out),.result_ready(result_ready_2by2),.Number1(c_1_1),.Number2(adder11_num2_in));
    adder fp_adder12(.clk(clk),.reset(reset),.load(load_2by2),.result_ack(result_ack_2by2),.Result(adder12_out),.result_ready(result_ready_2by2),.Number1(c_1_2),.Number2(adder12_num2_in));
    adder fp_adder21(.clk(clk),.reset(reset),.load(load_2by2),.result_ack(result_ack_2by2),.Result(adder21_out),.result_ready(result_ready_2by2),.Number1(c_2_1),.Number2(adder21_num2_in));
    adder fp_adder22(.clk(clk),.reset(reset),.load(load_2by2),.result_ack(result_ack_2by2),.Result(adder22_out),.result_ready(result_ready_2by2),.Number1(c_2_2),.Number2(adder22_num2_in));
   
    always @(posedge clk or negedge reset)begin
        if(!reset)begin
            ff11_out<=0;
            ff12_out<=0;
            ff21_out<=0;
            ff22_out<=0;
            mux_A<=0;
            mux_B<=0;
            c_1_1<=0;
            c_1_2<=0;
            c_2_1<=0;
            c_2_2<=0;
            cell_out<=0;
        end else begin
            if (reset_FP_Out)
                ff_out<=0;
            else
                ff_out<=adder_out;
            if (fp_2by2_ready)
                begin
                ff11_out<=adder11_out;
                ff12_out<=adder12_out;
                ff21_out<=adder21_out;
                ff22_out<=adder22_out;
                end
            if(enable_decoder) begin    
                case (select_demux)
                    2'b00:  c_1_1<=adder_out;
                    2'b01:  c_1_2<=adder_out;
                    2'b10:  c_2_1<=adder_out;
                    2'b11:  c_2_2<=adder_out;
                endcase
            end else begin
                c_1_1<=0;
                c_1_2<=0;
                c_2_1<=0;
                c_2_2<=0;
            end
            if(cell_ready)begin
                cell_out[31:0]<=ff11_out;
                cell_out[63:32]<=ff12_out;
                cell_out[95:64]<=ff21_out;
                cell_out[127:96]<=ff22_out;
                
                case ({matrix_A[129:128],matrix_B[129:128]})
                    4'b0000: cell_out[129:128]<=2'b00;//1*1
                    4'b1111: cell_out[129:128]<=2'b11;//2*2
                    4'b1110: cell_out[129:128]<=2'b10;//2*1
                    4'b0111: cell_out[129:128]<=2'b01;//1*2
                    default: cell_out[129:128]<=2'b11;
                endcase
            end
        end
        
    end
 generate 
    case (common_factor-1)
        3'b000: begin always @* begin
                 mux_A = matrix_A;
                 mux_B = matrix_B;
             end
             end
        3'b001:begin always @* begin
                    case(select_matrix)
                        1'b0: begin mux_A = matrix_A[129:0]; mux_B = matrix_B[129:0]; end
                        1'b1: begin mux_A = matrix_A[259:130]; mux_B = matrix_B[259:130]; end
                    endcase    
                end
                end
        3'b010:begin always @* begin
                    case(select_matrix)
                        2'b00: begin mux_A = matrix_A[129:0]; mux_B = matrix_B[129:0]; end
                        2'b01: begin mux_A = matrix_A[259:130]; mux_B = matrix_B[259:130]; end
                        2'b10: begin mux_A = matrix_A[389:260];  mux_B = matrix_B[389:260]; end
                    endcase
                end
                end
        3'b011:begin always @* begin
                    case(select_matrix)
                        2'b00: begin mux_A = matrix_A[129:0]; mux_B = matrix_B[129:0]; end
                        2'b01: begin mux_A = matrix_A[259:130]; mux_B = matrix_B[259:130]; end
                        2'b10: begin mux_A = matrix_A[389:260]; mux_B = matrix_B[389:260]; end
                        2'b11: begin mux_A = matrix_A[519:390]; mux_B = matrix_B[519:390]; end
                    endcase
                end
                end
        3'b100:begin always @* begin
                    case(select_matrix)
                        3'b000: begin mux_A = matrix_A[129:0]; mux_B = matrix_B[129:0]; end
                        3'b001: begin mux_A = matrix_A[259:130]; mux_B = matrix_B[259:130]; end
                        3'b010: begin mux_A = matrix_A[389:260]; mux_B = matrix_B[389:260]; end
                        3'b011: begin mux_A = matrix_A[519:390]; mux_B = matrix_B[519:390]; end
                        3'b100: begin mux_A = matrix_A[649:520]; mux_B = matrix_B[649:520]; end
                    endcase
                end
                end
        3'b101:begin always @* begin
                    case(select_matrix)
                        3'b000: begin mux_A = matrix_A[129:0]; mux_B = matrix_B[129:0]; end
                        3'b001: begin mux_A = matrix_A[259:130]; mux_B = matrix_B[259:130]; end
                        3'b010: begin mux_A = matrix_A[389:260]; mux_B = matrix_B[389:260]; end
                        3'b011: begin mux_A = matrix_A[519:390]; mux_B = matrix_B[519:390]; end
                        3'b100: begin mux_A = matrix_A[649:520]; mux_B = matrix_B[649:520]; end
                        3'b101: begin mux_A = matrix_A[779:650]; mux_B = matrix_B[779:650]; end
                    endcase
                end
                end
        3'b110:begin always @* begin
                    case(select_matrix)
                        3'b000: begin mux_A = matrix_A[129:0]; mux_B = matrix_B[129:0]; end
                        3'b001: begin mux_A = matrix_A[259:130]; mux_B = matrix_B[259:130]; end
                        3'b010: begin mux_A = matrix_A[389:260]; mux_B = matrix_B[389:260]; end
                        3'b011: begin mux_A = matrix_A[519:390]; mux_B = matrix_B[519:390]; end
                        3'b100: begin mux_A = matrix_A[649:520]; mux_B = matrix_B[649:520]; end
                        3'b101: begin mux_A = matrix_A[779:650]; mux_B = matrix_B[779:650]; end
                        3'b110: begin mux_A = matrix_A[909:780]; mux_B = matrix_B[909:780]; end
                    endcase
                end
                end
        3'b111:begin always @* begin
                    case(select_matrix)
                        3'b000: begin mux_A = matrix_A[129:0]; mux_B = matrix_B[129:0]; end
                        3'b001: begin mux_A = matrix_A[259:130]; mux_B = matrix_B[259:130]; end
                        3'b010: begin mux_A = matrix_A[389:260]; mux_B = matrix_B[389:260]; end
                        3'b011: begin mux_A = matrix_A[519:390]; mux_B = matrix_B[519:390]; end
                        3'b100: begin mux_A = matrix_A[649:520]; mux_B = matrix_B[649:520]; end
                        3'b101: begin mux_A = matrix_A[779:650]; mux_B = matrix_B[779:650]; end
                        3'b110: begin mux_A = matrix_A[909:780]; mux_B = matrix_B[909:780]; end
                        3'b111: begin mux_A = matrix_A[1039:910]; mux_B = matrix_B[1039:910]; end
                    endcase
                end
                end
    endcase
 endgenerate   
endmodule


