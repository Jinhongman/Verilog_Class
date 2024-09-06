`timescale 1ns / 1ps

module tb_tb();
    logic        clk;
    logic       reset;
    logic [3:0]  addr;
    logic        cs;
    logic        we;
    logic [31:0] wData;
 //   logic        start;
    logic [31:0] rData;
            /*
    logic  [3:0]      inPort;
    logic  [3:0]     outPort;
    logic rx;
    logic tx;
    logic [3:0] fndCom;
    logic [7:0] fndFont;
    logic btnU; */
/*
    downCounter dut(
        .clk(clk),
        .reset(reset),
        .wdata(wdata),
        .start(start),
        .rdata(rdata),
        .o_finish(o_finish)
    );
*/
 /*   RV32I_MCU dut (
        .*
    );
*/
/*
    DownCounter_IP dut(
        .*
    );
*/
    always #5 clk = ~clk;



    initial begin
             clk = 1'b0; reset = 1'b1;
        #10  reset = 1'b0; cs=1'b1; we = 1'b1;
             addr = 4'b0000; wData = 4'd1;
        #50  addr = 4'b0100; wData = 4'd10;
        #50  addr = 4'b1000;
        #500 addr = 4'b1100; wData = 4'd10;
    end

endmodule
