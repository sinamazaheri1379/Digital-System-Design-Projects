`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/31/2021 12:31:33 AM
// Design Name: 
// Module Name: UART
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


module UART #(parameter clks_per_bit = 80)(
    input wire [7: 0] serial_data,
    input wire uart_clk,
    input wire reset,
    input wire receive_transmit,
    output reg done,
    inout wire uart_bus,
    output reg error,
    output reg [7: 0] data_out
    );
    
    reg [$clog2(clks_per_bit) - 1: 0] r_clock_counter;
    reg [8: 0] buffer;
    reg [4: 0] r_index_counter;
    
    reg [2: 0] current_state;
    reg saved_bit;
    localparam IDLE = 3'b000, START = 3'b001, DATA = 3'b010, STOP = 3'b011, ERRORCHECKING = 3'b100, DONE = 3'b101, TRANSMITTER = 3'b110, RECOVERY = 3'b111;
    
    always @(posedge uart_clk or negedge reset)
        begin
            if (!reset)
                begin
                    saved_bit <= 0;
                    buffer <= 0;
                    current_state <= IDLE;
                    r_clock_counter <= 0;
                    r_index_counter <= 0;
                    error <= 0;
                    data_out <= 0;
                    done <= 1'b0;
                end
            else
                begin
                    case (current_state)
                        IDLE:
                            begin
                                r_clock_counter <= 0;
                                r_index_counter <= 0;
                                error <= 0;
                                data_out <= 0;
                                done <= 1'b0;
                                if (receive_transmit)
                                    begin
                                    buffer <= 0;
                                        if (!uart_bus)
                                                current_state <= START;
                                        else
                                                current_state <= IDLE;
                                    end 
                                else
                                    begin
                                                current_state <= TRANSMITTER;
                                                buffer <= serial_data;
                                    end
                            end
                        START:
                            begin
                                 if (r_clock_counter < clks_per_bit - 1)
                                    begin
                                        current_state <= START;
                                        r_clock_counter <= r_clock_counter + 1;
                                    end
                                 else
                                    begin
                                        current_state <= DATA;
                                        r_clock_counter <= 0;                   
                                    end 
                             end
                          DATA:
                            begin
                                if (r_clock_counter < clks_per_bit - 1)
                                    begin
                                        saved_bit <= uart_bus;
                                        current_state <= DATA;
                                        r_clock_counter <= r_clock_counter + 1;
                                    end
                                else
                                    begin
                                        r_clock_counter <= 0;
                                        if (r_index_counter < 8)
                                            begin
                                                current_state <= DATA;
                                                buffer[r_index_counter] <= saved_bit;
                                                r_index_counter <= r_index_counter + 1;
                                            end
                                        else
                                            begin
                                                buffer[r_index_counter] <= saved_bit;
                                                current_state <= STOP;
                                                r_index_counter <= 0;
                                            end
                                    end 
                              end
                             STOP:
                                begin
                                    if (r_clock_counter < clks_per_bit - 1)
                                        begin
                                            current_state <= STOP;
                                            r_clock_counter <= r_clock_counter + 1;
                                        end
                                    else 
                                        begin
                                            current_state <= ERRORCHECKING;
                                            error <= ~^buffer;
                                            r_clock_counter <= 0;
                                        end
                                end
                             ERRORCHECKING:
                                begin
                                    if (error)
                                        current_state <= RECOVERY;
                                    else
                                        begin
                                        done <= 1'b1;
                                        data_out <= buffer[7: 0];
                                        current_state <= DONE;
                                        end
                                end
                             DONE: current_state <= IDLE;
                             RECOVERY:  current_state <= START;     
              endcase
         end
  end
        
endmodule
