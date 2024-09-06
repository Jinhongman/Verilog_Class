`timescale 1ns / 1ps

`include "defines.sv"

module ControlUnit (
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic       regFilewe,
    output logic       AluScrMuxSel,
    output logic [2:0] RFWiteDataScrMuxSel,
    output logic       dataMemWe,
    output logic [2:0] extType,
    output logic [2:0] loadType,
    output logic [2:0] StoreType,
    output logic       branch,
    output logic [3:0] aluControl,
    output  logic        PCSrcMuxSel,
    output  logic        RsPcMuxSel
);

    logic [11:0] controls;
    assign {regFilewe, AluScrMuxSel, RFWiteDataScrMuxSel, dataMemWe , extType, branch,PCSrcMuxSel, RsPcMuxSel} = controls;

    always_comb begin : main_decoder
        case (op)
            //regFilewe, AluScrMuxSel, RFWiteDataScrMuxSel, dataMemWe, extType, RFPCMuxSel,PCSrcMuxSel, RsPcMuxSel
            `OP_TYPE_R:  controls = 12'b1_0_000_0_xxx_0_0x;
            `OP_TYPE_IL: controls = 12'b1_1_001_0_000_0_0x;
            `OP_TYPE_I:  begin
                case (funct3)
                   3'b001 : controls = 12'b1_1_000_0_100_0_0x; // SLLI
                   3'b101 : controls = 12'b1_1_000_0_100_0_0x; // SRLI, SRAI
                    default: controls = 12'b1_1_000_0_000_0_0x; // 나머지 I-Type
                endcase
            end
            `OP_TYPE_S:  controls = 12'b0_1_xxx_1_001_0_0x;
            `OP_TYPE_B:  controls = 12'b0_0_xxx_0_010_1_0x;
            `OP_TYPE_J:  controls = 12'b1_x_100_0_101_0_11;
            `OP_TYPE_JI: controls = 12'b1_x_100_0_000_0_10;
            `OP_TYPE_U:  controls = 12'b1_x_010_0_011_0_0x;
            `OP_TYPE_UA: controls = 12'b1_x_011_0_011_0_01;
            default:     controls = 12'bx;
        endcase
    end
    always_comb begin : alu_control_signal
        case (op)
            `OP_TYPE_R: aluControl = {funct7[5], funct3};
            `OP_TYPE_IL: aluControl = {1'b0, 3'b000};
            `OP_TYPE_I: begin
                case (funct3)
                   3'b001 : aluControl = {funct7[5], funct3};
                   3'b101 : aluControl = {funct7[5], funct3};
                    default: aluControl = {1'b0, funct3};
                endcase
            end
            `OP_TYPE_S: aluControl = {1'b0, 3'b000};
            `OP_TYPE_B: aluControl = {1'b0, funct3};
            default: aluControl = 4'bx;
        endcase
    end

    always_comb begin : Byte_load
        case (op)
           `OP_TYPE_IL : loadType = funct3;
           `OP_TYPE_S : StoreType = funct3;
            default: begin
                loadType = 3'dx;
                StoreType = 3'dx;
            end
        endcase
    end
endmodule
