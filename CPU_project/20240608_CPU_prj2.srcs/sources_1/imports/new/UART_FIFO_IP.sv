`timescale 1ns / 1ps

module UART_FIFO_IP (
    input  logic        clk,
    input  logic        reset,
    input  logic [ 3:0] addr,
    input  logic        cs,
    input  logic        we,
    
    input  logic [31:0] wData,
    output logic [31:0] rData,
    input  logic        rx,
    output logic        tx
);
    logic [7:0] w_tx_data, w_rx_data;
    logic w_rx_empty, w_tx_en;
    logic [31:0] TX_EN, TX, RX;

    always_ff @(posedge clk, posedge reset) begin : wdata
        if (reset) begin
            TX <= 32'b0;
            RX <= 32'b0;
            TX_EN <= 32'b0;
        end else begin
            if(!w_rx_empty) begin
                RX <= {24'b0, w_rx_data};
            end else if (cs & we) begin
                case (addr[3:2])  //write
                    2'b00: TX <= wData;  //0x00
                    2'b10: TX_EN <= wData;  //0x80
                    default: begin
                        TX <= 32'dx;
                        TX_EN <= 32'dx;
                    end
                endcase
            end
        end
    end

    always_comb begin : rdata
        case (addr[3:2])
            2'b01:   rData = RX; //0x40
            2'b10:   rData = TX_EN;
            default: rData = 32'dx;
        endcase
    end

    assign w_tx_data = TX[7:0];
    assign w_tx_en   = TX_EN[0];

    UART_FIFO U_uart_fifo (
        .clk(clk),
        .reset(reset),
        //tx
        .tx(tx),
        .tx_data(w_tx_data),
        .tx_en(w_tx_en),
        .tx_full(),
        //rx
        .rx(rx),
        .rx_data(w_rx_data),
        .rx_en(~w_rx_empty),
        .rx_empty(w_rx_empty)
    );
endmodule