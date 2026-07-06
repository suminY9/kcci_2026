`timescale 1ns / 1ps

module RGB_Filter(
    input  logic [2:0]  sw_rgb,
    input  logic [11:0] i_rgb,
    output logic [11:0] o_rgb
);

    assign o_rgb[3:0]  = sw_rgb[0] ? i_rgb[3:0] : 0;
    assign o_rgb[7:4]  = sw_rgb[1] ? i_rgb[7:4] : 0;
    assign o_rgb[11:8] = sw_rgb[2] ? i_rgb[11:8] : 0;

endmodule

module grayScale_Filter (
    input  logic [11:0] i_rgb,
    output logic [11:0] o_rgb
);
    logic [11:0] gray;

    assign gray = (i_rgb[11:8] << 6) + (i_rgb[11:8] << 3) + (i_rgb[11:8] << 2) +
                  (i_rgb[7:4] << 7) + (i_rgb[7:4] << 4) + (i_rgb[7:4] << 3) + (i_rgb[7:4] << 1) +
                  (i_rgb[3:0] << 4) + (i_rgb[3:0] << 3) + (i_rgb[3:0] << 1);
    assign o_rgb = {gray[11:8], gray[11:8], gray[11:8]};
    
endmodule
