`timescale 1ns / 1ps

module GPIO (
    input  logic        clk,
    input  logic        reset,
    input  logic [ 3:0] addr,
    input  logic        cs,
    input  logic        we,
    input  logic [31:0] wData,
    output logic [31:0] rData,
    inout  logic [ 3:0] IOPort
);
    logic [31:0] MODER, IDR, ODR;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            MODER <= 32'b0;
            ODR   <= 32'b0;
        end else begin
            if (cs & we) begin
                case (addr[3:2])  //4단위로 나누기 위해
                    2'b00: MODER <= wData;  //0x00
                    2'b10: ODR <= wData;  // 0x08
                    default: begin
                        MODER <= 32'dx;
                        ODR   <= 32'dx;
                    end
                endcase
            end
        end
    end

    always @(*) begin
        case (addr[3:2])
            2'b00:   rData = MODER;  //0x00
            2'b01:   rData = IDR;  //0x04
            2'b10:   rData = ODR;  //0x08
            default: rData = 32'bx;
        endcase
    end
    
    //IDR
    always @(*) begin
        IDR[0] = MODER[0] ? 1'bz : IOPort[0];
        IDR[1] = MODER[1] ? 1'bz : IOPort[1];
        IDR[2] = MODER[2] ? 1'bz : IOPort[2];
        IDR[3] = MODER[3] ? 1'bz : IOPort[3];
    end
    
    // ODR
    assign IOPort[0] = MODER[0] ? ODR[0] : 1'bz;
    assign IOPort[1] = MODER[1] ? ODR[1] : 1'bz;
    assign IOPort[2] = MODER[2] ? ODR[2] : 1'bz;
    assign IOPort[3] = MODER[3] ? ODR[3] : 1'bz;
endmodule


