`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/24/2021 06:24:16 PM
// Design Name: 
// Module Name: incubator
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


module incubator(
    input wire [7:0] T,
    input wire clk,
    input wire reset,
    output reg Cooler,
    output reg Heater,
    output reg [7:0] CRS
    );
    
    parameter S1 = 3'b000,
              S2 = 3'b001,
              S3 = 3'b010,
              S4 = 3'b011,
              S5 = 3'b100;
    
    reg [2:0] current_state, next_state;
    reg temp_Cooler, temp_Heater;
    reg [7:0] temp_CRS;
    //
    always @(posedge clk or negedge reset)
        begin
            if (!reset)
                current_state <= S1;
            else
                current_state <= next_state;
        end
    //
    
    always @(T or current_state)
        begin
            next_state = current_state;
            case (current_state)
                S1:
                    begin
                        if (T < 15)
                            next_state = S2;
                        else if (T > 35)
                            next_state = S3;
                        else
                            next_state = S1;
                     end
                S2:
                    begin
                        if (T > 30)
                            next_state = S1;
                        else
                            next_state = S2;
                    end
                S3:
                    begin
                        if (T > 40)
                            next_state = S4;
                        else if (T < 25)
                            next_state = S1;
                        else
                            next_state = S3;
                    end
                S4:
                    begin
                        if (T > 45)
                            next_state = S5;
                        else if(T < 35)
                            next_state = S3;
                        else
                            next_state = S4;
                    end
                S5:
                    begin
                        if (T < 40)
                            next_state = S4;
                        else
                            next_state = S5;
                    end
                endcase
     end
     
     always @(T or current_state)
        begin
            temp_Cooler = 0;
            temp_Heater = 0;
            temp_CRS = 0;
            case (current_state)
                S1:
                    begin
                        temp_Heater = 0;
                        temp_Cooler = 0;
                        temp_CRS = 0;
                    end
                S2:
                    begin
                        temp_Heater = 1;
                        temp_Cooler = 0;
                        temp_CRS = 0;
                    end
                S3:
                    begin
                        temp_Heater = 0;
                        temp_Cooler = 1;
                        temp_CRS = 4;
                    end
                S4:
                    begin
                        temp_Heater = 0;
                        temp_Cooler = 1;
                        temp_CRS = 6;
                    end
                S5:
                    begin
                        temp_Heater = 0;
                        temp_Cooler = 1;
                        temp_CRS = 8;
                    end
            endcase
      end
      
always @(posedge clk or negedge reset)
    begin
        if (!reset)
          begin
            Cooler <= 0;
            Heater <= 0;
            CRS <= 0;
          end
        else 
            begin
            Cooler <= temp_Cooler;
            Heater <= temp_Heater;
            CRS <= temp_CRS;
            end
    end
           
                            
endmodule
