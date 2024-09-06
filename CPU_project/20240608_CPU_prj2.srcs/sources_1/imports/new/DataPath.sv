`timescale 1ns / 1ps

`include "defines.sv"
module Datapath (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] machineCode,
    input  logic        RegFilewe,
    input  logic [ 3:0] aluControl,
    output logic [31:0] instrMemRAddr,
    output logic [31:0] dataMemRAddr,
    input  logic [31:0] dataMemRData,
    output logic [31:0] dataMemWData,
    input  logic        AluScrMuxSel,
    input  logic [ 2:0] RFWiteDataScrMuxSel,    
    input  logic [ 2:0] extType,
    input  logic        branch,
    input  logic        PCSrcMuxSel,
    input  logic        RsPcMuxSel
);
    logic [31:0]
        w_ALUresult,
        w_RegFileRData1,
        w_RegFileRData2,
        w_PC_Data,
        w_PCScrAdderOut,
        w_Adder_Rs1_PC_MuxOut,
        w_RFWriteData;
    logic [31:0]
        w_AluSrcMuxOut,
        w_extendOut,
        w_RFWriteDataScrMuxOut,
        w_PCAdderSrcMuxOut,
        w_Adder_PC_Extend_Data;
    logic w_PCAdderSrcMuxSel;
    logic w_btaken;

    assign w_PCAdderSrcMuxSel = branch & w_btaken;
    assign dataMemRAddr = w_ALUresult;
    assign dataMemWData = w_RegFileRData2;

    DataPath_Register U_PC (
        .clk  (clk),
        .reset(reset),
        .d    (w_PC_Data),
        .q    (instrMemRAddr)
    );
    mux_2x1 U_PCAdderSrcMux (
        .sel(w_PCAdderSrcMuxSel),
        .a  (32'd4),
        .b  (w_extendOut),
        .y  (w_PCAdderSrcMuxOut)
    );
    adder U_Adder_PC (
        .a(instrMemRAddr),
        .b(w_PCAdderSrcMuxOut),
        .y(w_PCScrAdderOut)
    );
    mux_2x1 U_PCScrMux (
        .sel(PCSrcMuxSel),
        .a  (w_PCScrAdderOut),
        .b  (w_Adder_PC_Extend_Data),
        .y  (w_PC_Data)
    );
    RegisterFile U_RegisterFile (
        .clk   (clk),
        .we    (RegFilewe),
        .RAddr1(machineCode[19:15]),
        .RAddr2(machineCode[24:20]),
        .WAddr (machineCode[11:7]),
        .WData (w_RFWriteData),
        .RData1(w_RegFileRData1),
        .RData2(w_RegFileRData2)
    );
    mux_2x1 U_ALUScrMux (
        .sel(AluScrMuxSel),
        .a  (w_RegFileRData2),
        .b  (w_extendOut),
        .y  (w_AluSrcMuxOut)
    );

    ALU U_ALU (
        .a         (w_RegFileRData1),
        .b         (w_AluSrcMuxOut),
        .aluControl(aluControl),
        .btaken    (w_btaken),
        .result    (w_ALUresult)
    );
    mux_5x1 U_RFWDataScrMux (
        .sel(RFWiteDataScrMuxSel),
        .a  (w_ALUresult),
        .b  (dataMemRData),
        .c  (w_extendOut),
        .d  (w_Adder_PC_Extend_Data),
        .e  (w_PCScrAdderOut),
        .y  (w_RFWriteData)
    );
    mux_2x1 U_RS1_PC_MUX (
        .sel(RsPcMuxSel),
        .a  (w_RegFileRData1),
        .b  (instrMemRAddr),
        .y  (w_Adder_Rs1_PC_MuxOut)
    );
    adder U_Adder_PC_Extend (
        .a(w_Adder_Rs1_PC_MuxOut),
        .b(w_extendOut),
        .y(w_Adder_PC_Extend_Data)
    );
    extend U_Extend (
        .extType(extType),
        .instr  (machineCode[31:7]),
        .immext (w_extendOut)
    );
endmodule

module RegisterFile (
    input  logic        clk,
    input  logic        we,
    input  logic [ 4:0] RAddr1,
    input  logic [ 4:0] RAddr2,
    input  logic [ 4:0] WAddr,
    input  logic [31:0] WData,
    output logic [31:0] RData1,
    output logic [31:0] RData2
);
    logic [31:0] RegFile[0:31];
    initial begin
        RegFile[0] = 32'd0;
        RegFile[1] = 32'd1;
        RegFile[2] = 32'd2;
        RegFile[3] = 32'd3;
        RegFile[4] = 32'd4;
        RegFile[5] = 32'd5;
    end
    always_ff @(posedge clk) begin
        if (we) RegFile[WAddr] <= WData;
    end
    assign RData1 = (RAddr1 != 0) ? RegFile[RAddr1] : 0;
    assign RData2 = (RAddr2 != 0) ? RegFile[RAddr2] : 0;
endmodule

module DataPath_Register (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] d,
    output logic [31:0] q
);
    always_ff @(posedge clk, posedge reset) begin : blockName
        if (reset) q <= 0;
        else q <= d;
    end
