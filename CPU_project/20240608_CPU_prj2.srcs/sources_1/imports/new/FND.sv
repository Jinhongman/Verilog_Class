
`timescale 1ns / 1ps

module FND (
    input  logic        clk,
    input  logic        reset,
    input  logic        addr,
    input  logic        cs,
    input  logic        we,

    input  logic [31:0] wData,
    output logic [31:0] rData,
    output logic [ 3:0] fndCom,
    output logic [ 7:0] fndFont
);

    logic [13:0] digit;
    logic [31:0] FND;

always_ff @( posedge clk, posedge reset ) begin : blockName
    if(reset) begin
        FND <= 0;
    end else begin
        if(we & cs) begin
            FND <= wData;
        end
    end
end

assign rData = FND; 
assign digit = FND[13:0];

    fndController U_fndController (
        .clk(clk),
        .reset(reset),
        .digit(digit),
        .fndFont(fndFont),
        .fndCom(fndCom)
    );
endmodule

