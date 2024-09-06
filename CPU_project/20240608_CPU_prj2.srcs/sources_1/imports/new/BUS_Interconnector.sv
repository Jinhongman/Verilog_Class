`timescale 1ns / 1ps

module BUS_Interconnector (
    input  logic [31:0] address,
    output logic [10:0] slave_sel,
    input  logic [31:0] slave_rdata1,
    input  logic [31:0] slave_rdata2,
    input  logic [31:0] slave_rdata3,
    input  logic [31:0] slave_rdata4,
    input  logic [31:0] slave_rdata5,
    input  logic [31:0] slave_rdata6,
    input  logic [31:0] slave_rdata7,
    input  logic [31:0] slave_rdata8,
    input  logic [31:0] slave_rdata9,
    input  logic [31:0] slave_rdata10,
    input  logic [31:0] slave_rdata11,

    output logic [31:0] master_rdata
);
    DECODER U_Decoder (
        .x(address),
        .y(slave_sel)
    );
    BUS_MUX U_MUX (
        .sel(address),
        .slave_rdata1(slave_rdata1),
        .slave_rdata2(slave_rdata2),
        .slave_rdata3(slave_rdata3),
        .slave_rdata4(slave_rdata4),
        .slave_rdata5(slave_rdata5),
        .slave_rdata6(slave_rdata6),
        .slave_rdata7(slave_rdata7),
        .slave_rdata8(slave_rdata8),
        .slave_rdata9(slave_rdata9),
        .slave_rdata10(slave_rdata10),
        .slave_rdata11(slave_rdata11),
        .y  (master_rdata)
    );
endmodule

module DECODER (
    input  logic [31:0] x,
    output logic [10:0] y
);
    always_comb begin : decoder
        case (x[31:8])
            24'h0000_10: y = 11'b000_0000_0001;  //RAM
            24'h0000_20: y = 11'b000_0000_0010;  //GPI
            24'h0000_21: y = 11'b000_0000_0100;  //GPO
            24'h0000_22: y = 11'b000_0000_1000;  //GPIOA
            24'h0000_23: y = 11'b000_0001_0000;  //GPIOB
            24'h0000_24: y = 11'b000_0010_0000;  //GPIOC
            24'h0000_25: y = 11'b000_0100_0000;  //GPIOD
            24'h0000_30: y = 11'b000_1000_0000;  //FND IP
            24'h0000_40: y = 11'b001_0000_0000;  //UART IP
            24'h0000_50: y = 11'b010_0000_0000;  //Button IP
            24'h0000_60: y = 11'b100_0000_0000;  //Counter_start IP
       
            default: y = 11'd0;
        endcase
    end
endmodule

module BUS_MUX (
    input  logic [31:0] sel,
    input  logic [31:0] slave_rdata1,
    input  logic [31:0] slave_rdata2,
    input  logic [31:0] slave_rdata3,
    input  logic [31:0] slave_rdata4,
    input  logic [31:0] slave_rdata5,
    input  logic [31:0] slave_rdata6,
    input  logic [31:0] slave_rdata7,
    input  logic [31:0] slave_rdata8,
    input  logic [31:0] slave_rdata9,
    input  logic [31:0] slave_rdata10,
    input  logic [31:0] slave_rdata11,
    output logic [31:0] y
);
    always_comb begin : decoder
        case (sel[31:8])
            24'h0000_10: y = slave_rdata1;
            24'h0000_20: y = slave_rdata2;
            24'h0000_21: y = slave_rdata3;
            24'h0000_22: y = slave_rdata4;
            24'h0000_23: y = slave_rdata5;
            24'h0000_24: y = slave_rdata6;
            24'h0000_25: y = slave_rdata7;
            24'h0000_30: y = slave_rdata8;
            24'h0000_40: y = slave_rdata9;
            24'h0000_50: y = slave_rdata10;
            24'h0000_60: y = slave_rdata11;
            default: y = 32'd0;
        endcase
    end
endmodule
