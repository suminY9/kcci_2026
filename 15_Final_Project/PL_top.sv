module PL_top(
    input  logic clk,
    input  logic reset,

    // VGA from PS
    input  logic        pclk,
    input  logic [23:0] RGB,
    input  logic [10:0] x_pixel,
    input  logic [10:0] y_pixel,
    // HW
    input  logic echo,      // from SR04
    output logic pwm,       // to SG90

    input  logic       btn, // icc_done
    output logic [1:0] led  // 0:vga_done, 1:vga_test_result
);

    // SR04 -> SG90
    logic w_open, w_close;
    logic w_gate;
    // SR04 -> VGA
    logic w_capture;
    logic w_vga_done;
    // VGA <-> CNN
    logic [31:0] w_pixel_data;
    logic [7:0]  w_pixel_addr;

    // assign led[0] = w_vga_done;

    always_comb begin
        if(w_close) w_gate = 1'b0;  // close
        else        w_gate = 1'b1;  // open
    end

    /********* Sensor *********/
    btn_debounce U_BTN_DEB(
        .clk(clk),
        .reset(reset),
        .i_btn(btn),
        .o_btn(w_btn)
    );
    sr04 U_SR04(
        .clk(clk),
        .reset(reset),
        .echo(echo),
        .i_cnn_done(w_btn),
        .o_capture(w_capture),
        .o_open(w_open),
        .o_close(w_close)
    );
    SG90_Controller U_SG90(
        .clk(clk),
        .reset(reset),
        .i_open(w_gate),
        .i_close(~w_gate),
        .o_pwm(pwm)
    );

    /********* CNN *********/
    VGA_top U_VGA_TOP(
        .i_pixel_clk(pclk),
        .reset(reset),
        .i_RGB(RGB),
        .i_x_pixel(x_pixel),
        .i_y_pixel(y_pixel),
        .i_pixel_addr(w_pixel_addr),
        .o_pixel_data(w_pixel_data),
        .i_capture(w_capture),
        .o_vga_done(w_vga_done)
    );

    /********* TEST *********/
    Capture_test U_Capture_test(
        .clk(clk),
        .reset(reset),
        .vga_done(w_vga_done),
        .pixel_data(w_pixel_data),
        .pixel_addr(w_pixel_addr),
        .pixel_result(led[1]),
        .led_vga_done(led[0])
    );
endmodule


module Capture_test(
    input  logic        clk,
    input  logic        reset,
    input  logic        vga_done,
    input  logic [31:0] pixel_data,
    output logic [7:0]  pixel_addr,
    output logic        pixel_result,
    output logic        led_vga_done
);

    // 1sec counter
    logic [$clog2(100_000_000)-1:0] cnt_1sec;
    logic tick_1sec;

    // test logic FSM
    localparam IDLE = 0, VERIF = 1;
    logic state;
    // test logic
    logic [7:0]  paddrCnt;
    logic [32:0] pre_data;

    /******* count 1 sec *******/
    always_ff @(posedge clk, posedge reset) begin
        if(reset) begin
            cnt_1sec  <= 0;
            tick_1sec <= 1'b0;
        end else begin
            if(cnt_1sec == 100_000_000-1) begin
                tick_1sec <= 1'b1;
            end else begin
                tick_1sec <= 1'b0;
                cnt_1sec  <= cnt_1sec + 1;
            end
        end
    end

    /******* test logic *******/
    always_ff @(posedge clk, posedge reset) begin
        if(reset) begin
            state      <= 1'b0;
            paddrCnt   <= 8'd0;
            pre_data   <= 32'd0;
            pixel_addr <= 8'd0;
            pixel_result <= 1'b0;
            led_vga_done <= 1'b0;
        end else begin
            case(state)
                IDLE: begin
                    pre_data     <= 32'd0;
                    pixel_addr   <= 8'd0;
                    paddrCnt     <= 8'd0;
                    pixel_result <= 1'b0;
                    led_vga_done <= 1'b0;
                    if(vga_done) begin
                        state    <= VERIF;
                        pre_data <= pixel_data;
                    end
                end
                VERIF: begin
                    led_vga_done <= 1'b1;
                    if(tick_1sec) begin
                        if(pixel_addr == 8'h80) state <= IDLE;
                        else                    pixel_addr <= pixel_addr + 1;
                        if(pre_data != pixel_data) pixel_result <= 1'b1;
                        else                       pixel_result <= 1'b0;
                    end
                end
            endcase
        end
    end
endmodule