`timescale 1ns / 1ps
module dataPath #(parameter row_A=16,common_factor=16,column_B=16)(
input fp_2by2_ready,enable_decoder,
input [31:0] operand,
input [1: 0] status_bit_entry,
input operand_chooser, result_finish, start,
input [31: 0] row_addr,
input [31: 0] column_addr,
input a_stb,b_stb,z_ack,load_fp,load_2by2,result_ack,result_ack_2by2,
input reset,clk,
input reset_fp_out,
input [31:0] select_matrix,
input [1:0] select_A_2by2, 
input [1:0] select_B_2by2,
input [1:0] select_decode,
input cell_ready,
output reg [31: 0] out,
output wire a_ack,b_ack,z_stb,result_ready,result_ready_2by2
    );
    localparam  reg [31: 0] common_A_row = row_A / 2 + row_A % 2;
    localparam  reg [31: 0] common_B_column = column_B / 2 + column_B % 2;
    localparam  reg [31: 0] common_fact = common_factor / 2 + common_factor % 2;
    reg [common_fact * 130 - 1: 0] cell_reg_A [0: common_A_row - 1][0: common_B_column - 1];
    reg [common_fact * 130 - 1: 0] cell_reg_B [0: common_A_row - 1][0: common_B_column - 1];
    wire [129: 0] cell_output [0: common_A_row - 1][0: common_B_column - 1]; // Cij = sigma AikBkj
    genvar i,j;
    generate 
        for(i=0;i<common_A_row;i=i+1)
            begin: i_index
                for(j=0;j<common_B_column;j=j+1)
                    begin:  j_index
                        cellcalc #(common_fact) calc_cell(.fp_2by2_ready(fp_2by2_ready),.reset_FP_Out(reset_fp_out), .cell_ready(cell_ready), .a_stb(a_stb), .b_stb(b_stb), .z_stb(z_stb),
                                             .z_ack(z_ack), .load_fp(load_fp),.load_2by2(load_2by2),
                                             .result_ack(result_ack),.result_ack_2by2(result_ack_2by2),
                                             .result_ready(result_ready),.result_ready_2by2(result_ready_2by2),.clk(clk),.reset(reset),
                                             .select_matrix(select_matrix),.select_A_2by2(select_A_2by2),.enable_decoder(enable_decoder),
                                             .select_B_2by2(select_B_2by2),.select_demux(select_decode),.matrix_A(cell_reg_A[i][j]),.matrix_B(cell_reg_B[i][j]),.cell_out(cell_output[i][j]));
                    end      
        end
    endgenerate     
    reg [31: 0] c;
    reg [31: 0] k;
    reg [31: 0] common_factor_counter;
    reg [1:0] counter;
    always @(posedge clk or negedge reset)
        begin
            if(!reset)
                begin
                    common_factor_counter <= 0;
                    for (c = 0; c < common_A_row; c = c + 1)
                        begin
                            for (k = 0; k < common_B_column; k = k + 1)
                                begin
                                    cell_reg_A[c][k] <= 0;
                                    cell_reg_B[c][k] <= 0;
                                 end
                        end
                end
            else
                begin
                    if (start)
                        begin
                            case (common_factor_counter)
                                            3'b000:
                                                begin
                                                        case (counter)
                                                        2'b00:  
                                                            begin
                                                                if (operand_chooser)
                                                                    begin
                                                                        cell_reg_A [row_addr][column_addr][31: 0] <= operand;
                                                                        cell_reg_A [row_addr][column_addr][129: 128] <= status_bit_entry;
                                                                    end
                                                                else
                                                                    begin
                                                                        cell_reg_B [row_addr][column_addr][31: 0] <= operand;
                                                                        cell_reg_B [row_addr][column_addr][129: 128] <= status_bit_entry;
                                                                    end
                                                                        
                                                               case (status_bit_entry)
                                                               2'b00:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end             
                                                               2'b01:
                                                                begin
                                                                     counter <= 1;
                                                                     common_factor_counter <= common_factor_counter;
                                                                end
                                                               2'b10: 
                                                                begin
                                                                    counter <= 2;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 1;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase
                                                                
                                                            end
                                                        2'b01:
                                                            begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][63: 32] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][63: 32] <= operand;
                                                               case (status_bit_entry)            
                                                               2'b01:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 2;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase
                                                            end
                                                        2'b10:
                                                             begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][95: 64] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][95: 64] <= operand;
                                                               case (status_bit_entry)            
                                                               2'b10:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 3;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase    
                                                                
                                                            end
                                                        2'b11:
                                                            begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][127: 96] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][127: 96] <= operand;
                                                                counter <= 0;
                                                                common_factor_counter <= common_factor_counter + 1;
                                                            end
                                                        endcase
                                                end
                                                        
                                            3'b001:
                                                begin
                                                        case (counter)
                                                        2'b00:  
                                                            begin
                                                                if (operand_chooser)
                                                                    begin
                                                                        cell_reg_A [row_addr][column_addr][159: 128] <= operand;
                                                                        cell_reg_A [row_addr][column_addr][257: 256] <= status_bit_entry;
                                                                    end
                                                                else
                                                                    begin
                                                                        cell_reg_B [row_addr][column_addr][159: 128] <= operand;
                                                                        cell_reg_B [row_addr][column_addr][257: 256] <= status_bit_entry;
                                                                    end
                                                                        
                                                               case (status_bit_entry)
                                                               2'b00:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end             
                                                               2'b01:
                                                                begin
                                                                     counter <= 1;
                                                                     common_factor_counter <= common_factor_counter;
                                                                end
                                                               2'b10: 
                                                                begin
                                                                    counter <= 2;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 1;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase
                                                                
                                                            end
                                                        2'b01:
                                                            begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][191: 160] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][191: 160] <= operand;
                                                               case (status_bit_entry)            
                                                               2'b01:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 2;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase
                                                            end
                                                        2'b10:
                                                             begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][223: 192] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][223: 192] <= operand;
                                                               case (status_bit_entry)            
                                                               2'b10:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 3;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase    
                                                                
                                                            end
                                                        2'b11:
                                                            begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][255: 224] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][255: 224] <= operand;
                                                                counter <= 0;
                                                                common_factor_counter <= common_factor_counter + 1;
                                                            end
                                                        endcase
                                                end
                                                 
                                            3'b010:
                                                begin
                                                        case (counter)
                                                        2'b00:  
                                                            begin
                                                                if (operand_chooser)
                                                                    begin
                                                                        cell_reg_A [row_addr][column_addr][289: 258] <= operand;
                                                                        cell_reg_A [row_addr][column_addr][387: 386] <= status_bit_entry;
                                                                    end
                                                                else
                                                                    begin
                                                                        cell_reg_B [row_addr][column_addr][289: 258] <= operand;
                                                                        cell_reg_B [row_addr][column_addr][387: 386] <= status_bit_entry;
                                                                    end
                                                                        
                                                               case (status_bit_entry)
                                                               2'b00:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end             
                                                               2'b01:
                                                                begin
                                                                     counter <= 1;
                                                                     common_factor_counter <= common_factor_counter;
                                                                end
                                                               2'b10: 
                                                                begin
                                                                    counter <= 2;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 1;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase
                                                                
                                                            end
                                                        2'b01:
                                                            begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][321: 290] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][321: 290] <= operand;
                                                               case (status_bit_entry)            
                                                               2'b01:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 2;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase
                                                            end
                                                        2'b10:
                                                             begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][353: 322] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][353: 322] <= operand;
                                                               case (status_bit_entry)            
                                                               2'b10:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 3;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase    
                                                                
                                                            end
                                                        2'b11:
                                                            begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][385: 354] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][385: 354] <= operand;
                                                                counter <= 0;
                                                                common_factor_counter <= common_factor_counter + 1;
                                                            end
                                                        endcase
                                                end
                                            3'b011:
                                                begin
                                                        case (counter)
                                                        2'b00:  
                                                            begin
                                                                if (operand_chooser)
                                                                    begin
                                                                        cell_reg_A [row_addr][column_addr][419: 388] <= operand;
                                                                        cell_reg_A [row_addr][column_addr][516: 515] <= status_bit_entry;
                                                                    end
                                                                else
                                                                    begin
                                                                        cell_reg_B [row_addr][column_addr][419: 388] <= operand;
                                                                        cell_reg_B [row_addr][column_addr][516: 515] <= status_bit_entry;
                                                                    end
                                                                        
                                                               case (status_bit_entry)
                                                               2'b00:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end             
                                                               2'b01:
                                                                begin
                                                                     counter <= 1;
                                                                     common_factor_counter <= common_factor_counter;
                                                                end
                                                               2'b10: 
                                                                begin
                                                                    counter <= 2;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 1;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase
                                                                
                                                            end
                                                        2'b01:
                                                            begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][451: 420] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][451: 420] <= operand;
                                                               case (status_bit_entry)            
                                                               2'b01:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 2;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase
                                                            end
                                                        2'b10:
                                                             begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][483: 452] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][483: 452] <= operand;
                                                               case (status_bit_entry)            
                                                               2'b10:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 3;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase    
                                                                
                                                            end
                                                        2'b11:
                                                            begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][514: 483] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][514: 483] <= operand;
                                                                counter <= 0;
                                                                common_factor_counter <= common_factor_counter + 1;
                                                            end
                                                        endcase
                                                end
                                            3'b100:
                                                begin
                                                        case (counter)
                                                        2'b00:  
                                                            begin
                                                                if (operand_chooser)
                                                                    begin
                                                                        cell_reg_A [row_addr][column_addr][548: 517] <= operand;
                                                                        cell_reg_A [row_addr][column_addr][646: 645] <= status_bit_entry;
                                                                    end
                                                                else
                                                                    begin
                                                                        cell_reg_B [row_addr][column_addr][548: 517] <= operand;
                                                                        cell_reg_B [row_addr][column_addr][646: 645] <= status_bit_entry;
                                                                    end
                                                                        
                                                               case (status_bit_entry)
                                                               2'b00:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end             
                                                               2'b01:
                                                                begin
                                                                     counter <= 1;
                                                                     common_factor_counter <= common_factor_counter;
                                                                end
                                                               2'b10: 
                                                                begin
                                                                    counter <= 2;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 1;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase
                                                                
                                                            end
                                                        2'b01:
                                                            begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][580: 549] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][580: 549] <= operand;
                                                               case (status_bit_entry)            
                                                               2'b01:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 2;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase
                                                            end
                                                        2'b10:
                                                             begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][612: 581] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][612: 581] <= operand;
                                                               case (status_bit_entry)            
                                                               2'b10:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 3;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase    
                                                                
                                                            end
                                                        2'b11:
                                                            begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][644: 613] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][644: 613] <= operand;
                                                                counter <= 0;
                                                                common_factor_counter <= common_factor_counter + 1;
                                                            end
                                                        endcase
                                                end
                                            3'b101:
                                                begin
                                                        case (counter)
                                                        2'b00:  
                                                            begin
                                                                if (operand_chooser)
                                                                    begin
                                                                        cell_reg_A [row_addr][column_addr][678: 647] <= operand;
                                                                        cell_reg_A [row_addr][column_addr][776: 775] <= status_bit_entry;
                                                                    end
                                                                else
                                                                    begin
                                                                        cell_reg_B [row_addr][column_addr][678: 647] <= operand;
                                                                        cell_reg_B [row_addr][column_addr][776: 775] <= status_bit_entry;
                                                                    end
                                                                        
                                                               case (status_bit_entry)
                                                               2'b00:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end             
                                                               2'b01:
                                                                begin
                                                                     counter <= 1;
                                                                     common_factor_counter <= common_factor_counter;
                                                                end
                                                               2'b10: 
                                                                begin
                                                                    counter <= 2;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 1;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase
                                                                
                                                            end
                                                        2'b01:
                                                            begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][710: 679] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][710: 679] <= operand;
                                                               case (status_bit_entry)            
                                                               2'b01:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 2;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase
                                                            end
                                                        2'b10:
                                                             begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][742: 711] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][742: 711] <= operand;
                                                               case (status_bit_entry)            
                                                               2'b10:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 3;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase    
                                                                
                                                            end
                                                        2'b11:
                                                            begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][774: 743] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][774: 743] <= operand;
                                                                counter <= 0;
                                                                common_factor_counter <= common_factor_counter + 1;
                                                            end
                                                        endcase
                                                end
                                            3'b110:
                                                begin
                                                        case (counter)
                                                        2'b00:  
                                                            begin
                                                                if (operand_chooser)
                                                                    begin
                                                                        cell_reg_A [row_addr][column_addr][808: 777] <= operand;
                                                                        cell_reg_A [row_addr][column_addr][906: 905] <= status_bit_entry;
                                                                    end
                                                                else
                                                                    begin
                                                                        cell_reg_B [row_addr][column_addr][808: 777] <= operand;
                                                                        cell_reg_B [row_addr][column_addr][906: 905] <= status_bit_entry;
                                                                    end
                                                                        
                                                               case (status_bit_entry)
                                                               2'b00:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end             
                                                               2'b01:
                                                                begin
                                                                     counter <= 1;
                                                                     common_factor_counter <= common_factor_counter;
                                                                end
                                                               2'b10: 
                                                                begin
                                                                    counter <= 2;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 1;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase
                                                                
                                                            end
                                                        2'b01:
                                                            begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][840: 809] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][840: 809] <= operand;
                                                               case (status_bit_entry)            
                                                               2'b01:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 2;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase
                                                            end
                                                        2'b10:
                                                             begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][872: 841] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][872: 841] <= operand;
                                                               case (status_bit_entry)            
                                                               2'b10:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 3;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase    
                                                                
                                                            end
                                                        2'b11:
                                                            begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][904: 873] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][904: 873] <= operand;
                                                                counter <= 0;
                                                                common_factor_counter <= common_factor_counter + 1;
                                                            end
                                                        endcase
                                                end
                                            3'b111:
                                                begin
                                                        case (counter)
                                                        2'b00:  
                                                            begin
                                                                if (operand_chooser)
                                                                    begin
                                                                        cell_reg_A [row_addr][column_addr][938: 907] <= operand;
                                                                        cell_reg_A [row_addr][column_addr][1036: 1035] <= status_bit_entry;
                                                                    end
                                                                else
                                                                    begin
                                                                        cell_reg_B [row_addr][column_addr][938: 907] <= operand;
                                                                        cell_reg_B [row_addr][column_addr][1036: 1035] <= status_bit_entry;
                                                                    end
                                                                        
                                                               case (status_bit_entry)
                                                               2'b00:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end             
                                                               2'b01:
                                                                begin
                                                                     counter <= 1;
                                                                     common_factor_counter <= common_factor_counter;
                                                                end
                                                               2'b10: 
                                                                begin
                                                                    counter <= 2;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 1;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase
                                                                
                                                            end
                                                        2'b01:
                                                            begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][970: 939] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][970: 939] <= operand;
                                                               case (status_bit_entry)            
                                                               2'b01:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 2;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase
                                                            end
                                                        2'b10:
                                                             begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][1002: 971] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][1002: 971] <= operand;
                                                               case (status_bit_entry)            
                                                               2'b10:
                                                                begin
                                                                     counter <= 0;
                                                                     if (common_factor_counter < common_fact - 1)
                                                                        common_factor_counter <= common_factor_counter + 1;
                                                                     else
                                                                        common_factor_counter <= 0;
                                                                end
                                                               2'b11:
                                                                begin
                                                                    counter <= 3;
                                                                    common_factor_counter <= common_factor_counter;
                                                                end
                                                               endcase    
                                                                
                                                            end
                                                        2'b11:
                                                            begin
                                                                if (operand_chooser)
                                                                    cell_reg_A [row_addr][column_addr][1034: 1003] <= operand;
                                                                else
                                                                    cell_reg_B [row_addr][column_addr][1034: 1003] <= operand;
                                                                counter <= 0;
                                                                common_factor_counter <= common_factor_counter + 1;
                                                            end
                                                        endcase
                                                end
                                            endcase
                                            
                                        
                                
                                    
                        end
                    else
                        begin
                            cell_reg_A[row_addr][column_addr] <= cell_reg_A[row_addr][column_addr];
                            cell_reg_B[row_addr][column_addr] <= cell_reg_B[row_addr][column_addr];
                        end       
                end
        end
    
    always @(posedge clk or negedge reset)
        begin 
            if(!reset)
                begin
                    out <= 0;
                    counter <= 0;
                end
//            else
//                begin
//                    if(result_finish)
//                        begin
//                            if (count)
//                                begin
//                                    status_bit <= cell_output[row_addr][column_addr][129: 128];
//                                    counter <= counter + 1;
//                                    case (counter)
//                                    2'b00: out <= cell_output[row_addr][column_addr][31: 0];
//                                    2'b01: out <= cell_output[row_addr][column_addr][63: 32];
//                                    2'b10: out <= cell_output[row_addr][column_addr][95: 64];
//                                    2'b11: out <= cell_output[row_addr][column_addr][127: 96];
//                                    endcase
//                                end
//                            else
//                                begin
//                                    counter <= 0;
//                                    out <= 0;
//                                    status_bit <= 0;
//                                end                                
//                         end
                        
//                    else
//                        begin
//                            out <= out;
//                            status_bit <= status_bit;
//                            counter <= 0;
//                        end
//                 end
        end
                      
    
    
    
    
    
    
    
      
endmodule

