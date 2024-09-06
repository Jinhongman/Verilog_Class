`timescale 1ns / 1ps

module CPU_Core(
    input logic clk,
    input logic reset,
    input logic [31:0] machineCode,
    output logic [31:0] instrMemRAddr,
    output logic [31:0] dataMemRAddr,
    input  logic [31:0] dataMemRData,
    output logic        dataMemWe,
    output  logic [31:0] dataMemWData,
    output logic [2:0] loadType,
    output logic [2:0] StoreType
    );

    logic w_regFilewe, w_AluScrMuxSel, w_PCSrcMuxSel, w_RsPcMuxSel;
    logic [2:0] w_RFWriteDataScrMuxSel;
    logic [3:0] w_aluControl;
    logic [2:0] w_extType;
    logic w_branch;

ControlUnit U_ControlUnit (
    .op(machineCode[6:0]),
    .funct3(machineCode[14:12]),
    .funct7(machineCode[31:25]),
    .regFilewe(w_regFilewe),
    .AluScrMuxSel(w_AluScrMuxSel),
    .RFWiteDataScrMuxSel(w_RFWriteDataScrMuxSel),
    .dataMemWe(dataMemWe),
    .extType(w_extType),
    .loadType(loadType),
    .StoreType(StoreType),
    .aluControl(w_aluControl),
    .branch(w_branch), 
    .PCSrcMuxSel(w_PCSrcMuxSel),
    .RsPcMuxSel(w_RsPcMuxSel)
);

Datapath  U_DataPath(
   .clk(clk),
    .reset(reset),
    .machineCode(machineCode),
    .RegFilewe(w_regFilewe),
    .aluControl(w_aluControl),
    .instrMemRAddr(instrMemRAddr),
    .dataMemRAddr(dataMemRAddr),
    .dataMemRData(dataMemRData),
    .AluScrMuxSel(w_AluScrMuxSel),
    .extType(w_extType),
    .RFWiteDataScrMuxSel(w_RFWriteDataScrMuxSel),
    .dataMemWData(dataMemWData),
    .branch(w_branch),
    .PCSrcMuxSel(w_PCSrcMuxSel),
    .RsPcMuxSel(w_RsPcMuxSel)
);
endmodule
