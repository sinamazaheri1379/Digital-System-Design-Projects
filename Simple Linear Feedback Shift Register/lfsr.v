`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2021 01:02:32 PM
// Design Name: 
// Module Name: lfsr
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


module lfsr #(parameter N = 4)
   (
    input wire [N:1] seed_value,
    input wire  clk, reset, load_seed,
    output reg [N:1] output_value
    );
    
    wire feedback_value;
    reg [N:1] current_state, next_state;
    generate
        begin
           case(N)
                2: assign feedback_value = current_state[2] ^ current_state[1];
                3: assign feedback_value = current_state[3] ^ current_state[2];
                4: assign feedback_value = current_state[4] ^ current_state[3];
                5: assign feedback_value = current_state[5] ^ current_state[3];
                6: assign feedback_value = current_state[6] ^ current_state[5];
                7: assign feedback_value = current_state[7] ^ current_state[6];
                8: assign feedback_value = current_state[8] ^ current_state[6] ^ current_state[5] ^ current_state[1];
                9: assign feedback_value = current_state[9] ^ current_state[5];
                10:assign feedback_value = current_state[10] ^ current_state[7];
                11:assign feedback_value = current_state[11] ^ current_state[9];
                12:assign feedback_value = current_state[12] ^ current_state[11] ^ current_state[10] ^ current_state[4];
                13:assign feedback_value = current_state[13] ^ current_state[12] ^ current_state[11] ^ current_state[8];
                14:assign feedback_value = current_state[14] ^ current_state[13] ^ current_state[12] ^ current_state[2];
                15:assign feedback_value = current_state[15] ^ current_state[14];
                16:assign feedback_value = current_state[16] ^ current_state[15] ^ current_state[13] ^ current_state[4];
                17:assign feedback_value = current_state[17] ^ current_state[3]; // considered
                18:assign feedback_value = current_state[18] ^ current_state[11];
                19:assign feedback_value = current_state[19] ^ current_state[18] ^ current_state[17] ^ current_state[14];
                20:assign feedback_value = current_state[20] ^ current_state[17];
                21:assign feedback_value = current_state[21] ^ current_state[19];
                22:assign feedback_value = current_state[22] ^ current_state[21];
                23:assign feedback_value = current_state[23] ^ current_state[18];
                24:assign feedback_value = current_state[24] ^ current_state[23] ^ current_state[22] ^ current_state[17];
                default:assign feedback_value = 1'bz;
            endcase
         end
     endgenerate
      
      
    always @(current_state or feedback_value)
        begin
            next_state[N] = feedback_value;
            next_state[N - 1:1] = current_state[N:2];
        end         
    always @(posedge clk or negedge reset)
        begin
            if (!reset)
                    current_state <= 0;
            else if (load_seed)
                    current_state <= seed_value;
            else
                    current_state <= next_state;
        end
    
    always @(current_state)
        output_value = current_state;
    
    
endmodule
