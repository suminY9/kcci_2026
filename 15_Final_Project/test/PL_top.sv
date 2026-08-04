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
    output logic trigger,   // to SR04
    output logic pwm,       // to SG90

    input  logic       btn, // icc_done
    output logic [1:0] led  // 0:vga_done, 1:vga_test_result
);

    // button
    logic w_btn;
    // SR04 -> SG90
    logic w_close;
    // SR04 -> VGA
    (* mark_debug = "true" *) logic w_capture;
    (* mark_debug = "true" *) logic w_vga_done;
    // VGA <-> CNN
    (* mark_debug = "true" *) logic [31:0] w_pixel_data;
    (* mark_debug = "true" *) logic [7:0]  w_pixel_addr;

    // assign led[0] = w_vga_done;

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
        .o_echo(echo),
        .i_cnn_done(w_btn),
        .o_capture(w_capture),
        .o_trigger(trigger),
        .o_close(w_close)
    );
    SG90_Controller U_SG90(
        .clk(clk),
        .reset(reset),
        .i_open(~w_close),
        .i_close(w_close),
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
    Capture_test U_TEST(
        .clk(clk),
        .reset(reset),
        .vga_done(w_vga_done),
        .pixel_addr(w_pixel_addr)
    );
endmodule


module Capture_test(
    input  logic        clk,
    input  logic        reset,
    input  logic        vga_done,
    output logic [7:0]  pixel_addr
);

    // 1sec counter
    // logic [$clog2(100_000_000)-1:0] cnt_1sec;
    // logic tick_1sec;

    // test logic FSM
    localparam IDLE = 0, VERIF = 1;
    logic state;
    // test logic
    logic [7:0]  paddrCnt;

    // /******* count 1 sec *******/
    // always_ff @(posedge clk, posedge reset) begin
    //     if(reset) begin
    //         cnt_1sec  <= 0;
    //         tick_1sec <= 1'b0;
    //     end else begin
    //         if(cnt_1sec == 100_000_000-1) begin
    //             tick_1sec <= 1'b1;
    //         end else begin
    //             tick_1sec <= 1'b0;
    //             cnt_1sec  <= cnt_1sec + 1;
    //         end
    //     end
    // end

    /******* test logic *******/
    always_ff @(posedge clk, posedge reset) begin
        if(reset) begin
            state      <= 1'b0;
            paddrCnt   <= 8'd0;
            pixel_addr <= 8'd0;
        end else begin
            case(state)
                IDLE: begin
                    pixel_addr   <= 8'd0;
                    paddrCnt     <= 8'd0;
                    if(vga_done) begin
                        state    <= VERIF;
                    end
                end
                VERIF: begin
                    // if(tick_1sec) begin
                        if(pixel_addr == 8'h80) state <= IDLE;
                        else                    pixel_addr <= pixel_addr + 1;
                    // end
                end
            endcase
        end
    end
endmodule