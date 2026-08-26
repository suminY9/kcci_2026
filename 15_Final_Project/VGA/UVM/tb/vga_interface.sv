interface vga_if(input logic pclk, input logic reset);
    logic [23:0] RGB;
    logic [10:0] x_pixel;
    logic [10:0] y_pixel;
    logic [7:0]  pixel_addr;
    logic [31:0] pixel_data;
    logic        vga_start;
    logic        vga_done;

    clocking drv_cb @(posedge pclk);
        default input #1step output #0;
        output RGB;
        output x_pixel;
        output y_pixel;
        output pixel_addr;
        input  pixel_data;
        output vga_start;
        input  vga_done;
    endclocking

    clocking mon_cb @(posedge pclk);
        default input #1step;
        input RGB;
        input x_pixel;
        input y_pixel;
        input pixel_addr;
        input pixel_data;
        input vga_start;
        input vga_done;
    endclocking

    modport mp_drv(clocking drv_cb, input pclk, input reset);
    modport mp_mon(clocking drv_cb, input pclk, input reset);
endinterface