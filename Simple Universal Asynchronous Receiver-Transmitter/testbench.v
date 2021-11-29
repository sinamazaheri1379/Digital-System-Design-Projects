`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2021 05:55:43 PM
// Design Name: 
// Module Name: testbench
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


module testbench(

    );
    reg [7: 0] serial_data;
    reg uart_clk, reset, receive_transmit, uart_reg;
    wire [7: 0] data_out;
    wire error;
    wire done;
    wire uart_bus;
    UART #(4) uart0(.uart_clk(uart_clk), .reset(reset), .done(done), .uart_bus(uart_bus), .receive_transmit(receive_transmit), .error(error), .serial_data(serial_data), .data_out(data_out));
    assign uart_bus = uart_reg;
    initial 
        begin
            uart_clk = 1'b0;
            reset = 1'b0;
            forever #5 uart_clk = ~ uart_clk;
        end
     
     //Data = 01101011, Parity = 0, Transmited Data: 001101011 (Odd parity)
     wire [2: 0] current_state;
     wire [1: 0] r_clock_counter;
     wire [2: 0] r_index_counter; 
     wire [8: 0] buffer;
     assign buffer = uart0.buffer;
     assign current_state = uart0.current_state;
     assign r_clock_counter = uart0.r_clock_counter;
     assign r_index_counter = uart0.r_index_counter;
     initial
        begin
            uart_reg = 1'b1;
            serial_data = 8'b0;
            receive_transmit = 1'b1;
            #1 reset = 1'b1;
            #4 uart_reg = 1'b0; // Start Bit
            #40 uart_reg = 1'b1; // Data Bits
            #40 uart_reg = 1'b1; 
            #40 uart_reg = 1'b0;
            #40 uart_reg = 1'b1;
            #40 uart_reg = 1'b0;
            #40 uart_reg = 1'b1;
            #40 uart_reg = 1'b1;
            #40 uart_reg = 1'b0;
            #40 uart_reg = 1'b0; // Parity Bit
            #40 uart_reg = 1'b1;// Stop Bit                  
        end 
        
endmodule
