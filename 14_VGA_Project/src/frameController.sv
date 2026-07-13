module frameController(
    // input  logic        clk,
    // input  logic        reset,
    input  logic        capture,
    input  logic [9:0]  note_x,
    input  logic [9:0]  note_y,
    input  logic [9:0]  x_pixel_VGA,
    input  logic [9:0]  y_pixel_VGA,
    input  logic [3:0]  region,
    input  logic [15:0] imgPxlData,
    output logic [$clog2(320*240)-1:0] imgPxlAddr,
    // output logic [$clog2(80*110)-1:0] wAddr_cap;
    // output logic [11:0] wData_cap;
    // output logic        we_cap;
    output logic [11:0] RGBport
);

    logic [11:0] RGB_region;
    logic [11:0] RGB_game;
    logic [11:0] RGB_capture;
    logic done_cap;

    // frame upscale -VGA: 640 * 320
    logic [9:0] x_pixel, y_pixel;
    assign x_pixel = x_pixel_VGA >> 1;
    assign y_pixel = y_pixel_VGA >> 1;
    assign imgPxlAddr = 320*(y_pixel) + (319-(x_pixel));


    Filter_Region U_Filter_REG(
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .region(region),
        .imgPxlData(imgPxlData),
        .imgPxlAddr(imgPxlAddr),
        .o_rgb(RGB_region)
    );
    Filter_GAME U_Filter_GAME(
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .i_rgb(RGB_region),
        .o_rgb(RGBport)
    );
    // Capture U_Capture(
    //     .clk(clk),
    //     .reset(reset),
    //     .capture(capture),
    //     .x_pixel(x_pixel),
    //     .y_pixel(y_pixel),
    //     .imgPxlData(imgPxlData),
    //     .wAddr_cap(wAddr_cap),
    //     .wData_cap(wData_cap),
    //     .we_cap(we_cap),
    //     .o_rgb(RGB_capture),
    //     .done(done_cap)
    // );

    // mux_2x1 #(
    //     .BIT_DEPTH(12)
    // ) (
    //     .sel(capture && !done_cap),
    //     .in1(RGB_capture),
    //     .in2(RGB_game),
    //     .out(RGBport)
    // )
endmodule


// module mux_2x1#(
//     parameter BIT_DEPTH = 16
// ) (
//     input  logic                 sel,
//     input  logic [BIT_DEPTH-1:0] in1,
//     input  logic [BIT_DEPTH-1:0] in2,
//     output logic [BIT_DEPTH-1:0] out
// );
//     assign out = sel? in1 : in2;
// endmodule


module Filter_Region(
    input  logic [9:0]  x_pixel,
    input  logic [9:0]  y_pixel,
    input  logic [3:0]  region,
    input  logic [15:0] imgPxlData,
    output logic [$clog2(320*240)-1:0] imgPxlAddr,
    output logic [11:0] o_rgb
);
    // frame upscale -VGA: 640 * 320
    logic vgaArea;
    assign vgaArea = (x_pixel < 640) && (y_pixel < 480);

    always_comb begin
        if(vgaArea) begin
            case(region)
                4'b0001:      if((x_pixel >=   0) && (x_pixel < 80)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b0010:      if((x_pixel >=  80) && (x_pixel < 160)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b0100:      if((x_pixel >= 160) && (x_pixel < 240)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b1000:      if((x_pixel >= 240) && (x_pixel < 320)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b0011:      if((x_pixel >=   0) && (x_pixel <  80)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >=  80) && (x_pixel < 160)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b0101:      if((x_pixel >=   0) && (x_pixel <  80)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 160) && (x_pixel < 240)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b1001:      if((x_pixel >=   0) && (x_pixel <  80)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 240) && (x_pixel < 320)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b0110:      if((x_pixel >=  80) && (x_pixel < 160)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 160) && (x_pixel < 240)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b1010:      if((x_pixel >=  80) && (x_pixel < 160)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 240) && (x_pixel < 320)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b1100:      if((x_pixel >= 160) && (x_pixel < 240)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 240) && (x_pixel < 320)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b0111:      if((x_pixel >=   0) && (x_pixel <  80)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >=  80) && (x_pixel < 160)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 160) && (x_pixel < 240)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b1011:      if((x_pixel >=   0) && (x_pixel <  80)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >=  80) && (x_pixel < 160)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 240) && (x_pixel < 320)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b1101:      if((x_pixel >=   0) && (x_pixel <  80)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 160) && (x_pixel < 240)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 240) && (x_pixel < 320)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b1110:      if((x_pixel >=  80) && (x_pixel < 160)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 160) && (x_pixel < 240)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else if((x_pixel >= 240) && (x_pixel < 320)) o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                         else                                         o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                4'b1111: o_rgb = {imgPxlData[15:12], {1'b0, imgPxlData[10:8]}, {1'b0, imgPxlData[4:2]}};
                4'b0000: o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
            endcase
        end else begin
            o_rgb = 0;
        end
    end
