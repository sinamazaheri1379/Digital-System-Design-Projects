`timescale 1ns/ 1ps
module main_test();
	reg clk, reset, start, getting_input;
	matrixMultiplier  #(.row_A(2), .common_factor(2), .column_B(2)) underTest(.clk(clk), .reset(reset), 
	.start(start), .getting_input(getting_input));
	wire [4: 0] current_state, next_state;
//	wire write_readBar;
	wire [9: 0] address;
	wire [31: 0] memory [0: 1023];
	wire [31: 0] data_out;
	wire [1: 0] switch_to_control_unit;
//	wire [31: 0] A_row;
//	wire [31: 0] common_fact_in;
//	wire [31: 0] B_column;
//	wire [31: 0] row_A_in_register;
//    wire [31: 0] column_B_in_register;
//    wire [31: 0] common_factor_register_var; 
//    wire [31: 0] row_A_counter;
//    wire [31: 0] column_B_counter;
//    wire [31: 0] common_factor_register_counter;
//    wire [31: 0] remain_A, remain_B, remain_common_factor_register, common_row_A, common_column_B, common_factor_reg;
//    wire [31: 0] j_A;
    wire [31: 0] pointer_A;
    wire [1:0] status_arr_A [0: 1023];
//    wire [1: 0] status_arr_B [0: 1023];
//    wire [31: 0] j_B;
//    wire [31: 0] pointer_B;
    wire [9:0] mem_address;
    wire [9:0] location_pointer_A;//, location_pointer_B;
    wire [1023: 0] save_reg_A;
    wire operand_chooser;
    wire [1:0] status_bit_entry;
    wire [129:0] cell_reg_A;
    wire [1:0] counter;
    wire [2:0] common_factor_counter;
    wire [31: 0] operand;
    assign operand = underTest.operand;
    genvar i;
//    generate
//            for (i = 0; i < 1024; i = i + 1)
//                begin
//                    assign status_arr_A [i]  = underTest.controller.status_arr_A[i];
//                 end
//    endgenerate 
    assign operand_chooser = underTest.data_path.operand_chooser;
    assign status_bit_entry = underTest.data_path.status_bit_entry;
    assign cell_reg_A = underTest.data_path.cell_reg_A[0][0];
    assign counter = underTest.data_path.counter;
    assign common_factor_counter = underTest.data_path.common_factor_counter;
    assign mem_address = underTest.controller.mem_addr;
    assign location_pointer_A = underTest.controller.location_pointer_A;
//    assign location_pointer_B = underTest.controller.location_pointer;
//    assign status_arr_B[0] = underTest.controller.status_arr_B[0];
//    assign pointer_B = underTest.controller.pointer_B;
    assign status_arr_A [0]  = underTest.controller.status_arr_A[0];
    assign pointer_A = underTest.controller.pointer_A;
	assign current_state = underTest.controller.current_state; 
	assign next_state = underTest.controller.next_state;
	assign save_reg_A = underTest.controller.save_reg_A;
	assign address = underTest.address;
	    generate
            for (i = 0; i < 1024; i = i + 1)
                begin
                    assign memory[i]  = underTest.mainMem.memory[i];
                 end
    endgenerate    
	assign data_out = underTest.data_out;
	assign switch_to_control_unit = underTest.switch_to_control_unit;
	initial 
	begin
		clk = 1'b0;
		reset = 1'b0;
		forever #5 clk = ~clk;
	end	

	initial
	begin
		start = 1'b0;
		getting_input = 1'b0;
		#2;
		getting_input = 1'b1;
		reset = 1'b1;
		#498;
		start = 1'b1;
	end
	
endmodule