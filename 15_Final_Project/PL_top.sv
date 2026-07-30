module PL_top(
    input  logic clk,
    input  logic reset,

    // HW
    input  logic echo,
    output logic pwm,

    input  logic btn, // icc_done
    output logic led  // vga_done
);

    // SR04 -> SG90
    logic w_open, w_close;
    // SR04 -> VGA
    logic w_capture;

    // btn debounce 추가 필요

    sr04 U_SR04(
        .clk(clk),
        .reset(reset),
        .echo(echo),
        .i_cnn_done(),
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

    VGA_top U_VGA_TOP(
        .i_pixel_clk(),
        .reset(reset),
        .i_RGB(),
        .i_x_pixel(),
        .i_y_pixel(),
        .i_pixel_addr(),
        .o_pixel_data(),
        .i_capture(w_capture),
        .vga_done(led)
    );
endmodule
