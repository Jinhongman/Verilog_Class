`timescale 1ns / 1ps

module fndController (
    input logic clk,
    input logic reset,
    input logic [13:0] digit,
    output logic [7:0] fndFont,
    output logic [3:0] fndCom
);

    logic [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    logic [3:0] w_digit;
    logic [1:0] w_countOut;
    logic w_clk_1kHz;

    clkDiv #(
        .MAX_COUNT(100_000)
    ) U_prescaler (  // 여기서 값 선언 안 하면 default값 들어감
        .clk  (clk),
        .reset(reset),
        .o_clk(w_clk_1kHz)
    );

    counter U_clkCounter (
        .clk  (w_clk_1kHz),
        .reset(reset),
        .count(w_countOut)
    );


    twoTofour_decoder U_Decoder_2x4 (
        .x(w_countOut),
        .y(fndCom)
    );

    digitSplitter U_DigitSplitter (
        .i_digit(digit),
        .o_digit_1(w_digit_1),
        .o_digit_10(w_digit_10),
        .o_digit_100(w_digit_100),
        .o_digit_1000(w_digit_1000)
    );

    mux_41 U_Mux_4x1 (

        .sel(w_countOut),
        .a (w_digit_1),
        .b (w_digit_10),
        .c (w_digit_100),
        .d (w_digit_1000),
        .y  (w_digit)
    );

    BCDtoSEG U_BcdToSeg (
        .bcd(w_digit),
        .seg(fndFont)
    );
endmodule


module digitSplitter (
    input  logic [31:0] i_digit,
    output logic [ 3:0] o_digit_1,
    output logic [ 3:0] o_digit_10,
    output logic [ 3:0] o_digit_100,
    output logic [ 3:0] o_digit_1000
);
    assign o_digit_1    = i_digit % 10;
    assign o_digit_10   = i_digit / 10 % 10;
    assign o_digit_100  = i_digit / 100 % 10;
    assign o_digit_1000 = i_digit / 1000 % 10;
endmodule



module mux_41 (
    input  logic [1:0] sel,
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic [3:0] c,
    input  logic [3:0] d,
    output logic [3:0] y
);
    always_comb begin
        case (sel)
            2'b00:   y = a;
            2'b01:   y = b;
            2'b10:   y = c;
            2'b11:   y = d;
            default: y = a;
        endcase
    end
endmodule




module BCDtoSEG (
    input  logic    [3:0]  bcd,
    output logic    [7:0]  seg
);
    always_comb begin
        case (bcd)
            4'h0 : seg = 8'hc0;
            4'h1 : seg = 8'hf9;
            4'h2 : seg = 8'ha4;
            4'h3 : seg = 8'hb0;
            4'h4 : seg = 8'h99;
            4'h5 : seg = 8'h92;
            4'h6 : seg = 8'h82;
            4'h7 : seg = 8'hf8;
            4'h8 : seg = 8'h80;
            4'h9 : seg = 8'h90;
            4'ha : seg = 8'h88;
            4'hb : seg = 8'h83;
            4'hc : seg = 8'hc6;
            4'hd : seg = 8'ha1;
            4'he : seg = 8'h86;
            4'hf : seg = 8'h8e;
            default: seg = 8'hff;           
        endcase
    end    
endmodule



module twoTofour_decoder (
    input  logic [1:0] x,
    output logic [3:0] y
);
    always @(x) begin
        case (x)

            2'b00:   y = 4'b1110;
            2'b01:   y = 4'b1101;
            2'b10:   y = 4'b1011;
            2'b11:   y = 4'b0111;
            default: y = 4'b1111;
        endcase
    end
endmodule

module counter (
    input  logic       clk,
    input  logic       reset,
    output logic [1:0] count
);
    reg [1:0] counter;
    assign count = counter;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
        end else begin
            if (counter == 3) begin
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule



module clkDiv #(
    parameter MAX_COUNT = 100
) (
    input  logic clk,
    input  logic reset,
    output logic o_clk
);
    reg [$clog2(MAX_COUNT)-1:0] counter = 0;
    reg r_tick = 0;

    assign o_clk = r_tick;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
        end else begin
            if (counter == (MAX_COUNT - 1)) begin
                counter <= 0;
                r_tick  <= 1'b1;
            end else begin
                counter <= counter + 1;
                r_tick  <= 1'b0;
            end
        end
    end
endmodule

