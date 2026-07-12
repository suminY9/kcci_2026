`timescale 1ns / 1ps

module VGA_system (
    input  logic clk,
    input  logic reset,

    // GAME
    input  logic capture,

    // cam0
    output logic       xclk,
    input  logic       pclk,
    input  logic       href,
    input  logic       vsync,
    input  logic [7:0] pdata,
    // cam1
    // input  logic       pclk1,
    // input  logic       href1,
    // input  logic       vsync1,
    // input  logic [7:0] pdata1,

    output logic       h_sync,
    output logic       v_sync,
    output logic [3:0] port_red,
    output logic [3:0] port_green,
    output logic [3:0] port_blue,

    output logic [3:0] region,

    output logic scl,
    // output logic scl1,
    inout  logic sda
    // inout  logic sda1
);
    // // cam
    // logic pclk, href, vsync;
    // logic [7:0] pdata;

    logic [9:0] x_pixel;
    logic [9:0] y_pixel;
    logic de;

    logic [$clog2(320*240)-1:0] imgPxlAddr;
    logic [15:0] imgPxlData;

    logic we;
    logic [$clog2(320*240)-1:0] wAddr;
    logic [15:0] wData;

    logic clk_100M, clk_25M, rclk;

    assign xclk = clk_25M;

    clk_wiz_0 clk_div(
        .clk_100M(clk_100M),
        .clk_25M(clk_25M),
        .reset(reset),
        .clk_in1(clk)
    );
    OV7670_SCCB_Controller U_SCCB_Data_Ctrl(
        .clk(clk_100M),
        .reset(reset),
        .scl(scl),
        .sda(sda)
    );
    // OV7670_SCCB_Controller U_SCCB_Data_Ctrl1(
    //     .clk(clk_100M),
    //     .reset(reset),
    //     .scl(scl1),
    //     .sda(sda1)
    // );
    // BUFGMUX U_MUX_PCLK(
    //     .S(capture),
    //     .I0(pclk0),
    //     .I1(pclk1),
    //     .O(pclk)
    // );
    // mux_2x1 #(
    //     .BIT_DEPTH(1)
    // ) U_MUX_pclk (
    //     .sel(!capture),
    //     .in1(pclk0),
    //     .in2(pclk1),
    //     .out(pclk)
    // );
    // mux_2x1 #(
    //     .BIT_DEPTH(10)
    // ) U_MUX_CAM (
    //     .sel(!capture),
    //     .in1({href0, vsync0, pdata0}),
    //     .in2({href1, vsync1, pdata1}),
    //     .out({href, vsync, pdata}) 
    // );

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
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .imgPxlData(imgPxlData),
        .imgPxlAddr(imgPxlAddr),
        // .capture(capture),
        // .note_x(note_x),
        // .note_y(note_y),
        .port_red(port_red),
        .port_green(port_green),
        .port_blue(port_blue),
        .region(region)
    );
endmodule
