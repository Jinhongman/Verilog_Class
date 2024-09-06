`timescale 1ns / 1ps

module downCounter(
    input  logic        clk,
    input  logic        reset,
    input  logic [3:0]  addr,
    input  logic        cs,
    input  logic        we,
    
    input  logic [31:0] wdata,
    output logic [31:0] rdata
    );
    
    logic w_clk_1kHz, start_sig, end_sig;
    logic [31:0] COUNT_STR, COUNT_WDT, COUNT_RDT, COUNT_EXT;

    always_ff @( posedge clk, posedge reset ) begin
        if(reset) begin
            COUNT_STR <= 32'b0;
            COUNT_WDT <= 32'b0;
            COUNT_RDT <= 32'b0;
            COUNT_EXT <= 32'b0;  
            start_sig <= 1'b0; 
        end else begin
            if(cs & we) begin
                 case(addr[3:2]) 
                    2'b00 : COUNT_STR <= wdata;     
                    2'b01 : begin
                        if(start_sig == 1'b0) begin
                            COUNT_WDT <= wdata;
                            //COUNT_EXT <= 32'd0;
                            start_sig <= 1'b1;
                        end else begin
                            if(start_sig & w_clk_1kHz) begin
                                if(COUNT_WDT == 0)begin
                                    COUNT_EXT <= 32'd1;
                                    start_sig <= 1'b0;
                                end else begin
                                    COUNT_RDT <= COUNT_WDT - 1;
                                    COUNT_WDT <= COUNT_RDT;
                                end
                            end
                        end
                    end     
                endcase
            end 
        end
    end
/*
    always_comb begin 
        if(start) start_sig = 1'b1;
    end*/

    always_comb begin 
        case(addr[3:2])
            2'b10 : rdata = COUNT_RDT;
            2'b11 : rdata = COUNT_EXT;
            default: rdata = 32'dx;
        endcase
    end

    clkDiv #(
        .MAX_COUNT(5_000_000)
    ) U_1kHz(
        .clk(clk),
        .reset(reset),
        .o_clk(w_clk_1kHz)
    );

endmodule

