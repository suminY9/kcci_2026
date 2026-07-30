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
    // SR04 -> VGA
    logic w_capture;
    logic w_vga_done;
    // VGA <-> CNN
    logic [31:0] w_pixel_data;
    logic [7:0]  w_pixel_addr;

    assign led[0] = w_vga_done;

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
        .i_open(w_open),
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

    /********* TEST *********/
    Capture_test U_Capture_test(
        .clk(clk),
        .reset(reset),
        .vga_done(w_vga_done),
        .pixel_data(w_pixel_data),
        .pixel_addr(w_pixel_addr),
        .pixel_result(led[1])
    );
endmodule


module Capture_test(
    input  logic        clk,
    input  logic        reset,
    input  logic        vga_done,
    input  logic [31:0] pixel_data,
    output logic [7:0]  pixel_addr,
    output logic        pixel_result
);

    localparam IDLE = 0, VERIF = 1;
    logic state;

    logic [7:0]  paddrCnt;
    logic [32:0] pre_data;

    always_ff @(posedge clk, posedge reset) begin
        if(reset) begin
            state      <= 1'b0;
            paddrCnt   <= 8'd0;
            pre_data   <= 32'd0;
            pixel_addr <= 8'd0;
        end else begin
            case(state)
                IDLE: begin
                    pre_data     <= 32'd0;
                    pixel_addr   <= 8'd0;
                    paddrCnt     <= 8'd0;
                    pixel_result <= 1'b0;
                    if(vga_done) begin
                        state    <= VERIF;
                        pre_data <= pixel_data;
                    end
                end
                VERIF: begin
                    if(pixel_addr == 8'h80) state <= IDLE;
                    else                    pixel_addr <= pixel_addr + 1;
                    if(pre_data != pixel_data) pixel_result <= 1'b1;
                    else                       pixel_result <= 1'b0;
                end
            endcase
        end
    end
endmodule