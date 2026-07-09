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
    // output logic        pushed,
    output logic [3:0]  region
);
    logic vgaArea;
    assign vgaArea = (x_pixel < 640) && (y_pixel < 480);

    // filter
    always_comb begin
        if(vgaArea) begin
            if(!(imgPxlData[15:12] >= 4'b1110)) begin
                case(region)
                    4'b0000: {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                    4'b0001: if((x_pixel >=   0) && (x_pixel <  80)) {port_red, port_green, port_blue} = {imgPxlData[15:12]+4, imgPxlData[10:7], imgPxlData[4:1]};
                             else                                    {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                    4'b0010: if((x_pixel >=  80) && (x_pixel < 160)) {port_red, port_green, port_blue} = {imgPxlData[15:12]+4, imgPxlData[10:7], imgPxlData[4:1]};
                             else                                    {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                    4'b0100: if((x_pixel >= 160) && (x_pixel < 240)) {port_red, port_green, port_blue} = {imgPxlData[15:12]+4, imgPxlData[10:7], imgPxlData[4:1]};
                             else                                    {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                    4'b1000: if((x_pixel >= 240) && (x_pixel < 320)) {port_red, port_green, port_blue} = {imgPxlData[15:12]+4, imgPxlData[10:7], imgPxlData[4:1]};
                             else                                    {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                endcase
            end else begin
                {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
            end
            // case(region)
            //     4'b0000: {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
            //     4'b0001: if((x_pixel >=   0) && (x_pixel <  80)) {port_red, port_green, port_blue} = {imgPxlData[15:12], 4'd0, 4'd0};
            //              else                                    {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
            //     4'b0010: if((x_pixel >=  80) && (x_pixel < 160)) {port_red, port_green, port_blue} = {imgPxlData[15:12], 4'd0, 4'd0};
            //              else                                    {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
            //     4'b0100: if((x_pixel >= 160) && (x_pixel < 240)) {port_red, port_green, port_blue} = {imgPxlData[15:12], 4'd0, 4'd0};
            //              else                                    {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
            //     4'b1000: if((x_pixel >= 240) && (x_pixel < 320)) {port_red, port_green, port_blue} = {imgPxlData[15:12], 4'd0, 4'd0};
            //              else                                    {port_red, port_green, port_blue} = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
            // endcase
        end else begin
            {port_red, port_green, port_blue} = 0;

        end
    end

    Region_Detector U_Region_Detector(
        .clk(clk),
        .reset(reset),
        .vsync(vsync),
        .DE(DE),
        .frame_data(imgPxlData),
        .frame_addr(imgPxlAddr),
        .scanning(scanning),
        // .pushed(pushed),
        .region(region)
    );

endmodule
