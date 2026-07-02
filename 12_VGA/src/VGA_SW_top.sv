module VGA_SW_top(
    input  logic clk,
    input  logic reset,
    input  logic [3:0] sw_red,
    input  logic [3:0] sw_green,
    input  logic [3:0] sw_blue,
    input  logic       sw_ctrl,
    input  logic       sw_scale,
    output logic       h_sync,
    output logic       v_sync,
    output logic [3:0] port_red,
    output logic [3:0] port_green,
    output logic [3:0] port_blue
);

    logic [9:0] x_pixel;
    logic [9:0] y_pixel;
    logic       de;
    logic [3:0] rgb_sw_red, rgb_sw_green, rgb_sw_blue;
    logic [3:0] rgb_cb_red, rgb_cb_green, rgb_cb_blue;
    logic [3:0] rgb_img_red, rgb_img_green, rgb_img_blue;

    logic [$clog2(320*240)-1:0] addr;
    logic [15:0] imgPxlData;

    VGA_Decoder U_VGA_Decode(
        .clk(clk),
        .reset(reset),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .de(de)
    ); 
    ImgROM U_ImgROM(
        .addr(addr),
        .data(imgPxlData)
    );
    ImgRomReader U_ImgRomReader(
        .de(de),
        .sw_ctrl(sw_ctrl),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .addr(addr),
        .imgPxlData(imgPxlData),
        .port_red(rgb_img_red),
        .port_green(rgb_img_green),
        .port_blue(rgb_img_blue)
    );
    VGA_RGB_SW U_VGA_RGB_SW(
        .sw_red(sw_red),
        .sw_green(sw_green),
        .sw_blue(sw_blue),
        .de(de),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .port_red(rgb_sw_red),
        .port_green(rgb_sw_green),
        .port_blue(rgb_sw_blue)
    );
    VGA_ColorBox U_VGA_ColorBox(
        .de(de),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .port_red(rgb_cb_red),
        .port_green(rgb_cb_green),
        .port_blue(rgb_cb_blue)
    );
    MUX_3X1 U_MUX_RGB(
        .sel({sw_scale, sw_ctrl}),
        .rgb_sw({rgb_sw_red, rgb_sw_green, rgb_sw_blue}),
        .rgb_colorbox({rgb_cb_red, rgb_cb_green, rgb_cb_blue}),
        .rgb_image({rgb_img_red, rgb_img_green, rgb_img_blue}),
        .rgb_out({port_red, port_green, port_blue})
    );
endmodule


module MUX_2X1(
    input  logic        sw_ctrl,
    input  logic [11:0] rgb_sw,
    input  logic [11:0] rgb_colorbox,
    output logic [11:0] rgb_out
);
    assign rgb_out = sw_ctrl? rgb_colorbox : rgb_sw;
endmodule


module MUX_3X1(
    input  logic [2:0]  sel,
    input  logic [11:0] rgb_sw,
    input  logic [11:0] rgb_colorbox,
    input  logic [11:0] rgb_image,
    output logic [11:0] rgb_out
);
    always_comb begin
        if(sel == 2'b00) rgb_out = rgb_sw;
        if(sel == 2'b01) rgb_out = rgb_colorbox;
        if(sel == 2'b10 || sel == 2'b11) rgb_out = rgb_image;
    end
endmodule