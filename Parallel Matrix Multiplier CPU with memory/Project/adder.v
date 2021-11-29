`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2021 04:46:52 PM
// Design Name: 
// Module Name: adder
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


module adder(
input clk,
input reset, 
input load,
input [31:0]Number1, 
input [31:0]Number2, 
input result_ack,
output [31:0]Result,
output reg result_ready
);
    localparam get_input = 0;
    localparam calculate = 1;
    localparam final = 2;
    
    reg [31:0] number1_copy;
    reg [31:0] number2_copy;
    reg start = 0;
    reg [1:0] state;
    reg    [31:0] Num_shift_80; 
    reg    [7:0]  Larger_exp_80,Final_expo_80;
    reg    [22:0] Small_exp_mantissa_80,S_mantissa_80,L_mantissa_80,Large_mantissa_80,Final_mant_80;
    reg    [23:0] Add_mant_80,Add1_mant_80;
    reg    [7:0]  e1_80,e2_80;
    reg    [22:0] m1_80,m2_80;
    reg           s1_80,s2_80,Final_sign_80;
    reg    [3:0]  renorm_shift_80;
    integer signed   renorm_exp_80;
    //reg           renorm_exp_80;
    reg    [31:0] Result_80;

    assign Result = Result_80;


    always @(*) begin
        //stage 1
        if (start) begin
            e1_80 = number1_copy[30:23];
            e2_80 = number2_copy[30:23];
                m1_80 = number1_copy[22:0];
            m2_80 = number2_copy[22:0];
            s1_80 = number1_copy[31];
            s2_80 = number2_copy[31];
                
                if (e1_80  > e2_80) begin
                    Num_shift_80           = e1_80 - e2_80;              // number of mantissa shift
                    Larger_exp_80           = e1_80;                     // store lower exponent
                    Small_exp_mantissa_80  = m2_80;
                    Large_mantissa_80      = m1_80;
                end
                
                else begin
                    Num_shift_80           = e2_80 - e1_80;
                    Larger_exp_80           = e2_80;
                    Small_exp_mantissa_80  = m1_80;
                    Large_mantissa_80      = m2_80;
                end
        
            if (e1_80 == 0 | e2_80 ==0) begin
                Num_shift_80 = 0;
            end
            else begin
                Num_shift_80 = Num_shift_80;
            end
            
            
                
                //stage 2
                //if check both for normalization then append 1 and shift
            if (e1_80 != 0) begin
                    Small_exp_mantissa_80  = {1'b1,Small_exp_mantissa_80[22:1]};
                Small_exp_mantissa_80  = (Small_exp_mantissa_80 >> Num_shift_80);
                end
            else begin
                Small_exp_mantissa_80 = Small_exp_mantissa_80;
            end
        
            if (e2_80!= 0) begin
                    Large_mantissa_80      = {1'b1,Large_mantissa_80[22:1]};
            end
            else begin
                Large_mantissa_80 = Large_mantissa_80;
            end
        
                    //else do what to do for denorm field
                    
        
                //stage 3
                                                            //check if exponent are equal
                    if (Small_exp_mantissa_80  < Large_mantissa_80) begin
                        //Small_exp_mantissa_80 = ((~ Small_exp_mantissa_80 ) + 1'b1);
                //$display("what small_exp:%b",Small_exp_mantissa_80);
                S_mantissa_80 = Small_exp_mantissa_80;
                L_mantissa_80 = Large_mantissa_80;
                    end
                    else begin
                        //Large_mantissa_80 = ((~ Large_mantissa_80 ) + 1'b1);
                //$display("what large_exp:%b",Large_mantissa_80);
                    
                S_mantissa_80 = Large_mantissa_80;
                L_mantissa_80 = Small_exp_mantissa_80;
                     end       
                //stage 4
                //add the two mantissa's
            
            if (e1_80!=0 & e2_80!=0) begin
                if (s1_80 == s2_80) begin
                        Add_mant_80 = S_mantissa_80 + L_mantissa_80;
                end else begin
                    Add_mant_80 = L_mantissa_80 - S_mantissa_80;
                end
            end	
            else begin
                Add_mant_80 = L_mantissa_80;
            end
                 
            //renormalization for mantissa and exponent
            if (Add_mant_80[23]) begin
                renorm_shift_80 = 4'd1;
                renorm_exp_80 = 4'd1;
            end
            else if (Add_mant_80[22])begin
                renorm_shift_80 = 4'd2;
                renorm_exp_80 = 0;		
            end
            else if (Add_mant_80[21])begin
                renorm_shift_80 = 4'd3; 
                renorm_exp_80 = -1;
            end 
            else if (Add_mant_80[20])begin
                renorm_shift_80 = 4'd4; 
                renorm_exp_80 = -2;		
            end  
            else if (Add_mant_80[19])begin
                renorm_shift_80 = 4'd5; 
                renorm_exp_80 = -3;		
            end      
        
            //stage 5
            // if e1==e2, no shift for exp
                Final_expo_80 =  Larger_exp_80 + renorm_exp_80;
            
            Add1_mant_80 = Add_mant_80 << renorm_shift_80;
        
            Final_mant_80 = Add1_mant_80[23:1];  	
        
                
            if (s1_80 == s2_80) begin
                Final_sign_80 = s1_80;
            end 
        
            if (e1_80 > e2_80) begin
                Final_sign_80 = s1_80;	
            end else if (e2_80 > e1_80) begin
                Final_sign_80 = s2_80;
            end
            else begin
        
                if (m1_80 > m2_80) begin
                    Final_sign_80 = s1_80;		
                end else begin
                    Final_sign_80 = s2_80;
                end
            end	
            
            Result_80 = {Final_sign_80,Final_expo_80,Final_mant_80}; 
        end
        else begin
            Result_80 = 0;
        end
    end
    
    always @(posedge clk, negedge reset) begin
            if(!reset) begin
                Num_shift_80 <= #1 0;
                state <= get_input;
                number1_copy <= 0;
                number2_copy <= 0;
                start <= 0;
                result_ready <= 0;
            end
            else begin
                case (state)
                    get_input: begin
                        if (load) begin
                            number1_copy <= Number1;
                            number2_copy <= Number2;
                            state <= calculate;
                        end
                        else begin
                            state <= get_input;
                            start <= 0;
                            result_ready <= 0;
                        end
                    end
                    calculate: begin
                        start <= 1;
                        state <= final;
                    end
                    final: begin
                        result_ready <= 1;
                        if (result_ack) begin
                            state <= get_input;
                            result_ready <= 0;
                            start <= 0;
                        end 
                        else begin
                            state <= final;
                        end
                    end
                endcase
            end
    end
endmodule
