`timescale 1ns / 1ps

module VGAsystem(
    input  logic clk,
    input  logic reset,

    // GAME
    input  logic       capture,
    // input  logic [9:0] note_x,
    // input  logic [9:0] note_y,
    output logic       done_cap,
    output logic [3:0] region,

    // cam0
    output logic       xclk,
    input  logic       pclk_0,
    input  logic       href_0,
    input  logic       vsync_0,
    input  logic [7:0] pdata_0,
    // cam1
    input  logic       pclk_1,
    input  logic       href_1,
    input  logic       vsync_1,
    input  logic [7:0] pdata_1,

    output logic       h_sync,
    output logic       v_sync,
    output logic [3:0] port_red,
    output logic [3:0] port_green,
    output logic [3:0] port_blue,

    output logic scl0,
    output logic scl1,
    inout  logic sda
);

    logic [9:0] x_pixel;
    logic [9:0] y_pixel;
    logic de;

    logic we_0, we_1, we_cap;
    logic [$clog2(320*240)-1:0] rAddr_0, rAddr_1;
    logic [$clog2(320*240)-1:0] wAddr_0, wAddr_1;
    logic [$clog2(80*110)-1:0] rAddr_cap;
    logic [$clog2(80*110)-1:0] wAddr_cap;
    logic [15:0] rData_0, rData_1;
    logic [15:0] wData_0, wData_1;
    logic [11:0] rData_cap;
    logic [11:0] wData_cap;

    logic [11:0] RGB_printer, RGB_capture;

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
        .scl0(scl0),
        .scl1(scl1),
        .sda(sda)
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
    OV7670MemController U_OV7670MemController_0(
        .pclk(pclk_0),
        .reset(reset),
        .href(href_0),
        .vsync(vsync_0),
        .pdata(pdata_0),
        .we(we_0),
        .wAddr(wAddr_0),
        .wData(wData_0)
    );
    OV7670MemController U_OV7670MemController_1(
        .pclk(pclk_1),
        .reset(reset),
        .href(href_1),
        .vsync(vsync_1),
        .pdata(pdata_1),
        .we(we_1),
        .wAddr(wAddr_1),
        .wData(wData_1)
    );
    frameBuffer U_FrameBuffer (
        .wclk_0(pclk_0),
        .we_0(we_0),
        .wAddr_0(wAddr_0),
        .wData_0(wData_0),
        .rclk_0(rclk),
        .rAddr_0(rAddr_0),
        .rData_0(rData_0),
        .wclk_1(pclk_1),
        .we_1(we_1),
        .wAddr_1(wAddr_1),
        .wData_1(wData_1),
        .rclk_1(rclk),
        .rAddr_1(rAddr_1),
        .rData_1(rData_1),
        .wclk_cap(rclk),
        .we_cap(we_cap),
        .wAddr_cap(wAddr_cap),
        .wData_cap(wData_cap),
        .rclk_cap(),
        .rAddr_cap(),
        .rData_cap()
    );
    framePrinter U_framePrinter(
        .clk(rclk),
        .reset(reset),
        // .vsync(vsync_0),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .imgPxlData(rData_0),
        .imgPxlAddr(rAddr_0),
        // .note_x(note_x),
        // .note_y(note_y),
        .RGBport(RGB_printer),
        .region(region)
    );
    frameCapture U_frameCapture(
        .clk(rclk),
        .reset(reset),
        .capture(capture),
        .vsync(vsync_1),
        .x_pixel_VGA(x_pixel),
        .y_pixel_VGA(y_pixel),
        .imgPxlData(rData_1),
        .imgPxlAddr(rAddr_1),
        .wData_cap(wData_cap),
        .wAddr_cap(wAddr_cap),
        .we_cap(we_cap),
        .done_cap(done_cap),
        .RGBport(RGB_capture)
    );
    assign {port_red, port_green, port_blue} = RGB_printer;
    // assign {port_red, port_green, port_blue} = RGB_capture;
    // mux_2x1 #(
    //     .BIT_DEPTH(12)
    // ) U_MUX_RGB (
    //     .sel(capture),
    //     .in0(RGB_printer),
    //     .in1(RGB_capture),
    //     .out({port_red, port_green, port_blue})
    // );
endmodule
