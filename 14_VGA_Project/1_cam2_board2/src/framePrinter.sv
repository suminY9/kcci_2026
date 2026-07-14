`timescale 1ns / 1ps

module framePrinter(
    input  logic        clk,
    input  logic        reset,
    // input  logic        vsync,
    input  logic [9:0]  x_pixel,
    input  logic [9:0]  y_pixel,
    input  logic [15:0] imgPxlData,
    output logic [$clog2(320*240)-1:0] imgPxlAddr,
    // frame print
    // input  logic [9:0]  note_x,
    // input  logic [9:0]  note_y,
    output logic [11:0]  RGBport,
    // region detector
    output logic [3:0]  region
);

    RegionDetector U_Region_Detector(
        .clk(clk),
        .reset(reset),
        // .vsync(vsync),
        .x_pixel_VGA(x_pixel),
        .y_pixel_VGA(y_pixel),
        .frame_data(imgPxlData),
        .region(region)
    );

    frameController U_Frame_Controller(
        // .note_x(note_x),
        // .note_y(note_y),
        .x_pixel_VGA(x_pixel),
        .y_pixel_VGA(y_pixel),
        .region(region),
        .imgPxlData(imgPxlData),
        .imgPxlAddr(imgPxlAddr),
        .RGBport(RGBport)
    );
endmodule
