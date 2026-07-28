module VGAtest_top(
    input  logic clk,
    input  logic reset,
    
    output logic       xclk,
    input  logic       pclk,
    input  logic       vsync,
    input  logic       href,
    input  logic [7:0] pdata,

    output logic       h_sync,
    output logic       v_sync,
    output logic [3:0] port_R,
    output logic [3:0] port_G,
    output logic [3:0] port_B,

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
    assign xclk = clk_25M;

    clk_wiz_0 clk_div(
        .clk_100M(clk_100M),
        .clk_25M(clk_25M),
        .reset(reset),
        .clk_in1(clk)
    );
    SCCB_Data_Controller U_SCCB_Data_Ctrl(
        .clk(clk_100M),
        .reset(reset),
        .scl(scl),
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
    frameBuffer_CAM0 U_FrameBuffer (
        .wclk(pclk),
        .we(we),
        .wAddr(wAddr),
        .wData(wData),
        .rclk(rclk),
        .rAddr(imgPxlAddr),
        .rData(imgPxlData)
    );

    FrameManager U_FrameManager (
        .de(de),
        .x_pixel_VGA(x_pixel),
        .y_pixel_VGA(y_pixel),
        .imgPxlData(imgPxlData),
        .imgPxlAddr(imgPxlAddr),
        .portRGB({port_R, port_G, port_B})
    );
endmodule