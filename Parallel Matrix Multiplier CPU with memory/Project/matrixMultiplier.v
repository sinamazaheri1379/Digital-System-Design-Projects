`timescale 1ns / 1ps

module matrixMultiplier #(parameter row_A=16,common_factor=16,column_B=16) (
input clk,reset,start,getting_input,
output done
    );
    localparam  reg [31: 0] common_A_row = row_A / 2 + row_A % 2;
    localparam  reg [31: 0] common_B_column = column_B / 2 + column_B % 2;
    localparam  reg [31: 0] common_fact = common_factor / 2 + common_factor % 2;
    wire write_readbar;
    wire reset_fp_out;
    wire [31:0] data_in;
    wire [9:0] address;
    wire [31:0] data_out;
    wire [31: 0] select_matrix;
    wire [1: 0] select_A_2by2;
    wire [1: 0] select_B_2by2;
    wire [1: 0] select_decoder;
    wire operand_chooser;
    wire [31: 0] row_addr;
    wire [31: 0] column_addr;
    wire a_stb,b_stb,z_stb,a_ack,b_ack,z_ack,load_fp,load_2by2,result_ack,result_ack_2by2,result_ready,result_ready_2by2;
    wire cell_ready;
    wire enable_decoder;
    wire [1: 0] switch_to_control_unit;
    mainMemory mainMem(.clk(clk),.reset(reset),.write_readBar(write_readbar),.data_in(data_in),.address(address),.data_out(data_out));
    reg [31: 0] A_row;
    reg [31: 0] B_column;
    wire  result_finish;
    reg [31: 0] common_fact_in;
    reg [31: 0] operand;
    wire [1: 0] status_bit_out;
    wire fp_2by2_ready;
    wire start_to_data_path;
    wire done;
    dataPath #(.row_A(row_A),.common_factor(common_factor),.column_B(column_B)) data_path (.cell_ready(cell_ready),.clk(clk),.reset(reset),.select_matrix(select_matrix),.select_A_2by2(select_A_2by2),.select_B_2by2(select_B_2by2),
                .select_decode(select_decoder),.operand(operand),.operand_chooser(operand_chooser),.row_addr(row_addr),.column_addr(column_addr),.out(data_in),
                .a_stb(a_stb), .b_stb(b_stb),.result_finish(result_finish), .z_stb(z_stb), .a_ack(a_ack), .b_ack(b_ack),.status_bit_entry(status_bit_out),
                                             .z_ack(z_ack), .load_fp(load_fp),.load_2by2(load_2by2),.result_ack(result_ack),.result_ack_2by2(result_ack_2by2),
                                             .result_ready(result_ready),.enable_decoder(enable_decoder),.result_ready_2by2(result_ready_2by2), .reset_fp_out(reset_fp_out), .fp_2by2_ready(fp_2by2_ready), .start(start_to_data_path));
                
    control_unit #(.row_A(row_A),.common_factor(common_factor),.column_B(column_B)) controller(.common_factor_register(common_fact_in),.row_A_in(A_row),.column_B_in(B_column),.clk(clk),.reset(reset),.write_readbar(write_readbar),.mem_addr(address),.select_matrix(select_matrix),
                            .select_A_2by2(select_A_2by2),.select_B_2by2(select_B_2by2),.select_decoder(select_decoder),.operand_chooser(operand_chooser),.row_addr(row_addr),.column_addr(column_addr),
                            .a_stb(a_stb), .b_stb(b_stb), .z_stb(z_stb),
                                             .z_ack(z_ack), .load_fp(load_fp),.load_2by2(load_2by2),.result_ack(result_ack),.result_ack_2by2(result_ack_2by2),
                                             .result_ready(result_ready),.result_ready_2by2(result_ready_2by2), .cell_ready(cell_ready), .switch_to_control_unit(switch_to_control_unit), .reset_fp_out(reset_fp_out), .fp_2by2_ready(fp_2by2_ready)
                                             ,.getting_input(getting_input), .start(start),.enable_decoder(enable_decoder), .start_to_data_path(start_to_data_path),.status_bit_out(status_bit_out));
                                             
     always @(switch_to_control_unit or data_out)
        begin
        A_row = 0;
        common_fact_in = 0;
        B_column = 0;
        operand = 0;
        case (switch_to_control_unit)
            2'b00: A_row = data_out;
            2'b01: common_fact_in = data_out;
            2'b10: B_column = data_out;
            default: operand = data_out;
        endcase
        end
    assign done = cell_ready;                                         
     
endmodule
