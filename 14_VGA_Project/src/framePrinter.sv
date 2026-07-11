`timescale 1ns / 1ps

module framePrinter(
    input  logic        clk,
    input  logic        reset,
    input  logic        DE,
    input  logic        vsync,
    input  logic [9:0]  x_pixel,
    input  logic [9:0]  y_pixel,
    input  logic [15:0] imgPxlData,
    output logic [$clog2(320*240)-1:0] imgPxlAddr,
    // frame print
    output logic [3:0]  port_red,
    output logic [3:0]  port_green,
    output logic [3:0]  port_blue,
    // region detector
    output logic        scanning,
    output logic [3:0]  region
);
    // frame upscale - VGA: 640 * 320
    logic vgaArea;
    assign vgaArea = (x_pixel < 640) && (y_pixel < 480);
    assign imgPxlAddr = 320*(y_pixel>>1) + (319-(x_pixel>>1));
    
    // filter
    always_comb begin
        if(vgaArea) begin
            case(region)
                4'b0001:      if((x_pixel >=   0) && (x_pixel < 160)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b0010:      if((x_pixel >= 160) && (x_pixel < 320)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b0100:      if((x_pixel >= 320) && (x_pixel < 480)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b1000:      if((x_pixel >= 480) && (x_pixel < 640)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b0011:      if((x_pixel >=   0) && (x_pixel < 160)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 160) && (x_pixel < 320)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b0101:      if((x_pixel >=   0) && (x_pixel < 160)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 320) && (x_pixel < 480)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b1001:      if((x_pixel >=   0) && (x_pixel < 160)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 480) && (x_pixel < 640)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b0110:      if((x_pixel >= 160) && (x_pixel < 320)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 320) && (x_pixel < 480)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b1010:      if((x_pixel >= 160) && (x_pixel < 320)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 480) && (x_pixel < 640)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b1100:      if((x_pixel >= 320) && (x_pixel < 480)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 480) && (x_pixel < 640)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b0111:      if((x_pixel >=   0) && (x_pixel < 160)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 160) && (x_pixel < 320)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 320) && (x_pixel < 480)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b1011:      if((x_pixel >=   0) && (x_pixel < 160)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 160) && (x_pixel < 320)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 480) && (x_pixel < 640)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b1101:      if((x_pixel >=   0) && (x_pixel < 160)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 320) && (x_pixel < 480)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 480) && (x_pixel < 640)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b1110:      if((x_pixel >= 160) && (x_pixel < 320)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 320) && (x_pixel < 480)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 480) && (x_pixel < 640)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b1111: {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                4'b0000: {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
            endcase
        end else begin
            {port_red, port_green, port_blue} = 0;
        end
    end

    RegionDetector U_Region_Detector(
        .clk(clk),
        .reset(reset),
        .x_pixel_VGA(x_pixel),
        .y_pixel_VGA(y_pixel),
        .frame_data(imgPxlData),
        .region(region)
    );
endmodule
