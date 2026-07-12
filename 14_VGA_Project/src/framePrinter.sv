`timescale 1ns / 1ps

module framePrinter(
    input  logic        clk,
    input  logic        reset,
    input  logic [9:0]  x_pixel,
    input  logic [9:0]  y_pixel,
    input  logic [15:0] imgPxlData,
    output logic [$clog2(320*240)-1:0] imgPxlAddr,
    // frame print
    // input  logic        capture,
    // input  logic [9:0]  note_x,
    // input  logic [9:0]  note_y,
    output logic [3:0]  port_red,
    output logic [3:0]  port_green,
    output logic [3:0]  port_blue,
    // region detector
    output logic [3:0]  region
);

    RegionDetector U_Region_Detector(
        .clk(clk),
        .reset(reset),
        .x_pixel_VGA(x_pixel),
        .y_pixel_VGA(y_pixel),
        .frame_data(imgPxlData),
        .region(region)
    );

    frameController U_Frame_Controller(
        // .clk(clk),
        // .reset(reset),
        // .capture(capture),
        // .note_x(note_x),
        // .note_y(note_y),
        .x_pixel_VGA(x_pixel),
        .y_pixel_VGA(y_pixel),
        .region(region),
        .imgPxlData(imgPxlData),
        .imgPxlAddr(imgPxlAddr),
        .RGBport({port_red, port_green, port_blue})
    );
endmodule
