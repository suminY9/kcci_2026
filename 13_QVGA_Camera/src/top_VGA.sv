`timescale 1ns / 1ps

module top_VGA (
    input  logic clk,
    input  logic reset,

    input  logic       sw_upscale,   // 1: upscale(VGA), 0: normal(QVGA)
    input  logic       sw_filter,    // 1: filter mode, 0: normal
    input  logic       sw_gray,      // 1: gray filter, 0: rgb filter
    input  logic [2:0] sw_rgbColor,  // [0]: R, [1]: G, [2]: B

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

    // scale, filter
    logic [11:0] port_scale, port_gray, port_rgb;

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
        .rAddr(qvga_addr),
        .rData(qvga_imgPxlData)
    );
    frameBufferReader U_frameBufferReader (
        .de        (de),
        .sw_upscale(sw_upscale),
        .x_pixel   (x_pixel),
        .y_pixel   (y_pixel),
        .addr      (qvga_addr),
        .imgPxlData(qvga_imgPxlData),
        .port_red  (port_scale[11:8]),
        .port_green(port_scale[7:4]),
        .port_blue (port_scale[3:0])
    );
    
    grayScale_Filter U_Gray_Filter (
        .i_rgb(port_scale),
        .o_rgb(port_gray)
    );
    RGB_Filter U_RGB_Filter(
        .sw_rgb(sw_rgbColor),
        .i_rgb(port_scale),
        .o_rgb(port_rgb)
    );
    
    mux_3x1 #(
        .LENGTH(12)
    ) U_MUX_FILTER (
        .sel({sw_gray, sw_filter}),
        .in1(port_scale),
        .in2(port_gray),
        .in3(port_rgb),
        .out({port_red, port_green, port_blue})
    );
endmodule


module mux_3x1#(
    parameter LENGTH = 15
)   (
    input  logic [1:0]        sel,
    input  logic [LENGTH-1:0] in1,
    input  logic [LENGTH-1:0] in2,
    input  logic [LENGTH-1:0] in3,
    output logic [LENGTH-1:0] out
);
    assign out = !sel[0] ? in1 :
                 sel[1]  ? in2 : in3;
endmodule
