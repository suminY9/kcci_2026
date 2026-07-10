module frameController(
    input  logic [9:0]  x_pixel,
    input  logic [9:0]  y_pixel,
    input  logic [3:0]  region,
    input  logic [15:0] imgPxlData,
    output logic [$clog2(320*240)-1:0] imgPxlAddr,
    output logic [15:0] RGBport
);

endmodule


module Filter_Region(
    input  logic [9:0]  x_pixel,
    input  logic [9:0]  y_pixel,
    input  logic [3:0]  region,
    input  logic [15:0] imgPxlData,
    output logic [$clog2(320*240)-1:0] imgPxlAddr,
    output logic [15:0] o_rgb
);

endmodule


module Filter_GAME(
    input  logic [9:0]  x_pixel,
    input  logic [9:0]  y_pixel,
    input  logic [15:0] i_rgb,
    output logic [15:0] o_rgb
);

endmodule