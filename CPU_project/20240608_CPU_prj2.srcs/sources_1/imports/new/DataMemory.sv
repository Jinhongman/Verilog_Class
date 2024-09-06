`timescale 1ns / 1ps
`include "defines.sv"

module DataMemory (
    input  logic        clk,
    input  logic        we,
    input logic         ce,
    input  logic [ 7:0] addr,
    input  logic [31:0] wdata,
    input  logic [ 2:0] StoreType,
    input  logic [ 2:0] loadType,
    output logic [31:0] rdata
);
    logic [31:0] ram[0:2**8 - 1];

    always_ff @(posedge clk) begin : write
        if (ce & we) begin
            case (StoreType)
                `SB: ram[addr[7:2]][7:0] <= wdata[7:0];
                `SH: ram[addr[7:2]][15:0] <= wdata[15:0];
                `SW: ram[addr[7:2]] <= wdata[31:0];
                default: ram[addr[7:2]] <= wdata;
            endcase
        end
    end

    always_comb begin : Read
    if(ce & ~we) begin
        case (loadType)
            `LB: rdata = {{25{ram[addr[7:2]][7]}}, ram[addr[7:2]][6:0]};  //LB
            `LH: rdata = {{17{ram[addr[7:2]][15]}}, ram[addr[7:2]][14:0]};  //LH
            `LW: rdata = ram[addr[7:2]][31:0];  //LW
            `LBU: rdata = {24'd0, ram[addr[7:2]][7:0]};  //LBU
            `LHU: rdata = {16'd0, ram[addr[7:2]][15:0]};  //LHU
            default: rdata = ram[addr[7:2]];
        endcase
    end else begin
        rdata = 32'dz;
    end
    end
endmodule