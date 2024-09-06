`timescale 1ns/1ps

module DownCounter_IP (
    input  logic        clk,
    input  logic        reset,
    input  logic [ 3:0] addr,
    input  logic        cs,
    input  logic        we,
    input  logic [31:0] wData,
    output logic [31:0] rData
);
    logic start, finish;
    logic [13:0] i_data, o_data;

    logic [31:0] COUNT_STR, COUNT_IN, COUNT_OUT, COUNT_EXT;

    assign start = COUNT_STR[0];
    assign i_data = COUNT_IN;

    always_ff @( posedge clk, posedge reset ) begin 
        if(reset) begin
            COUNT_STR <= 0;
            COUNT_IN  <= 0;
            COUNT_OUT <= 0;
            COUNT_EXT <= 0;
        end else begin
            COUNT_OUT <= {18'd0, o_data};
            COUNT_EXT <= {31'd0, finish};
            if (cs & we) begin
                case (addr[3:2])   
                    2'b00 : COUNT_STR <= wData;
                    2'b01 : COUNT_IN <= wData; 
                    2'b11 : COUNT_IN <= 32'd0;
                    default: begin
                        COUNT_STR <= 32'bx;
                        COUNT_IN <= 32'bx;
                    end
                endcase
            end
        end    
    end

    always_comb begin 
        case (addr[3:2])
            2'b10: rData = COUNT_OUT; 
            2'b11: rData = COUNT_EXT;
            default: rData = 32'bx;
        endcase
    end

    DownCounterTop U_DC_TOP(
        .clk(clk),
        .reset(reset),
        .start(start),
        .i_data(i_data),
        .o_data(o_data),
        .finish(finish)
    );
    
endmodule

module DownCounterTop (
    input logic clk,
    input logic reset,
    input logic start,
    input logic [13:0] i_data,
    output logic [13:0] o_data,
    output logic finish
);
    logic w_clk_1Hz;

    clkDiv #(
        .MAX_COUNT(100_000_000)
    ) U_pre_1Hz (
        .clk  (clk),
        .reset(reset),
        .o_clk(w_clk_1Hz)
    );
    DownCounter3 u_DownCounter (
        .clk(clk),
        .reset(reset),
        .tick(w_clk_1Hz),
        .start(start),
        .i_data(i_data),
        .o_data(o_data),
        .finish(finish)
    );
endmodule

module DownCounter3 (
    input logic clk,
    input logic reset,
    input logic tick,
    input logic start,
    input logic [13:0] i_data,
    output logic [13:0] o_data,
    output logic finish
);

    logic [13:0] counter_reg, counter_next;
    logic finish_reg, finish_next;
    logic start_reg, start_next, start_flag;

    assign o_data = counter_reg;
    assign finish = finish_reg;

    always_ff @(posedge clk, posedge reset) begin : blockName
        if (reset) begin
            start_reg <= 0;
            counter_reg <= 0;
            start_flag <= 0;
            finish_reg <= 1'b0;

        end else begin
            start_reg <= start_next;
            counter_reg <= counter_next;
            finish_reg <= finish_next;
        end
    end

    always_comb begin : down_counter
        counter_next = counter_reg;
        start_next = start_reg;
        finish_next = finish_reg;

        if(start && (start_reg == 1'b0)) begin
            counter_next = i_data;
            start_next = 1'b1;
        end 
        else if(tick && start_reg) begin
            if(counter_reg != 0) begin
                counter_next = counter_reg - 1;
                finish_next = 1'b0;
            end else if(counter_reg == 0) begin
                finish_next = 1'b1;
                start_next = 1'b0;
            end 
        end
    end
endmodule