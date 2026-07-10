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
    output logic [3:0]  region_RED,
    output logic [3:0]  region_BLUE
);
    // frame upscale - VGA: 640 * 320
    logic vgaArea;
    logic [$clog2(320*240)-1:0] imgPxlAddr_reg, DetectorAddr;
    assign vgaArea = (x_pixel < 640) && (y_pixel < 480);

    // fix multi-driver
    assign imgPxlAddr_reg = 320*(y_pixel>>1) + (319-(x_pixel>>1));
    always_comb begin
        if(scanning && !DE) imgPxlAddr = DetectorAddr;
        else                imgPxlAddr = imgPxlAddr_reg;
    end
    
    // filter
    always_comb begin
        if(vgaArea) begin
            case({region_BLUE, region_RED})
                8'b0000_0000: {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                // RED
                8'b0000_0001: if((x_pixel >=   0) && (x_pixel < 160)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0,imgPxlData[4:2]}};
                              else                                    {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                8'b0000_0010: if((x_pixel >= 160) && (x_pixel < 320)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0,imgPxlData[4:2]}};
                              else                                    {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                8'b0000_0100: if((x_pixel >= 320) && (x_pixel < 480)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0,imgPxlData[4:2]}};
                              else                                    {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                8'b0000_1000: if((x_pixel >= 480) && (x_pixel < 640)) {port_red, port_green, port_blue} = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0,imgPxlData[4:2]}};
                              else                                    {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                // BLUE
                8'b0001_0000: if((x_pixel >=   0) && (x_pixel < 160)) {port_red, port_green, port_blue} = {8'd0, imgPxlData[4:1]};
                              else                                    {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                8'b0010_0000: if((x_pixel >= 160) && (x_pixel < 320)) {port_red, port_green, port_blue} = {8'd0, imgPxlData[4:1]};
                              else                                    {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                8'b0100_0000: if((x_pixel >= 320) && (x_pixel < 480)) {port_red, port_green, port_blue} = {8'd0, imgPxlData[4:1]};
                              else                                    {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                8'b1000_0000: if((x_pixel >= 480) && (x_pixel < 640)) {port_red, port_green, port_blue} = {8'd0, imgPxlData[4:1]};
                              else                                    {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                // BLUE = RED 
                8'b0001_0001: if((x_pixel >=   0) && (x_pixel < 160)) {port_red, port_green, port_blue} = {imgPxlData[15:12], 4'd0, imgPxlData[4:1]};
                              else                                    {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                8'b0010_0010: if((x_pixel >= 160) && (x_pixel < 320)) {port_red, port_green, port_blue} = {imgPxlData[15:12], 4'd0, imgPxlData[4:1]};
                              else                                    {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                8'b0100_0100: if((x_pixel >= 320) && (x_pixel < 480)) {port_red, port_green, port_blue} = {imgPxlData[15:12], 4'd0, imgPxlData[4:1]};
                              else                                    {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                8'b1000_1000: if((x_pixel >= 480) && (x_pixel < 640)) {port_red, port_green, port_blue} = {imgPxlData[15:12], 4'd0, imgPxlData[4:1]};
                              else                                    {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                // BLUEX & RED0
                8'b0010_0001: begin
                    if     ((x_pixel >=   0) && (x_pixel < 160)) {port_red, port_green, port_blue} = {imgPxlData[15:12], 8'd0};
                    else if((x_pixel >= 160) && (x_pixel < 320)) {port_red, port_green, port_blue} = {8'd0, imgPxlData[4:1]};
                    else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12],   imgPxlData[10:7], imgPxlData[4:1]};
                end
                8'b0100_0001: begin
                    if     ((x_pixel >=   0) && (x_pixel < 160)) {port_red, port_green, port_blue} = {imgPxlData[15:12], 4'd0, 4'd0};
                    else if((x_pixel >= 320) && (x_pixel < 480)) {port_red, port_green, port_blue} = {4'd0, 4'd0, imgPxlData[4:1]};
                    else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12],   imgPxlData[10:7], imgPxlData[4:1]};
                end
                8'b1000_0001: begin
                    if     ((x_pixel >=   0) && (x_pixel < 160)) {port_red, port_green, port_blue} = {imgPxlData[15:12], 8'd0};
                    else if((x_pixel >= 480) && (x_pixel < 640)) {port_red, port_green, port_blue} = {8'd0, imgPxlData[4:1]};
                    else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12],   imgPxlData[10:7], imgPxlData[4:1]};
                end
                // BLUEX & RED1
                8'b0001_0010: begin
                    if     ((x_pixel >= 160) && (x_pixel < 320)) {port_red, port_green, port_blue} = {imgPxlData[15:12], 8'd0};
                    else if((x_pixel >=   0) && (x_pixel < 160)) {port_red, port_green, port_blue} = {8'd0, imgPxlData[4:1]};
                    else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12],   imgPxlData[10:7], imgPxlData[4:1]};
                end
                8'b0100_0010: begin
                    if     ((x_pixel >= 160) && (x_pixel < 320)) {port_red, port_green, port_blue} = {imgPxlData[15:12], 8'd0};
                    else if((x_pixel >= 320) && (x_pixel < 480)) {port_red, port_green, port_blue} = {8'd0, imgPxlData[4:1]};
                    else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12],   imgPxlData[10:7], imgPxlData[4:1]};
                end
                8'b1000_0010: begin
                    if     ((x_pixel >= 160) && (x_pixel < 320)) {port_red, port_green, port_blue} = {imgPxlData[15:12], 8'd0};
                    else if((x_pixel >= 480) && (x_pixel < 640)) {port_red, port_green, port_blue} = {8'd0, imgPxlData[4:1]};
                    else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12],   imgPxlData[10:7], imgPxlData[4:1]};
                end
                // BLUEX & RED2
                8'b0001_0100: begin
                    if     ((x_pixel >= 320) && (x_pixel < 480)) {port_red, port_green, port_blue} = {imgPxlData[15:12], 8'd0};
                    else if((x_pixel >=   0) && (x_pixel < 160)) {port_red, port_green, port_blue} = {8'd0, imgPxlData[4:1]};
                    else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12],   imgPxlData[10:7], imgPxlData[4:1]};
                end
                8'b0010_0100: begin
                    if     ((x_pixel >= 320) && (x_pixel < 480)) {port_red, port_green, port_blue} = {imgPxlData[15:12], 8'd0};
                    else if((x_pixel >= 160) && (x_pixel < 320)) {port_red, port_green, port_blue} = {8'd0, imgPxlData[4:1]};
                    else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12],   imgPxlData[10:7], imgPxlData[4:1]};
                end
                8'b1000_0100: begin
                    if     ((x_pixel >= 320) && (x_pixel < 480)) {port_red, port_green, port_blue} = {imgPxlData[15:12], 8'd0};
                    else if((x_pixel >= 480) && (x_pixel < 640)) {port_red, port_green, port_blue} = {8'd0, imgPxlData[4:1]};
                    else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12],   imgPxlData[10:7], imgPxlData[4:1]};
                end
                // BLUEX & RED3
                8'b0001_1000: begin
                    if     ((x_pixel >= 480) && (x_pixel < 640)) {port_red, port_green, port_blue} = {imgPxlData[15:12], 8'd0};
                    else if((x_pixel >=   0) && (x_pixel < 160)) {port_red, port_green, port_blue} = {8'd0, imgPxlData[4:1]};
                    else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12],   imgPxlData[10:7], imgPxlData[4:1]};
                end
                8'b0010_1000: begin
                    if     ((x_pixel >= 480) && (x_pixel < 640)) {port_red, port_green, port_blue} = {imgPxlData[15:12], 8'd0};
                    else if((x_pixel >= 160) && (x_pixel < 320)) {port_red, port_green, port_blue} = {8'd0, imgPxlData[4:1]};
                    else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12],   imgPxlData[10:7], imgPxlData[4:1]};
                end
                8'b0100_1000: begin
                    if     ((x_pixel >= 480) && (x_pixel < 640)) {port_red, port_green, port_blue} = {imgPxlData[15:12], 8'd0};
                    else if((x_pixel >= 320) && (x_pixel < 480)) {port_red, port_green, port_blue} = {8'd0, imgPxlData[4:1]};
                    else                                         {port_red, port_green, port_blue} = {imgPxlData[15:12],   imgPxlData[10:7], imgPxlData[4:1]};
                end
            endcase
        end else begin
            {port_red, port_green, port_blue} = 0;
        end
    end

    RegionDetector U_Region_Detector(
        .clk(clk),
        .reset(reset),
        .vsync(vsync),
        .DE(DE),
        .frame_data(imgPxlData),
        .frame_addr(DetectorAddr),
        .scanning(scanning),
        .region_RED(region_RED),
        .region_BLUE(region_BLUE)
    );

endmodule