endmodule

module ALU (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [ 3:0] aluControl,
    output logic        btaken,
    output logic [31:0] result
);
    always_comb begin
        case (aluControl)
            `ADD: result = a + b;
            `SUB: result = a - b;
            `SLL: result = a << b;
            `SRL: result = a >> b;
            `SRA: result = $signed(a) >>> b;
            `SLT: result = ($signed(a)  < $signed(b)) ? 1 : 0;
            `SLTU: result = (a < b) ? 1 : 0;
            `XOR: result = a ^ b;
            `OR: result = a | b;
            `AND: result = a & b;
            default: result = 32'bx;
        endcase
    end

    always_comb begin : comparator
        case (aluControl[2:0])
            3'b000:  btaken = (a == b);  // BEQ
            3'b001:  btaken = (a != b);  // BNE
            3'b100:  btaken = (a < b);  // BLT
            3'b101:  btaken = (a >= b);  // BGE
            3'b110:  btaken = (a < b);  // BLTU
            3'b111:  btaken = (a >= b);  // BGEU
            default: btaken = 1'bx;
        endcase

    end
endmodule

module adder (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);
    assign y = a + b;
endmodule

module extend (
    input  logic [ 2:0] extType,
    input  logic [31:7] instr,
    output logic [31:0] immext
);
    always_comb begin
        case (extType)
            3'b000: immext = {{21{instr[31]}}, instr[30:20]};  // I-type
            3'b100: immext = {{27{instr[24]}}, instr[24:20]};  // I-ype_shift
            3'b001:
            immext = {{21{instr[31]}}, instr[30:25], instr[11:7]};  // S-Type
            3'b010: begin
                immext = {
                    {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0
                };
            end  //B-Type
            3'b011: immext = {instr[31:12], 12'd0};  // U-Type, UI-Type
            3'b101:
            immext = {
                {12{instr[31]}},
                instr[19:12],
                instr[20],
                instr[30:25],
                instr[24:21],
                1'b0
            };  // J-Type
            default: immext = 32'bx;
        endcase
    end
endmodule

module mux_2x1 (
    input  logic        sel,
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);

    always_comb begin
        case (sel)
            1'b0: y = a;
            1'b1: y = b;
            default: y = 32'bx;
        endcase
    end
endmodule

module mux_5x1 (
    input  logic [ 2:0] sel,
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [31:0] c,
    input  logic [31:0] d,
    input  logic [31:0] e,
    output logic [31:0] y
);

    always_comb begin
        case (sel)
            3'b000:  y = a;
            3'b001:  y = b;
            3'b010:  y = c;
            3'b011:  y = d;
            3'b100:  y = e;
            default: y = 32'bx;
        endcase
    end
endmodule
