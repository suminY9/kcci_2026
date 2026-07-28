module FrameManager(
    input  logic        de,
    input  logic [9:0]  x_pixel_VGA,
    input  logic [9:0]  y_pixel_VGA,
    input  logic [15:0] imgPxlData,
    output logic [16:0] imgPxlAddr,
    output logic [11:0] portRGB
);

    // frame upscale -VGA: 640 * 320
    logic [9:0] x_pixel, y_pixel;
    assign x_pixel = x_pixel_VGA >> 1;
    assign y_pixel = y_pixel_VGA >> 1;
    assign imgPxlAddr = 320*(y_pixel) + x_pixel;

    logic [11:0] RGBcrop, RGBmono;

    assign portRGB = de ? RGBmono : 12'h0;

    FrameCrop U_FrameCrop(
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .imgPxlData(imgPxlData),
        .o_rgb(RGBcrop)
    );
    FrameMono U_FrameMono(
        .i_rgb(RGBcrop),
        .o_rgb(RGBmono)
    );
endmodule


module FrameCrop(
    input  logic [9:0]  x_pixel,
    input  logic [9:0]  y_pixel,
    input  logic [15:0] imgPxlData,
    output logic [11:0] o_rgb
);

    // frame upscale -VGA: 640 * 320
    logic vgaArea;
    assign vgaArea = (x_pixel < 320) && (y_pixel < 240);

    always_comb begin
        if(vgaArea) begin
            if((x_pixel >= 128) && (x_pixel < 192) && (y_pixel >= 88) && (y_pixel < 152))
                o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
            else o_rgb = 0;
        end
        else o_rgb = 0;
    end
endmodule


module FrameMono(
    input  logic [11:0] i_rgb,
    output logic [11:0] o_rgb
);

    logic [11:0] gray;

    assign gray = (i_rgb[11:8] << 6) + (i_rgb[11:8] << 3) + (i_rgb[11:8] << 2) +
                  (i_rgb[7:4] << 7) + (i_rgb[7:4] << 4) + (i_rgb[7:4] << 3) + (i_rgb[7:4] << 1) +
                  (i_rgb[3:0] << 4) + (i_rgb[3:0] << 3) + (i_rgb[3:0] << 1);

    always_comb begin
        if(i_rgb == 0) o_rgb = 0;
        else begin
            if(gray[11:8] >= 4'b0111) o_rgb = 12'hfff;
            else                      o_rgb = 12'h000;
        end
    end
endmodule
