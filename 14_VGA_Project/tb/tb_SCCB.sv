`timescale 1ns / 1ps

module tb_SCCB();
    logic clk;
    logic reset;
    logic capture;
    logic       xclk;
    logic       pclk0;
    logic       href0;
    logic       vsync0;
    logic [7:0] pdata0;
    logic       pclk1;
    logic       href1;
    logic       vsync1;
    logic [7:0] pdata1;
    logic       h_sync;
    logic       v_sync;
    logic [3:0] port_red;
    logic [3:0] port_green;
    logic [3:0] port_blue;
    logic [3:0] region;
    logic scl0;
    logic scl1;
    wire  sda;

    VGA_system dut (.*);

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 1;
        repeat(3) @(posedge clk);
        reset = 0;
        @(posedge clk);
    end
endmodule
