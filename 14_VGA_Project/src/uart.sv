`timescale 1ns / 1ps

module uart(
    input  logic        clk,
    input  logic        reset,
    input  logic        uart_rx,
    output logic        uart_tx,
    // Pxl data
    input  logic        done_cap,
    input  logic [11:0] rData_cap,
    output logic [$clog2(80*110)-1:0] rAddr_cap
);

    // uart_rx
    logic rx_done;
    logic [7:0] rx_data;
    // uart_tx
    logic b_tick;
    logic tx_busy;
    logic tx_done;
    // fifo rx
    logic [7:0] fifo_rx_out;
    logic fifo_rx_empty;
    logic fifo_rx_pop;
    // fifo tx
    logic tx_start;
    logic [7:0] tx_data;
    logic [7:0] fifo_tx_out;
    logic fifo_tx_empty;
    logic fifo_tx_full;
    logic fifo_tx_pop;

    assign fifo_rx_pop = !fifo_rx_empty;


    localparam IDLE = 0, DATA0 = 1, DATA1 = 2, WAIT = 3;
    logic [1:0] state;

    always_ff @(posedge clk, posedge reset) begin
        if(reset) begin
            rAddr_cap <= 0;
            state     <= IDLE;
            tx_start  <= 1'b0;
            tx_data   <= 0;
        end else begin
            case(state)
                IDLE: begin
                    if(done_cap) begin
                        state <= DATA0;
                    end
                end
                DATA0: begin
                    if(rAddr_cap < 80*110) begin
                        tx_start <= 1'b1;
                        tx_data  <= rData_cap[11:4];
                        state    <= DATA1;
                    end else begin
                        state <= IDLE;
                    end
                end
                DATA1: begin
                    tx_start  <= 1'b1;
                    tx_data   <= {rData_cap[3:0], 4'h0};
                    state     <= WAIT;
                end
                WAIT: begin
                    if(rAddr_cap == 80*110-1) begin
                        tx_start  <= 1'b0;
                        state     <= IDLE;
                        rAddr_cap <= 0;
                    end else begin
                        tx_start  <= 1'b0;
                        if(!fifo_tx_full) begin
                            state     <= DATA0;
                            rAddr_cap <= rAddr_cap + 1;
                        end
                    end
                end
            endcase
        end
    end

    // DataController <-> tx
    fifo #(
        .DEPTH(16),
        .BIT_WIDTH(8)
    ) U_FIFO_SENDER_TX (
        .clk(clk),
        .reset(reset),
        .push(tx_start),
        .pop(fifo_tx_pop),
        .push_data(tx_data),
        .pop_data(fifo_tx_out),
        .full(fifo_tx_full),
        .empty(fifo_tx_empty)
    );
    // rx 안씀
    fifo #(
        .DEPTH(4),
        .BIT_WIDTH(8)
    ) U_FIFO_DECODER_RX (
        .clk(clk),
        .reset(reset),
        .push(rx_done),
        .pop(fifo_rx_pop),
        .push_data(rx_data),
        .pop_data(fifo_rx_out),
        .full(),
        .empty(fifo_rx_empty)
    );

    uart_rx U_UART_RX (
        .clk(clk),
        .reset(reset),
        .rx(uart_rx),
        .b_tick(b_tick),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );
    uart_tx U_UART_TX (
        .clk(clk),
        .reset(reset),
        .tx_start(fifo_tx_pop),
        .b_tick(b_tick),
        .tx_data(fifo_tx_out),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .uart_tx(uart_tx)
    );

    // 9600 x 16 baud tick
    baud_tick U_BOUD_TICK (
        .clk(clk),
        .reset(reset),
        .b_tick(b_tick)
    );

endmodule


module uart_rx (
    input  logic       clk,
    input  logic       reset,
    input  logic       rx,
    input  logic       b_tick,
    output logic [7:0] rx_data,
    output logic       rx_done
);

    // FSM state
    localparam IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;
    logic [1:0] c_state, n_state;
    // x16 tick counter
    logic [4:0] b_tick_cnt_reg, b_tick_cnt_next;
    // uart 8-bit data counter
    logic [2:0] bit_cnt_next, bit_cnt_reg;
    // uart done, rx data
    logic done_reg, done_next;
    logic [7:0] buf_reg, buf_next;

    assign rx_data = buf_reg;
    assign rx_done = done_reg;

    // state register
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state        <= 2'd0;
            b_tick_cnt_reg <= 5'd0;
            bit_cnt_reg    <= 3'd0;
            done_reg       <= 1'b0;
            buf_reg        <= 8'd0;
        end else begin
            c_state        <= n_state;
            b_tick_cnt_reg <= b_tick_cnt_next;
            bit_cnt_reg    <= bit_cnt_next;
            done_reg       <= done_next;
            buf_reg        <= buf_next;
        end
    end

    // next, output
    always_comb begin
        n_state         = c_state;
        b_tick_cnt_next = b_tick_cnt_reg;
        bit_cnt_next    = bit_cnt_reg;
        done_next       = done_reg;
        buf_next        = buf_reg;

        case (c_state)
            IDLE: begin
                bit_cnt_next    = 3'd0;
                b_tick_cnt_next = 5'd0;
                done_next       = 1'b0;
                buf_next        = 8'd0;
                if (b_tick & !rx) begin
                    buf_next = 8'd0;
                    n_state  = START;
                end
            end
            START: begin
                if (b_tick) begin
                    if (b_tick_cnt_reg == 7) begin
                        b_tick_cnt_next = 5'd0;
                        n_state = DATA;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
            DATA: begin
                if (b_tick) begin
                    if (b_tick_cnt_reg == 4'd15) begin
                        b_tick_cnt_next = 4'd0;
                        buf_next = {rx, buf_reg[7:1]};
                        if (bit_cnt_reg == 7) begin
                            n_state = STOP;
                        end else begin
                            bit_cnt_next = bit_cnt_reg + 1;
                        end
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        n_state   = IDLE;
                        done_next = 1'b1;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule


module uart_tx (
    input  logic       clk,
    input  logic       reset,
    input  logic       tx_start,
    input  logic       b_tick,
    input  logic [7:0] tx_data,
    output logic       tx_busy,   //안전한 출력을 위해
    output logic       tx_done,
    output logic       uart_tx
);

    localparam IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;

    //state reg
    logic [1:0] c_state, n_state;
    logic
        tx_reg,
        tx_next;           //출력을 순차논리를 이용해 노이즈 제거하기 위해

    //BIT_CNT
    logic [2:0]
        bit_cnt_reg,
        bit_cnt_next;  //카운터를 피드백 구조 래치방지
    //tick_count
    logic [3:0] b_tick_cnt_reg, b_tick_cnt_next;
    //busy,done
    logic busy_reg, busy_next;
    logic done_reg, done_next;
    //buffer
    logic [7:0] data_in_buf_reg, data_in_buf_next;

    assign tx_busy = busy_reg;
    assign tx_done = done_reg;
    assign uart_tx = tx_reg;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state <= IDLE;
            tx_reg <= 1'b1;
            bit_cnt_reg <= 1'b0;
            busy_reg <= 0;
            done_reg <= 0;
            data_in_buf_reg <= 0;
            b_tick_cnt_reg <= 0;
        end else begin
            c_state <= n_state;
            tx_reg <= tx_next;
            bit_cnt_reg <= bit_cnt_next;
            busy_reg <= busy_next;
            done_reg <= done_next;
            data_in_buf_reg <= data_in_buf_next;
            b_tick_cnt_reg <= b_tick_cnt_next;
        end
    end

    always_comb begin
        //initialize
        n_state          = c_state;
        tx_next          = tx_reg;
        bit_cnt_next     = bit_cnt_reg;
        b_tick_cnt_next  = b_tick_cnt_reg;
        busy_next        = busy_reg;
        done_next        = done_reg;
        data_in_buf_next = data_in_buf_reg;

        case (c_state)
            IDLE: begin
                tx_next = 1'b1;
                bit_cnt_next = 0;
                b_tick_cnt_next = 4'h0;
                busy_next = 0;
                done_next = 0;
                if (tx_start == 1) begin
                    n_state = START;
                    busy_next = 1'b1;
                    data_in_buf_next = tx_data;
                end
            end
            START: begin
                tx_next = 1'b0;
                if (b_tick == 1) begin
                    if (b_tick_cnt_reg == 15) begin
                        n_state = DATA;
                        b_tick_cnt_next = 0;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
            DATA: begin
                tx_next = data_in_buf_reg[0];
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        b_tick_cnt_next = 4'h0;
                        if (bit_cnt_reg == 7) begin
                            n_state = STOP;
                        end else begin
                            b_tick_cnt_next = 4'h0;
                            bit_cnt_next = bit_cnt_reg + 1;
                            n_state = DATA;
                            data_in_buf_next = {1'b0, data_in_buf_reg[7:1]};
                        end
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                tx_next = 1'b1;
                if (b_tick == 1) begin
                    if (b_tick_cnt_reg == 15) begin
                        done_next = 1;
                        busy_next = 1'b0;
                        n_state   = IDLE;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule


module baud_tick (
    input  logic clk,
    input  logic reset,
    output logic b_tick
);

    parameter BAUDRATE = 9600 * 16;
    parameter F_COUNT = 100_000_000 / BAUDRATE;

    logic [$clog2(F_COUNT)-1 : 0] count_reg;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= 0;
            b_tick <= 1'b0;
        end else begin
            if (count_reg == (F_COUNT - 1)) begin
                b_tick <= 1;
                count_reg <= 0;
            end else begin
                count_reg <= count_reg + 1;
                b_tick <= 0;
            end
        end
    end

endmodule
