`timescale 1ns / 1ps

module ImgRomReader(
    input  logic        de,
    input  logic        sw_ctrl,
    input  logic [9:0]  x_pixel,
    input  logic [9:0]  y_pixel,
    output logic [$clog2(320*240-1):0] addr,
    input  logic [15:0] imgPxlData,
    output logic [3:0]  port_red,
    output logic [3:0]  port_green,
    output logic [3:0]  port_blue
);

    logic displayArea;

    assign displayArea = sw_ctrl ? (x_pixel < 640) && (y_pixel < 480) : (x_pixel < 320) && (y_pixel < 240);

    // QVGA output
    // assign addr = displayArea ? (320*y_pixel + x_pixel) : 'bz;
    // VGA output (x2 up scaling)
    //assign addr = displayArea ? (320*(y_pixel/2) + (x_pixel/2)) : 'bz;

    assign {port_red, port_green, port_blue} = displayArea ? {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]} : 0;

    always_comb begin
        if(sw_ctrl) addr = displayArea ? 320*(y_pixel/2) + (x_pixel/2) : 0;
        else        addr = displayArea ? (320*y_pixel + x_pixel) : 0;
    end
endmodule