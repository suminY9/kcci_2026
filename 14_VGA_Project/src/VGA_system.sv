`timescale 1ns / 1ps

module VGA_system (
    input  logic clk,
    input  logic reset,

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
    output logic [3:0] port_blue,

    output logic       scanning,
    // output logic       pushed,
    output logic [3:0] region,

    output logic scl,
    inout  logic sda
);

    logic [9:0] x_pixel;
    logic [9:0] y_pixel;
    logic de;

    logic [$clog2(320*240)-1:0] imgPxlAddr;
    logic [15:0] imgPxlData;

    logic we;
    logic [$clog2(320*240)-1:0] wAddr;
    logic [15:0] wData;

    logic clk_100M, clk_25M, rclk;

    // scale, filter
    logic [11:0] port_scale, port_gray, port_rgb;

    assign xclk = clk_25M;

    clk_wiz_0 clk_div(
        .clk_100M(clk_100M),
        .clk_25M(clk_25M),
        .reset(reset),
        .clk_in1(clk)
    );

    VGA_Decoder U_VGA_Decoder(

        .clk(clk_100M),
        .reset(reset),
        .rclk(rclk),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .de(de)
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
    frameBuffer U_FrameBuffer (
        .wclk(pclk),
        .we(we),
        .wAddr(wAddr),
        .wData(wData),
        .rclk(rclk),
        .rAddr(imgPxlAddr),
        .rData(imgPxlData)
    );
    framePrinter U_framePrinter(
        .clk(rclk),
        .reset(reset),
        .DE(de),
        .vsync(vsync),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .imgPxlData(imgPxlData),
        .imgPxlAddr(imgPxlAddr),
        .port_red  (port_red),
        .port_green(port_green),
        .port_blue (port_blue),
        .scanning(scanning),
        // .pushed(pushed),
        .region(region)
    );
    
    OV7670_SCCB_Controller U_SCCB_Data_Ctrl(
        .clk(clk_100M),
        .reset(reset),
        .scl(scl),
        .sda(sda)
    );
endmodule
