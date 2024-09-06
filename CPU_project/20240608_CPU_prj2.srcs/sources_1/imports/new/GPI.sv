`timescale 1ns / 1ps

module GPI (
    input  logic        clk,
    input  logic        addr,
    input  logic        cs,
    input  logic        we,

    output logic [31:0] rdata,
    input  logic [ 3:0] inPort
);
    logic [31:0] IDR;
    
    assign rdata = IDR;

    always @(*) begin
        if (cs & ~we) IDR[3:0] <= inPort;
    end
endmodule

