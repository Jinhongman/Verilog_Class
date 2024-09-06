
`timescale 1ns / 1ps

module dddownCounter(
    input  logic        clk,
    input  logic        reset,
    input  logic [3:0]  addr,
    input  logic        cs,
    input  logic        we,
    
    input  logic [31:0] wdata,
    output logic [31:0] rdata
    );
    
    logic w_clk_1kHz, start_sig;
    logic [31:0] COUNT_STR, COUNT, COUNT_EXT;

    always_ff @( posedge clk, posedge reset ) begin
        if(reset) begin
            COUNT_STR <= 32'b0;
            COUNT <= 32'b0;
            COUNT_EXT <= 32'b0;  
            start_sig <= 1'b0; 
        end else begin
            if(cs & we) begin
                case(addr[3:2]) 
                    2'b00 : COUNT_STR <= wdata;     
                    2'b01 : begin
                        if(COUNT_STR == 1'b1) begin
                            if(start_sig == 1'b0)begin
                                COUNT <= wdata;
                                COUNT_EXT <= 32'd0;
                                start_sig <= 1'b1;
                            end else if(w_clk_1kHz) begin
                                if(COUNT == 0)begin
                                    start_sig = 1'b0;
                                end else begin
                                    COUNT <= COUNT - 1;
                                end
                            end
                        end
                    end
                endcase
            end
        end
    end

    always_comb begin 
        case(addr[3:2])
            2'b00 : rdata = COUNT_STR;
            2'b01 : begin
                rdata = COUNT;
                if(COUNT == 32'd0) COUNT_EXT = 32'd1;
            end
            2'b10 : rdata = COUNT_EXT;
            default: rdata = 32'dx;
        endcase
    end

    clkDiv #(
        .MAX_COUNT(10)
    ) U_1kHz(
        .clk(clk),
        .reset(reset),
        .o_clk(w_clk_1kHz)
    );

endmodule
