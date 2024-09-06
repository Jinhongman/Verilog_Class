`timescale 1ns / 1ps

module UART_FIFO (
    input  logic clk,
    input  logic reset,
    //tx  
    output logic  tx,
    input  logic [7:0] tx_data,
    input  logic tx_en,
    output logic  tx_full,
    //rx  
    input  logic rx,
    output logic  [7:0] rx_data,
    input  logic rx_en,
    output logic  rx_empty
);

    wire w_tx_fifo_empty;
    wire [7:0] w_tx_fifo_rdata;
    wire w_tx_done, w_rx_done;
    wire [7:0] w_rx_data;
    //wire w_tx_rx_loop;

    FIFO #(
        .ADDR_WIDTH(3),
        .DATA_WIDTH(8)
    ) U_TX_fifo (
        .clk  (clk),
        .reset(reset),
        .wdata(tx_data),
        .wr_en(tx_en),
        .rd_en(w_tx_done),
        .full (tx_full),
        .empty(w_tx_fifo_empty),
        .rdata(w_tx_fifo_rdata)
    );
    FIFO #(
        .ADDR_WIDTH(3),
        .DATA_WIDTH(8)
    ) U_RX_fifo (
        .clk  (clk),
        .reset (reset),
        .wdata(w_rx_data),
        .wr_en(w_rx_done),
        .rd_en(rx_en),
        .full (),
        .empty(rx_empty),
        .rdata(rx_data)
    );

    UART U_uart (
        .clk     (clk),
        .reset   (reset),
        //transmitter
        .tx_start(~w_tx_fifo_empty),
        .tx_data (w_tx_fifo_rdata),
        .tx      (tx),
        .tx_done (w_tx_done),
        //receive
        .rx      (rx),
        .rx_data (w_rx_data),
        .rx_done (w_rx_done)
    );

endmodule
