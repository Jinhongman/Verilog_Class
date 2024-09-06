`timescale 1ns / 1ps

module UART(
input  logic clk,
input  logic reset,
//transmitter
input  logic tx_start,
input  logic [7:0] tx_data,
output logic  tx,
output logic  tx_done,
//receive
input  logic rx,
output logic  [7:0]rx_data,
output logic  rx_done
    );

    wire w_br_tick;

buadrate_generator U_BR_GEN (
    .clk(clk),
    .reset(reset),
    .br_tick(w_br_tick)
);
trasmitter U_TX(
    .clk(clk),
    .reset(reset),
    .tx_start(tx_start),
    .br_tick(w_br_tick),
    .tx_data(tx_data),
    .tx_done(tx_done),
    .tx(tx)
);
receive U_receive (
    .clk(clk),
    .reset(reset),
    .br_tick(w_br_tick),
    .rx(rx),
    .rx_data(rx_data),
    .rx_done(rx_done)
);
endmodule

module buadrate_generator (
    input  logic clk,
    input  logic reset,
    output logic br_tick
);
    reg [$clog2(100_000_000/9600 / 16) - 1 :0] counter_reg, counter_next;
    reg tick_reg, tick_next;

    assign br_tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            tick_reg <= 0;
            counter_reg <= 0;
        end else begin
            tick_reg <= tick_next;
            counter_reg <= counter_next;
        end
    end

    always @(*) begin
        counter_next = counter_reg;
        // 계산된 결과 값으로 회로가 만들어진다. 나누기 회로가 만들어지지 않는다. 상수이기 때문이다. 
       // if(counter_reg == 3) begin //simulation 용
       if(counter_reg == (100_000_000 / 9600 / 16) - 1) begin // 9600의 16배 해주기(oversampling)
            counter_next = 0;
            tick_next = 1'b1;
        end else begin
            counter_next = counter_reg + 1;
            tick_next = 1'b0;
        end
    end
endmodule

module trasmitter (
    input  logic clk,
    input  logic reset,
    input  logic tx_start,
    input  logic br_tick,
    input  logic [7:0] tx_data,
    output logic tx_done,
    output logic tx
);
localparam  IDLE = 0, START = 1, DATA = 2, STOP = 3;

reg [1:0] state, next_state;
reg [7:0] tx_data_reg, tx_data_next;
reg tx_reg, tx_next;
reg [3:0] br_cnt_reg, br_cnt_next;
reg [2:0] data_bit_cnt_reg, data_bit_cnt_next;
reg tx_done_reg;

assign tx = tx_reg;
assign tx_done = tx_done_reg;

always @(posedge clk, posedge reset) begin
    if(reset) begin
        state <= IDLE;
        tx_data_reg <= 0;
        tx_reg <= 0;
        br_cnt_reg <= 0;
        data_bit_cnt_reg <= 0;
   //     tx_done_reg <= 0;
    end else begin
        state <= next_state;
        tx_data_reg <= tx_data_next;
        tx_reg <= tx_next;
        br_cnt_reg <= br_cnt_next;
        data_bit_cnt_reg <= data_bit_cnt_next;
  //      tx_done_reg <= tx_done_next;
    end
end

always @(*) begin

    next_state = state;
    tx_next = tx_reg;
    tx_data_next = tx_data_reg;
    br_cnt_next = br_cnt_reg;
    data_bit_cnt_next = data_bit_cnt_reg;
  //  tx_done_next = tx_done_reg;

    case (state)
        IDLE: begin
        tx_done_reg = 1'b0;
        tx_next = 1'b1;    
        if(tx_start) begin
        next_state = START; 
        tx_data_next = tx_data;
        br_cnt_next = 0;
        data_bit_cnt_next = 0;
            end
        end 
    START : begin
        tx_next = 1'b0;
        if(br_tick) begin
            if(br_cnt_reg == 15) begin
                next_state = DATA;
                br_cnt_next = 0;
            end
            else begin
                br_cnt_next = br_cnt_reg + 1;
            end
        end
    end
    DATA : begin
        tx_next = tx_data_reg [0];
        if(br_tick) begin
            if(br_cnt_reg == 15) begin
                br_cnt_next = 0;
                if(data_bit_cnt_reg == 7) begin
                     next_state = STOP;
                      br_cnt_next = 0;
                end 
                else begin
                    data_bit_cnt_next = data_bit_cnt_reg + 1;
                    tx_data_next = {1'b0, tx_data_reg[7:1]};
                     end
                end else begin
                br_cnt_next = br_cnt_reg + 1;
            end
        end
    end
    STOP: begin
        tx_next = 1'b1;
        if(br_tick) begin
            if(br_cnt_reg == 15) begin
                br_cnt_next = 0;
                tx_done_reg = 1'b1;
                next_state = IDLE;
            end else begin
                br_cnt_next = br_cnt_reg + 1;
            end
        end
    end
    endcase
end
endmodule

module receive (
    input  logic clk,
    input  logic reset,
    input  logic br_tick,
    input  logic rx,
    output logic  [7:0] rx_data,
    output logic  rx_done
);
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;

    reg [1:0] state, next_state;
    reg [7:0] rx_data_reg, rx_data_next;
    reg rx_done_reg, rx_done_next;
    reg [3:0] br_cnt_reg, br_cnt_next;
    reg [2:0] data_bit_cnt_reg, data_bit_cnt_next;

    assign rx_data = rx_data_reg;
    assign rx_done = rx_done_reg;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= 0;
            rx_data_reg <= 0;
            rx_done_reg <= 0;
            br_cnt_reg <= 0;
            data_bit_cnt_reg <= 0;
        end else begin
            state <= next_state;
            rx_data_reg <= rx_data_next;
            rx_done_reg <= rx_done_next;
            br_cnt_reg <= br_cnt_next;
            data_bit_cnt_reg <= data_bit_cnt_next;
        end
    end

    always @(*) begin
        next_state = state;
        rx_data_next = rx_data_reg;
        rx_done_next = rx_done_reg;
        br_cnt_next = br_cnt_reg;
        data_bit_cnt_next = data_bit_cnt_reg;
        case (state)
           IDLE : begin 
             rx_done_next = 1'b0;
            if(rx == 1'b0)begin
                br_cnt_next = 0;
                rx_data_next = 0;
                data_bit_cnt_next = 0;
                next_state = START;
            end
           end
            START: begin
                if(br_tick) begin
                    if(br_cnt_reg == 7) begin
                        next_state = DATA;
                        br_cnt_next = 0;
                    end else begin
                        br_cnt_next = br_cnt_reg + 1;
                    end
                end
            end
            DATA: begin
                if(br_tick) begin
                    if(br_cnt_reg == 15) begin
                        br_cnt_next = 0;
                        rx_data_next = {rx ,rx_data_reg[7:1]};

                        if(data_bit_cnt_reg == 7) begin
                            data_bit_cnt_next = 0;
                            next_state = STOP;
                            br_cnt_next = 0;
                        end else begin
                            data_bit_cnt_next = data_bit_cnt_reg + 1; 
                        end
                    end else begin
                        br_cnt_next = br_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                
                if(br_tick) begin
                    if(br_cnt_reg == 15) begin
                        br_cnt_next = 0; 
                        next_state = IDLE;
                        rx_done_next = 1'b1;
                    end else begin
                        br_cnt_next = br_cnt_reg + 1;
                    end
                end
            end
        endcase
    end
endmodule

