`timescale 1ns / 1ps

module top_VGA (
    input logic clk,
    input logic reset,

    // ov7670 side
    output logic       xclk,
    input  logic       pclk,
    input  logic       href,
    input  logic       vsync,
    input  logic [7:0] pdata,

    output logic       h_sync,
    output logic       v_sync,
    output logic [3:0] port_red,
    output logic [3:0] port_green,
    output logic [3:0] port_blue
);

    logic [9:0] x_pixel;
    logic [9:0] y_pixel;
    logic de;

    logic [$clog2(320*240)-1:0] addr;
    logic [15:0] imgPxlData;

    logic [$clog2(320*240)-1:0] qvga_addr;
    logic [15:0] qvga_imgPxlData;
    logic [11:0] qvga_port_rgb;

    logic we;
    logic [$clog2(320*240)-1:0] wAddr;
    logic [15:0] wData;

    logic clk_100M, clk_25M, rclk;

    assign xclk = clk_25M;

    clk_wiz_0 instance_name (
        .clk_100M(clk_100M),
        .clk_25M(clk_25M),
        .reset(reset),
        .clk_in1(clk)
    );

    VGA_Decoder U_VGA_Decoder (

        .clk    (clk_100M),
        .reset  (reset),
        .rclk   (rclk),
        .h_sync (h_sync),
        .v_sync (v_sync),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .de     (de)
    );

    frameBufferReader U_frameBufferReader (
        .de        (de),
        .x_pixel   (x_pixel),
        .y_pixel   (y_pixel),
        .addr      (qvga_addr),
        .imgPxlData(qvga_imgPxlData),
        .port_red  (port_red),
        .port_green(port_green),
        .port_blue (port_blue)
    );
    frameBuffer U_FrameBuffer (
        .wclk(pclk),
        .we(we),
        .wAddr(wAddr),
        .wData(wData),
        .rclk(rclk),
        .rAddr(qvga_addr),
        .rData(qvga_imgPxlData)
    );
   
    OV7670MemController U_OV7670MemController(
        .pclk(pclk),
        .reset(reset),
        .href(href),
        .vsync(vsync),
        .pdata(pdata),
        .we(we),
        .wAddr(wAddr),
        .wData(wData)
    );
endmodule
