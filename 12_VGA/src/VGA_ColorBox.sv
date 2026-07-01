`timescale 1ns / 1ps

module VGA_ColorBox(
    input  logic       de,
    input  logic [9:0] x_pixel,
    input  logic [9:0] y_pixel,
    output logic [3:0] port_red,
    output logic [3:0] port_green,
    output logic [3:0] port_blue
);

    localparam X_MAX = 639;
    localparam Y_MAX = 479;
    localparam raw1 = 92;
    localparam raw2 = 115;
    localparam raw3 = 30;
    localparam column1 = 310;
    localparam column2 = 350;
    localparam column3 = 480;

    localparam WHITE   = 12'hfff,
               YELLOW  = 12'hff0,
               CYAN    = 12'h0ff,
               GREEN   = 12'h0f0,
               MAGENTA = 12'hf0f,
               RED     = 12'hf00,
               BLUE    = 12'h00f,
               GRAY1   = 12'hAAA,
               GRAY2   = 12'h888,
               GRAY3   = 12'h444,
               GRAY4   = 12'h111,
               BLACK   = 12'h000;

    always_comb begin
        if(de) begin
            if(y_pixel <= column1) begin
                if(x_pixel <= raw1)             {port_red, port_green, port_blue} = WHITE;
                else if (x_pixel <= raw1*2)     {port_red, port_green, port_blue} = YELLOW;
                else if (x_pixel <= raw1*3)     {port_red, port_green, port_blue} = CYAN;
                else if (x_pixel <= raw1*4)     {port_red, port_green, port_blue} = GREEN;
                else if (x_pixel <= raw1*5)     {port_red, port_green, port_blue} = MAGENTA;
                else if (x_pixel <= raw1*6)     {port_red, port_green, port_blue} = RED;
                else if (x_pixel <= X_MAX)      {port_red, port_green, port_blue} = BLUE;
            end else if(y_pixel <= column2) begin
                if(x_pixel <= raw1)             {port_red, port_green, port_blue} = BLUE;
                else if (x_pixel <= raw1*2)     {port_red, port_green, port_blue} = BLACK;
                else if (x_pixel <= raw1*3)     {port_red, port_green, port_blue} = MAGENTA;
                else if (x_pixel <= raw1*4)     {port_red, port_green, port_blue} = BLACK;
                else if (x_pixel <= raw1*5)     {port_red, port_green, port_blue} = CYAN;
                else if (x_pixel <= raw1*6)     {port_red, port_green, port_blue} = BLACK;
                else if (x_pixel <= X_MAX)      {port_red, port_green, port_blue} = WHITE;
            end else begin
                if(x_pixel <= raw2)             {port_red, port_green, port_blue} = 12'h004;
                else if(x_pixel <= raw2*2)      {port_red, port_green, port_blue} = WHITE;
                else if(x_pixel <= raw2*3)      {port_red, port_green, port_blue} = 12'h202;
                else if(x_pixel <= raw2*4)      {port_red, port_green, port_blue} = GRAY4;
                else if(x_pixel <= raw2*4 + raw3)   {port_red, port_green, port_blue} = BLACK;
                else if(x_pixel <= raw2*4 + raw3*2) {port_red, port_green, port_blue} = GRAY4;
                else if(x_pixel <= raw2*4 + raw3*3) {port_red, port_green, port_blue} = GRAY3;
                else if(x_pixel <= X_MAX)           {port_red, port_green, port_blue} = BLACK;
            end
        end else begin
            {port_red, port_green, port_blue} = BLACK;
        end
    end
endmodule