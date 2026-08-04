`timescale 1ns / 1ps

module sr04 (
    input  logic clk,
    input  logic reset,
    input  logic o_echo,
    input  logic i_cnn_done,
    
    output logic o_trigger,
    output logic o_capture,
    output logic o_close
);

    wire [11:0] w_distance; // 센서에서 측정된 거리를 FSM으로 전달하는 선

    // 초음파 센서 구동부 인스턴스
    SR04_Controller U_SR04_CONTROLLER(
        .clk(clk),
        .reset(reset),
        .echo(o_echo),
        .trigger(o_trigger),
        .distance(w_distance)
    );
    // 카메라 및 문 제어 FSM 인스턴스
    sr04_fsm U_FSM_CONTROL (
        .clk(clk),
        .reset(reset),
        .i_distance(w_distance),
        .i_cnn_done(i_cnn_done),
        .o_capture(o_capture),
        .o_close(o_close)
    );

endmodule

module sr04_fsm (
    input  logic        clk,
    input  logic        reset,
    input  logic [11:0] i_distance,
    input  logic        i_cnn_done,
    output logic        o_capture,
    output logic        o_close
);

    typedef enum logic [2:0] {
        IDLE,
        WAIT,
        WAIT_CNN,
        OPEN,
        WAIT_DELAY
    } state_e;

    state_e state;
    logic [31:0] delay_cnt;

    always_ff @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            delay_cnt <= 32'd0;
        end else begin
            case (state)
                IDLE: begin
                    delay_cnt <= 32'd0;
                    if (i_distance > 12'd0 && i_distance <= 12'd3) begin
                        state <= WAIT;
                    end
                end
                WAIT: begin
                    if (delay_cnt >= 200_000_000) begin
                        state <= WAIT_CNN;
                        delay_cnt <= 32'd0;
                    end else begin
                        delay_cnt <= delay_cnt + 1'b1;
                    end
                end
                WAIT_CNN: begin
                    if (i_cnn_done) begin
                        state <= OPEN;
                    end
                end
                OPEN: begin
                    delay_cnt <= 32'd0;
                    state <= WAIT_DELAY;
                end
                WAIT_DELAY: begin
                    if (delay_cnt >= 200_000_000) begin
                        state <= IDLE;
                    end else begin
                        delay_cnt <= delay_cnt + 1'b1;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            o_capture <= 1'b0;
            o_close <= 1'b1;
        end else begin
            o_capture <= 1'b0;
            o_close   <= 1'b1;

            case (state)
                IDLE: begin
                    o_capture <= 1'b0;
                end
                WAIT: begin
                    if (delay_cnt == 200_000_000 - 1) begin
                        o_capture <= 1'b1;
                    end
                end
                WAIT_CNN: begin
                    o_capture <= 1'b1;
                end
                OPEN: begin
                    o_close   <= 1'b0;
                    o_capture <= 1'b1;
                end
                WAIT_DELAY: begin
                    o_close   <= 1'b0;
                    o_capture <= 1'b1;
                    if (delay_cnt == 200_000_000 - 1) begin
                        o_close <= 1'b1;
                    end
                end
                default: begin
                    o_capture <= 1'b0;
                    o_close <= 1'b1;
                end
            endcase
        end
    end

endmodule
