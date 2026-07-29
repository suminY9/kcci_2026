module FrameManager(
    input  logic        de,
    input  logic [9:0]  x_pixel_VGA,
    input  logic [9:0]  y_pixel_VGA,
    input  logic [15:0] imgPxlData,
    output logic [16:0] imgPxlAddr,
    output logic [11:0] portRGB
);

    // VGA 640x480 -> QVGA 320x240 좌표
    logic [9:0] x_pixel, y_pixel;
    assign x_pixel = x_pixel_VGA >> 1;
    assign y_pixel = y_pixel_VGA >> 1;

    // ------------------------------------------------------------------------
    // 화면 중앙 28x28 영역 정의 (QVGA 320x240 기준)
    // Center X: 160 -> 146 ~ 173 (28 pixels)
    // Center Y: 120 -> 106 ~ 133 (28 pixels)
    // ------------------------------------------------------------------------
    logic in_display_28x28;
    assign in_display_28x28 = (x_pixel >= 10'd146) && (x_pixel < 10'd174) &&
                              (y_pixel >= 10'd106) && (y_pixel < 10'd134);

    // 28x28 영역 내부에서의 상대 좌표 (0 ~ 27)
    logic [4:0] rel_x, rel_y;
    assign rel_x = x_pixel - 10'd146;
    assign rel_y = y_pixel - 10'd106;

    // ------------------------------------------------------------------------
    // 원본 192x192 중앙 영역(X: 64~255, Y: 24~215)에서 
    // 28x28 좌표를 192x192 좌표로 복원 (Nearest Neighbor: rel * 192 / 28 = rel * 48 / 7)
    // ------------------------------------------------------------------------
    logic [9:0] orig_crop_x, orig_crop_y;
    assign orig_crop_x = 10'd64 + ((rel_x * 48) / 7);
    assign orig_crop_y = 10'd24 + ((rel_y * 48) / 7);

    // BRAM Read 주소 선택
    // 28x28 영역을 그릴 때는 건너뛴 샘플링 주소를 읽고, 아니면 0번지 읽음
    assign imgPxlAddr = in_display_28x28 ? (320 * orig_crop_y + orig_crop_x) : 17'd0;

    // RGB 및 흑백 변환
    logic [11:0] RGBcrop, RGBmono;
    assign RGBcrop = in_display_28x28 ? {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]} : 12'h0;

    FrameMono U_FrameMono(
        .i_rgb(RGBcrop),
        .o_rgb(RGBmono)
    );

    assign portRGB = de ? RGBmono : 12'h000;
    // assign portRGB = de ? RGBcrop : 12'h000;

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
