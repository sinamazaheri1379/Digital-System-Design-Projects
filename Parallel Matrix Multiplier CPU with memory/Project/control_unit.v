`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2021 08:18:34 PM
// Design Name: 
// Module Name: control_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module control_unit #(parameter row_A=16,common_factor=16,column_B=16) (
 input wire clk, reset, start, getting_input,
 input wire [31: 0] row_A_in,
 input wire [31: 0] column_B_in,
 input wire z_stb, result_ready, result_ready_2by2,
 input wire [31: 0] common_factor_register,
 output reg write_readbar, // Signal
 output reg [9: 0] mem_addr, // Register
 output reg [31: 0] row_addr, // Register
 output reg [31: 0] column_addr, // Register
 output reg a_stb,b_stb,z_ack,load_fp,load_2by2,result_ack,result_ack_2by2,// Signal
 output reg [31: 0] select_matrix, // Signal
 output reg [1:0] select_A_2by2, // Register
 output reg [1:0] select_B_2by2, // Register
 output reg [1:0] select_decoder,
 output reg operand_chooser, // Signal
 output reg [1: 0] status_bit_out,
 output reg enable_decoder,
 output reg [1: 0] switch_to_control_unit,
 output reg start_to_data_path,
 output reg cell_ready,
 output reg reset_fp_out,
 output reg fp_2by2_ready
    );
    
    localparam [4: 0] IDLE = 5'b00000,
                      Fetching_Row_A = 5'b00001,
                      Fetching_Common_Factor = 5'b00010,
                      Fetching_Column_B = 5'b00011,
                      Loop_row_A = 5'b00100,
                      Loop_common_fact = 5'b00101,
                      Loop_column = 5'b00110,
                      fetch_status_arr_A = 5'b00111,
                      fetch_status_arr_B  = 5'b01000,
                      IDLE_Start = 5'b01001,
                      State_Fetch_A = 5'b01010,
                      State_Fetch_A_1 = 5'b01011,
                      State_Fetch_A_2 = 5'b01100,
                      State_Fetch_A_3 = 5'b01101,
                      State_Fetch_A_4 = 5'b01110,
                      State_Fetch_A_5 = 5'b01111,
                      State_Fetch_B = 5'b10000,
                      State_Fetch_B_1 = 5'b10001,
                      State_Fetch_B_2 = 5'b10010,
                      State_Fetch_B_3 = 5'b10011,
                      State_Fetch_B_4 = 5'b10100,
                      State_Fetch_B_5 = 5'b10101,
                      State_fetch_final_column = 5'b10110,
                      State_fetch_Row = 5'b10111,
                      Add_2by2 = 5'b11000,
                      mult = 5'b11001,
                      calc = 5'b11010,
                      done = 5'b11011;
                      
                      
     reg [4: 0] current_state, next_state;
     reg [31: 0] row_A_in_register;
     reg [31: 0] column_B_in_register;
     reg [31: 0] common_factor_register_var;
     reg [31: 0] remain_A;
     reg [31: 0] remain_B;
     reg [31: 0] remain_common_factor_register;
     reg [31: 0] row_A_counter;
     reg [31: 0] column_B_counter;
     reg [31: 0] common_factor_register_counter;
     reg [31: 0]common_row_A;
     reg [31: 0] common_column_B;
     reg [31: 0] common_factor_reg;
     reg [1023: 0] pointer_A;
     reg [1023: 0] pointer_B;
     reg [31: 0] j_A;
     reg [31: 0] j_B;
     reg [9: 0] location_pointer_A;
     reg [9: 0] location_pointer_B;
     reg [1: 0] status_arr_A [0: 1023];
     reg [1: 0] status_arr_B [0: 1023];
     reg [31: 0] select_matrix_register;
     reg [1:0] select_A_2by2_int; // Register
     reg [1:0] select_B_2by2_int;
     reg [31: 0] column_addr_register;
     reg [31: 0] row_addr_register;
     reg [1023: 0] save_reg_A;
     reg [1023: 0] save_reg_B;
     integer i, j;
     
     
     
     
     
     
     
     
     always @(posedge clk or negedge reset)
        begin
            if (!reset)
                    current_state <= IDLE;
            else
                current_state <= next_state;
        end
   
 
     always @(*)
        begin
            case (current_state)
                IDLE:
                    begin
                        if (getting_input)
                            next_state = Fetching_Row_A;
                        else
                            next_state = IDLE;
                    end
                Fetching_Row_A: next_state = Fetching_Common_Factor;
                Fetching_Common_Factor: next_state = Fetching_Column_B;
                Fetching_Column_B: next_state = Loop_row_A;
                Loop_row_A: 
                    begin
                        if (remain_A >= 2)
                            next_state = Loop_row_A;
                        else
                            next_state = Loop_common_fact;
                    end
                Loop_common_fact:
                    begin
                        if (remain_common_factor_register >= 2)
                            next_state = Loop_common_fact;
                        else
                            next_state = Loop_column;
                    end
                Loop_column:
                    begin
                        if (remain_B >= 2)
                            next_state = Loop_column;
                        else
                            $display("Loop_column_Ended");
                            next_state = fetch_status_arr_A;
                    end
                fetch_status_arr_A:
                    begin
                        $display("fetch_status_arr_A");
                        if (pointer_A < common_row_A*common_factor_reg)
                            next_state = fetch_status_arr_A;
                        else
                            next_state = fetch_status_arr_B;
                    end
                fetch_status_arr_B:
                    begin
                        if (pointer_B < common_column_B*common_factor_reg)
                            next_state = fetch_status_arr_B;
                        else
                            next_state = IDLE_Start;
                    end
                IDLE_Start:
                    begin
                        next_state = State_Fetch_A;
                    end
                State_Fetch_A:
                    begin
                    if (start)
                        if (pointer_A <= common_factor + save_reg_A)
                            begin
                                case (status_arr_A[pointer_A])
                                2'b00:  next_state = State_Fetch_A;
                                2'b10:  next_state = State_Fetch_A_1;
                                2'b01:  next_state = State_Fetch_A_2;
                                2'b11:  next_state = State_Fetch_A_3;
                                endcase
                            end
                        else
                            next_state = State_Fetch_B;
                    else 
                        next_state = State_Fetch_A;
                    end
               State_Fetch_A_1: next_state =  State_Fetch_A;
               State_Fetch_A_2: next_state = State_Fetch_A;
               State_Fetch_A_3: next_state = State_Fetch_A_4;
               State_Fetch_A_4: next_state = State_Fetch_A_5;
               State_Fetch_A_5: next_state = State_Fetch_A;
               State_Fetch_B:
                    begin
                        if (pointer_B <= common_factor + save_reg_B)
                            begin
                                case (status_arr_B[pointer_B])
                                2'b00:  next_state = State_Fetch_B;
                                2'b10:  next_state = State_Fetch_B_1;
                                2'b01:  next_state = State_Fetch_B_2;
                                2'b11:  next_state = State_Fetch_B_3;
                                endcase
                            end
                        else
                            next_state = State_fetch_final_column;
                    end
               State_Fetch_B_1: next_state =  State_Fetch_B;
               State_Fetch_B_2: next_state = State_Fetch_B;
               State_Fetch_B_3: next_state = State_Fetch_B_4;
               State_Fetch_B_4: next_state = State_Fetch_B_5;
               State_Fetch_B_5: next_state = State_Fetch_B;
               State_fetch_final_column:
                                begin
                                    if (column_addr < column_B % 2 + column_B / 2)
                                         next_state = State_Fetch_A;
                                    else
                                        next_state = State_fetch_Row;
                                end
               State_fetch_Row: 
                                begin
                                    if (row_addr< row_A % 2 + row_A / 2)
                                        next_state = State_fetch_final_column;
                                    else 
                                        next_state = Add_2by2;
                                end
               
                                
               Add_2by2:
                                begin
                                    if (result_ready_2by2)
                                        begin
                                            if (select_matrix_register < common_factor)
                                                next_state = mult;
                                            else
                                                next_state = done;
                                        end
                                    else
                                        next_state = Add_2by2;
                                end
               done: next_state = IDLE;
               
               
               mult: next_state = calc;
               
               calc: next_state = Add_2by2;
               
               endcase
   end
   
   
   
   // Signal outputs
   
   
   
   
   
   always @(*)
        begin
            case (current_state)
                IDLE:
                    begin
                        a_stb = 0;
                        b_stb = 0;
                        z_ack = 0;
                        load_fp = 0;
                        load_2by2 = 0;
                        result_ack = 0;
                        result_ack_2by2 = 0;
                        select_matrix = 0;
                        select_A_2by2 = 0;
                        select_B_2by2 = 0;
                        select_decoder = 0;
                        operand_chooser = 0;
                        status_bit_out = 0;
                        enable_decoder = 0;
                        switch_to_control_unit = 2'b11;
                        start_to_data_path = 0;
                        reset_fp_out = 0;
                        fp_2by2_ready = 0;
                        cell_ready = 0;
                        write_readbar = 1'b0;
                    end
                Fetching_Row_A: switch_to_control_unit = 2'b00;
                Fetching_Common_Factor: switch_to_control_unit = 2'b01;
                Fetching_Column_B: switch_to_control_unit = 2'b10;
                Loop_row_A: switch_to_control_unit = 2'b11;
                fetch_status_arr_B:
                    begin
                        if (pointer_B < common_column_B*common_factor)
                           operand_chooser = 1;
                        else 
                           operand_chooser = 0;
                    end
                State_Fetch_A:
                    begin
                        if (start)
                            begin
                            start_to_data_path = 1;
                            operand_chooser = 1;
                            status_bit_out = status_arr_A[pointer_A];
                            if (pointer_A > common_factor + save_reg_A)
                                status_bit_out = status_arr_B[pointer_B];
                            end
                        else 
                            start_to_data_path = 0;
                            operand_chooser = 0; 
                    end
               State_Fetch_B:
                    begin
                        status_bit_out = status_arr_B[pointer_B];
                    end
               State_fetch_Row: 
                                begin
                                    if (row_addr < row_A % 2 + row_A / 2)
                                        start_to_data_path = 1;
                                    else 
                                        start_to_data_path = 0;
                                end    
               Add_2by2:
                                begin
                                    select_A_2by2 = 0;
                                    select_B_2by2 = 0;  
                                    a_stb = 1;
                                    b_stb = 1;
                                    if (result_ready_2by2)
                                        begin
                                            if (select_matrix_register < common_factor)
                                                begin
                                                    result_ack_2by2 = 1;
                                                    fp_2by2_ready = 1;
                                                end
                                            else    begin
                                                    result_ack_2by2 = 0;
                                                    fp_2by2_ready = 0;
                                                    end
                                        end
                                    else
                                        begin
                                        result_ack_2by2 = 0;  
                                        fp_2by2_ready = 0;
                                        end
                                end
               mult: begin
                        result_ack_2by2 = 0;
                        enable_decoder = 0;
                        fp_2by2_ready = 0;
                        if (z_stb)
                            begin
                                z_ack = 1;
                                result_ack = 0;
                                load_fp = 1;
                            end
                         else
                                begin
                                z_ack = 0;
                                result_ack = 1;
                                load_fp = 0;
                                end
                     end  
              calc:  begin
                        z_ack = 0;
                        if (result_ready)
                            begin
                                case ({select_A_2by2_int, select_B_2by2_int})
                                    4'b0000: 
                                        begin
                                            select_B_2by2 = 2'b10;
                                            select_A_2by2 = 2'b01;
                                            result_ack = 1'b1;
                                            reset_fp_out = 1'b0;
                                        end
                                    4'b0110:
                                        begin
                                            select_B_2by2 = 2'b00;
                                            select_A_2by2 = 2'b10;
                                            result_ack = 1'b1;
                                            enable_decoder = 1'b1;
                                            select_decoder = 2'b00;
                                            reset_fp_out = 1'b1;
                                        end
                                    4'b1000:
                                        begin
                                            select_B_2by2 = 2'b10;
                                            select_A_2by2 = 2'b11;
                                            result_ack = 1'b1;
                                            reset_fp_out = 1'b0;
                                        end
                                    4'b1110:
                                        begin
                                            select_B_2by2 = 2'b01;
                                            select_A_2by2 = 2'b00;
                                            result_ack = 1'b1;
                                            enable_decoder = 1'b1;
                                            select_decoder = 2'b10;
                                            reset_fp_out = 1'b1;
                                        end
                                    4'b0001:
                                        begin
                                            select_B_2by2 = 2'b11;
                                            select_A_2by2 = 2'b01;
                                            result_ack = 1'b1;
                                            reset_fp_out = 1'b0;
                                        end
                                    4'b0111:
                                        begin
                                            select_B_2by2 = 2'b01;
                                            select_A_2by2 = 2'b10;
                                            result_ack = 1'b1;
                                            enable_decoder = 1'b1;
                                            select_decoder = 2'b01;
                                            reset_fp_out = 1'b1;
                                        end
                                    4'b1001:
                                        begin
                                            select_B_2by2 = 2'b11;
                                            select_A_2by2 = 2'b11;
                                            result_ack = 1'b1;
                                            reset_fp_out = 1'b0;
                                        end
                                    4'b1111:
                                        begin
                                            result_ack = 1'b1;
                                            enable_decoder = 1'b1;
                                            select_decoder = 2'b11;
                                            reset_fp_out = 1'b1;
                                            //select_matrix_register <= select_matrix_register + 1
                                        end
                              endcase
                     end
                     else
                        begin
                          select_B_2by2 = 2'b00;
                          select_A_2by2 = 2'b00;
                          result_ack = 1'b0;
                          enable_decoder = 1'b0;
                          select_decoder = 2'b00;
                          reset_fp_out = 1'b0; 
                       end
       end              
       done: cell_ready = 1'b1;
       endcase
   end
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   ////////////////////////////////////////////////////////////////////////////////////////////
   
   
   
   
   
   
   
   
   
   
   
   always @(posedge clk or negedge reset)
        begin
            if (!reset)
                begin
                    save_reg_A <= 0;
                    save_reg_B <= 0;
                    column_addr_register <= 0;
                    row_addr_register <= 0;
                    row_A_in_register <= 0;
                    column_B_in_register <= 0;
                    common_factor_register_var <= 0;
                    remain_common_factor_register <= 0;
                    common_factor_reg <= 0;
                    remain_A <= 0;
                    remain_B <= 0;
                    mem_addr <= 0;
                    row_addr <= 0;
                    column_addr <= 0;
                    row_A_counter <= 0;
                    column_B_counter <= 0;
                    common_factor_register_counter <= 0;
                    common_row_A <= 0;
                    common_column_B <= 0;
                    pointer_A <= 0;
                    pointer_B <= 0;
                    j_A <= 0;
                    j_B <= 0;
                    location_pointer_A <= 0;
                    location_pointer_B <= 0;
                    for (i = 0; i < 1024; i = i + 1)
                        status_arr_A[i] <= 0;
                    for (j = 0; j <  1024; j = j + 1)
                        status_arr_B[j] <= 0;   
                    select_matrix_register <= 0;
                    select_A_2by2_int <= 0;
                    select_B_2by2_int <= 0;
             end
             else
                begin
                    case (current_state)
                IDLE:
                    begin
                    save_reg_A <= 0;
                    save_reg_B <= 0;
                    column_addr_register <= 0;
                    row_addr_register <= 0;
                    row_A_in_register <= 0;
                    column_B_in_register <= 0;
                    common_factor_register_var <= 0;
                    remain_common_factor_register <= 0;
                    remain_A <= 0;
                    remain_B <= 0;
                    mem_addr <= 0;
                    common_factor_reg <= 0;
                    row_addr <= 0;
                    column_addr <= 0;
                    row_A_counter <= 0;
                    column_B_counter <= 0;
                    common_factor_register_counter <= 0;
                    common_row_A <= 0;
                    common_column_B <= 0;
                    pointer_A <= 0;
                    pointer_B <= 0;
                    j_A <= 0;
                    j_B <= 0;
                    location_pointer_A <= 0;
                    location_pointer_B <= 0;
                    for (i = 0; i < 1024; i = i + 1)
                        status_arr_A[i] <= 0;
                    for (j = 0; j <  1024 ; j = j + 1)
                        status_arr_B[j] <= 0;   
                    select_matrix_register <= 0;
                    select_A_2by2_int <= 0;
                    select_B_2by2_int <= 0;
                    end
                Fetching_Row_A:begin
                           row_A_in_register <= row_A_in;
                           mem_addr <= mem_addr + 1;
                           row_A_counter <= row_A_in;
                           end
                Fetching_Common_Factor: begin
                           common_factor_register_var <= common_factor_register;
                           mem_addr <= mem_addr + 1;
                           common_factor_register_counter <= common_factor_register;
                           end
                           
                Fetching_Column_B: 
                            begin
                            column_B_in_register <= column_B_in;
                            column_B_counter <= column_B_in;
                            common_row_A <= 0;
                            remain_A <= row_A_in_register;
                            end
                Loop_row_A: begin
                            if (remain_A >= 2)
                                begin
                                common_row_A <= common_row_A + 1;
                                remain_A <= remain_A - 2;
                                end
                            else begin
                                remain_common_factor_register <= common_factor_register_var;
                                common_factor_reg <= 0;
                                end
                            end
                Loop_common_fact: begin
                            if (remain_common_factor_register >= 2)
                                begin
                                remain_common_factor_register <= remain_common_factor_register - 2;
                                common_factor_reg <= common_factor_reg + 1;
                                end
                            else begin
                                remain_B <= column_B_in_register;
                                common_column_B <= 0;
                                end
                            end
                Loop_column: begin
                            if (remain_B >= 2)
                                begin
                                common_column_B <= common_column_B + 1;
                                remain_B <= remain_B - 2;
                                end
                            else begin
                                pointer_A <= 0;
                                j_A <= 0;
                                end
                            end
                fetch_status_arr_A: begin
                               if ( pointer_A < common_row_A*common_factor_reg)
                                begin
                                    $display("if1");
                                    if ((pointer_A==((common_row_A*common_factor_reg)-1)) && (remain_common_factor_register==1) && (remain_A==1))
                                        begin
                                            $display("if2");
                                            status_arr_A[pointer_A] <= 2'b00;
                                            pointer_A <= pointer_A + 1;
                                        end
                                     else
                                        begin
                                            $display("else2");
                                            if (j_A== common_factor_reg -1)
                                                begin
                                                    $display("if3");
                                                    if (remain_common_factor_register == 1)
                                                        begin
                                                            $display("if4");
                                                            j_A<=0;
                                                            status_arr_A[pointer_A]<=2'b10;
                                                            pointer_A<=pointer_A+1;
                                                        end
                                                    else
                                                        begin
                                                            $display("else5");
                                                            j_A<=0;
                                                            status_arr_A[pointer_A]<=2'b11;
                                                            pointer_A<=pointer_A+1;
                                                        end
                                               end
                                           else
                                                begin
                                                    $display("else1");
                                                    if (pointer_A>= (common_row_A*common_factor_reg) - common_factor_reg)
                                                        begin
                                                            $display("if6");
                                                            if (remain_A == 1)
                                                                begin
                                                                $display("if7");
                                                                status_arr_A[pointer_A]<= 2'b01;
                                                                j_A<=j_A+1;
                                                                pointer_A<=pointer_A+1;
                                                                end
                                                            else
                                                                begin
                                                                    status_arr_A[pointer_A] <= 2'b11;
                                                                    j_A<=j_A+1;
                                                                    pointer_A<=pointer_A+1;
                                                                end
                                                         end
                                                    else
                                                        begin
                                                            status_arr_A[pointer_A] <= 2'b11;
                                                            j_A<=j_A+1;
                                                            pointer_A<=pointer_A+1;
                                                        end
                                             end
                              end
                     end
                     else
                        begin
                            $display("common_row_A * common_factor_register: %d", common_row_A*common_factor_register);
                            pointer_B<=0;
                            j_B<=0;
                        end
                 end                          
                fetch_status_arr_B:
                    begin
                               if ( pointer_B < common_column_B*common_factor_reg)
                                begin
                                    if (pointer_B==(common_column_B*common_factor_reg)-1 && remain_common_factor_register==1 && remain_B==1)
                                        begin
                                            status_arr_B[pointer_B] <= 2'b00;
                                            pointer_B <= pointer_B + 1;
                                        end
                                     else
                                        begin
                                            if (j_B==common_factor_reg-1)
                                                begin
                                                    if (remain_common_factor_register == 1)
                                                        begin
                                                            j_B<=0;
                                                            status_arr_B[pointer_B]<=2'b10;
                                                            pointer_B<=pointer_B+1;
                                                        end
                                                    else
                                                        begin
                                                            j_B<=0;
                                                            status_arr_B[pointer_B]<=2'b11;
                                                            pointer_B<=pointer_B+1;
                                                        end
                                               end
                                           else
                                                begin
                                                    if (pointer_B >= (common_column_B*common_factor_reg) - common_factor_reg)
                                                        begin
                                                            if (remain_B == 1)
                                                                begin
                                                                status_arr_B[pointer_B]<= 2'b01;
                                                                j_B<=j_B+1;
                                                                pointer_B<=pointer_B+1;
                                                                end
                                                            else
                                                                begin
                                                                    status_arr_B[pointer_B] <= 2'b11;
                                                                    j_B<=j_B+1;
                                                                    pointer_B<=pointer_B+1;
                                                                end
                                                         end
                                                    else
                                                        begin
                                                            status_arr_B[pointer_B] <= 2'b11;
                                                            j_B<=j_B+1;
                                                            pointer_B<=pointer_B+1;
                                                        end
                                             end
                              end
                     end
                     else
                        begin
                           pointer_A <= 0;
                           mem_addr <= mem_addr + 1;
                           location_pointer_A <= mem_addr + 1;
                           location_pointer_B <= mem_addr + (row_A * common_factor);
                        end
                 end                          
                State_Fetch_A:
                    begin
                        if (start)
                            location_pointer_A <= mem_addr;
                            if (pointer_A <= common_factor + save_reg_A)
                                begin
                                    case (status_arr_A[pointer_A])
                                        2'b00:
                                            begin
                                                mem_addr <= mem_addr + 1;
                                                pointer_A <= pointer_A + 1;
                                            end
                                        2'b01:
                                            begin
                                                mem_addr <= mem_addr + 1;
                                            end
                                        2'b10: mem_addr <= mem_addr + common_factor;
                                        2'b11: mem_addr <= mem_addr + 1;
                                    endcase
                                end
                            else
                                begin
                                    save_reg_A <= pointer_A;
                                    pointer_B <= save_reg_B;
                                    mem_addr <= location_pointer_B;
                                end
                    end
               State_Fetch_A_1: begin
                                mem_addr<= location_pointer_A + 1;
                                pointer_A <= pointer_A + 1;
                                end
               State_Fetch_A_2: begin
                                mem_addr<=location_pointer_A+2;
                                pointer_A<= pointer_A + 1;
                                end
               State_Fetch_A_3: mem_addr <= mem_addr + common_factor;
               State_Fetch_A_4: mem_addr <= mem_addr + 1;
               State_Fetch_A_5: begin
                                mem_addr<=location_pointer_A+2;
                                pointer_A <= pointer_A + 1;
                                end
               State_Fetch_B:
                    begin
                        location_pointer_B <= mem_addr;
                        if (pointer_B <= common_factor + save_reg_B)
                            begin
                                case (status_arr_B[pointer_B])
                                    2'b00:
                                        begin
                                            mem_addr <= mem_addr + 1;
                                            pointer_B <= pointer_B + 1;
                                        end
                                    2'b01:
                                        begin
                                            mem_addr <= mem_addr + 1;
                                        end
                                    2'b10: mem_addr <= mem_addr + common_factor;
                                    2'b11: mem_addr <= mem_addr + 1;
                                endcase
                             end
                         else
                            begin
                                save_reg_B <= pointer_B;
                            end
                    end
               State_Fetch_A_1: begin
                                mem_addr<= location_pointer_B + 1;
                                pointer_B <= pointer_B + 1;
                                end
               State_Fetch_A_2: begin
                                mem_addr<=location_pointer_B+2;
                                pointer_B<= pointer_B + 1;
                                end
               State_Fetch_A_3: mem_addr <= mem_addr + common_factor;
               State_Fetch_A_4: mem_addr <= mem_addr + 1;
               State_Fetch_A_5: begin
                                mem_addr<=location_pointer_B+2;
                                pointer_B <= pointer_B + 1;
                                end
               State_fetch_final_column: 
                                begin
                                   if (column_addr_register < column_B % 2 + column_B / 2)
                                     begin
                                     pointer_A <= save_reg_A;
                                     column_addr_register <= column_addr_register + 1;
                                     end
                                  else
                                    begin
                                        column_addr_register <= 0;
                                    end
                                end    
               State_fetch_final_column: 
                                begin
                                   if (column_addr_register < column_B % 2 + column_B / 2)
                                     begin
                                     pointer_A <= save_reg_A;
                                     column_addr_register <= column_addr_register + 1;
                                     end
                                  else
                                    begin
                                        column_addr_register <= 0;
                                    end
                                end    
               State_fetch_Row:
                                begin
                                    if (row_addr_register < row_A % 2 + row_A / 2)
                                        begin
                                            row_addr_register <= row_addr_register + 1;
                                        end
                                end
              calc:  begin
                     if (result_ready && {select_A_2by2_int, select_B_2by2_int} == 4'b1111)
                         select_matrix_register <= select_matrix_register + 1;
                     end
             
        endcase
        end
        end   
endmodule