endmodule


module Filter_GAME(
    input  logic [9:0]  x_pixel,
    input  logic [9:0]  y_pixel,
    input  logic [11:0] i_rgb,
    output logic [11:0] o_rgb
);
    always_comb begin
        // seperate region
        if     ((x_pixel >=  79) && (x_pixel <  81)) o_rgb = 0;
        else if((x_pixel >= 159) && (x_pixel < 161)) o_rgb = 0;
        else if((x_pixel >= 239) && (x_pixel < 241)) o_rgb = 0;
        // detecting area
        else if((y_pixel >= 200) && (y_pixel < 220)) o_rgb = {2'b00, i_rgb[11:10], 2'b00, i_rgb[7:6], 2'b00, i_rgb[3:2]};
        else o_rgb = i_rgb;
    end
endmodule


// module Capture(
//     input  logic        clk,
//     input  logic        reset,
//     input  logic        capture,
//     input  logic [9:0]  x_pixel,
//     input  logic [9:0]  y_pixel,
//     input  logic [15:0] imgPxlData,
//     // captureRAM
//     output logic [$clog2(80*110)-1:0] wAddr_cap,
//     output logic [11:0] wData_cap,
//     output logic        we_cap,
//     // frame output
//     output logic [11:0] o_rgb,
//     output logic        done
// );
//     logic [$clog2(100_000_000)-1:0] cnt_reg;

//     localparam IDLE = 0, RD3 = 1, RD2 = 2, RD1 = 3, CAP = 4, DONE = 5;
//     localparam P1 = 1, P2 = 2, P3 = 3;
//     logic [2:0] state;
//     logic [1:0] CAPstate;

//     logic [80*110-1:0] capDone;
//     logic [$clog2(80*110)-1:0] cap_cnt;

//     // x: 115~194 (80), y: 45~144 (110)
//     assign wAddr_cap = (x_pixel - 115) + (y_pixel - 45) * 80;
//     assign wData_cap = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
//     assign we_cap = ((state == CAP && CAPstate == P3)
//                     && (x_pixel >= 115 && x_pixel < 195) && (y_pixel >= 45 && y_pixel < 145)
//                     && !capDone[wAddr_cap]) ? 1'b1 : 1'b0;

//     always_ff @(posedge clk, posedge reset) begin
//         if(reset) begin
//             state    <= IDLE;
//             CAPstate <= IDLE;
//             done     <= 1'b0;
//             capDone  <= 0;
//             cnt_reg  <= 0;
//         end else begin
//             case(state)
//                 IDLE: begin
//                     if(capture) begin
//                         state    <= RD3;
//                         CAPstate <= IDLE;
//                         done     <= 1'b0;
//                         capDone  <= 0;
//                         cap_cnt  <= 0;
//                         cnt_reg  <= 0;
//                     end
//                 end
//                 RD3: begin
//                     if(cnt_reg == 100_000_000 -1) begin
//                         cnt_reg <= 0;
//                         state   <= RD2;
//                     end else begin
//                         cnt_reg <= cnt_reg + 1;
//                     end
//                 end
//                 RD2: begin
//                     if(cnt_reg == 100_000_000 -1) begin
//                         cnt_reg <= 0;
//                         state   <= RD1;
//                     end else begin
//                         cnt_reg <= cnt_reg + 1;
//                     end
//                 end
//                 RD1: begin
//                     if(cnt_reg == 100_000_000 -1) begin
//                         cnt_reg <= 0;
//                         state   <= CAP;
//                     end else begin
//                         cnt_reg <= cnt_reg + 1;
//                     end
//                 end
//                 CAP: begin
//                     case(CAPstate)
//                         P1: begin
//                             if(cnt_reg == 100_000_000 -1) begin
//                                 cnt_reg  <= 0;
//                                 CAPstate <= P2;
//                             end else begin
//                                 cnt_reg <= cnt_reg + 1;
//                             end
//                                 end
//                         P2: begin
//                             CAPstate <= P3;
//                         end
//                         P3: begin
//                             if (we_cap) begin
//                                 capDone[(x_pixel-115) + (y_pixel-45)*80] <= 1'b1;
//                                 cap_cnt <= cap_cnt + 1;
//                             end
//                             if (cap_cnt == 80*110) begin
//                                 state    <= DONE;
//                                 CAPstate <= IDLE;
//                             end
//                         end
//                     endcase
//                 end
//                 DONE: begin
//                     state <= IDLE;
//                     done <= 1'b1;
//                 end
//             endcase
//         end
//     end

//     always_comb begin
//         o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
//         case(state)
//             RD3: begin
//                 /*** 3 ***/
//                 if     ((x_pixel >= 110) && (x_pixel < 200) && (y_pixel >=  40) && (y_pixel <  60)) o_rgb = 0;
//                 else if((x_pixel >= 110) && (x_pixel < 200) && (y_pixel >= 110) && (y_pixel < 130)) o_rgb = 0;
//                 else if((x_pixel >= 110) && (x_pixel < 200) && (y_pixel >= 180) && (y_pixel < 200)) o_rgb = 0;
//                 else if((x_pixel >= 200) && (x_pixel < 220) && (y_pixel >=  40) && (y_pixel < 200)) o_rgb = 0;
//                 else o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
//             end
//             RD2: begin
//                 /*** 2 ***/
//                 if     ((x_pixel >= 110) && (x_pixel < 220) && (y_pixel >=  40) && (y_pixel <  60)) o_rgb = 0;
//                 else if((x_pixel >= 110) && (x_pixel < 220) && (y_pixel >= 110) && (y_pixel < 130)) o_rgb = 0;
//                 else if((x_pixel >= 110) && (x_pixel < 220) && (y_pixel >= 180) && (y_pixel < 200)) o_rgb = 0;
//                 else if((x_pixel >= 200) && (x_pixel < 220) && (y_pixel >=  40) && (y_pixel < 130)) o_rgb = 0;
//                 else if((x_pixel >= 110) && (x_pixel < 130) && (y_pixel >= 130) && (y_pixel < 200)) o_rgb = 0;
//                 else o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
//             end
//             RD1: begin
//                 /*** 1 ***/
//                 if     ((x_pixel >= 120) && (x_pixel < 150) && (y_pixel >=  50) && (y_pixel <  70)) o_rgb = 0;
//                 else if((x_pixel >= 120) && (x_pixel < 200) && (y_pixel >= 180) && (y_pixel < 200)) o_rgb = 0;
//                 else if((x_pixel >= 150) && (x_pixel < 170) && (y_pixel >=  40) && (y_pixel < 200)) o_rgb = 0;
//                 else o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
//             end
//             CAP: begin
//                 case(CAPstate)
//                     P1: begin
//                         /*** face guide ***/
//                         if     ((x_pixel >= 110) && (x_pixel < 200) && (y_pixel >=  40) && (y_pixel <  45)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
//                         else if((x_pixel >= 110) && (x_pixel < 120) && (y_pixel >=  40) && (y_pixel < 150)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
//                         else if((x_pixel >= 195) && (x_pixel < 200) && (y_pixel >=  40) && (y_pixel < 150)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
//                         else if((x_pixel >= 110) && (x_pixel < 200) && (y_pixel >= 145) && (y_pixel < 150)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
//                         else o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
//                     end
//                     P2: begin
//                         /*** shot ***/
//                         if     ((x_pixel >= 110) && (x_pixel < 200) && (y_pixel >=  40) && (y_pixel <  45)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
//                         else if((x_pixel >= 110) && (x_pixel < 115) && (y_pixel >=  40) && (y_pixel < 150)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
//                         else if((x_pixel >= 195) && (x_pixel < 200) && (y_pixel >=  40) && (y_pixel < 150)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
//                         else if((x_pixel >= 110) && (x_pixel < 200) && (y_pixel >= 145) && (y_pixel < 150)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
//                         else o_rgb = 12'hfff;
//                     end
//                     P3: begin
//                         o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
//                     //     if((capDone[80*110-1] == 1'b1)) begin
//                     //         if((x_pixel >= 115) && (x_pixel < 195) && (y_pixel >= 45) && (y_pixel < 145))
//                     //              o_rgb = capImg[x_pixel*y_pixel];
//                     //         else o_rgb = 12'h000;
//                     //     end else begin
//                     //         if((x_pixel >= 115) && (x_pixel < 195) && (y_pixel >= 45) && (y_pixel < 145)) begin
//                     //             capImg[x_pixel*y_pixel]  = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
//                     //             capDone[x_pixel*y_pixel] = 1'b1;
//                     //         end
//                     //     end
//                     end
//                 endcase
//             end
//             default: begin
//                 o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
//             end
//         endcase
//     end
// endmodule