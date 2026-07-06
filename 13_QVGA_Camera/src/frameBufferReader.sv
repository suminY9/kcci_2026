`timescale 1ns / 1ps

module frameBufferReader(
    input  logic       de,
    input  logic       sw_upscale,
    input  logic [9:0] x_pixel,
    input  logic [9:0] y_pixel,
    output logic [$clog2(320*240)-1:0] addr,
    input  logic [15:0] imgPxlData,
    output logic [3:0] port_red,
    output logic [3:0] port_green,
    output logic [3:0] port_blue
);
    logic vgaArea;

    assign vgaArea = sw_upscale ? (x_pixel < 640) && (y_pixel < 480) : (x_pixel < 320) && (y_pixel < 240);

    assign {port_red, port_green, port_blue} = vgaArea ? {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]} : 0;

    always_comb begin
        if(sw_upscale) addr = vgaArea ? 320*(y_pixel/2) + (x_pixel/2) : 0;
        else           addr = vgaArea ? (320*y_pixel + x_pixel) : 0;
    end
endmodule
