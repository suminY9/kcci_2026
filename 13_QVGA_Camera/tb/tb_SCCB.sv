`timescale 1ns / 1ps

module tb_SCCB();
    logic clk;
    logic reset;
    logic scl;
    wire sda;
    logic sw_upscale;
    logic sw_filter;
    logic sw_gray;
    logic [2:0] sw_rgbColor;
    logic xclk;
    logic pclk;
    logic href;
    logic vsync;
    logic [7:0] pdata;
    logic h_sync;
    logic v_sync;
    logic [3:0] port_red, port_green, port_blue;

    // top_VGA dut(
    // .clk(clk),
    // .reset(reset),
    // .sw_upscale(),
    // .sw_filter(),
    // .sw_gray(),
    // .sw_rgbcolor(),
    // .xclk(),
    // .pclk(),
    // .href(),
    // .vsync(),
    // .pdata(),
    // .h_sync(),
    // .v_sync(),
    // .port_red(),
    // .port_green(),
    // .port_blue(),
    // .scl(scl),
    // .sda(sda)
    // );

    top_VGA dut(.*);


    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 1;
        repeat(3) @(posedge clk);
        reset = 0;
        @(posedge clk);
    end

endmodule
