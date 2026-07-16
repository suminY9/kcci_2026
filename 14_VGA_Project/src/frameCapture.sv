module frameCapture(
    input  logic        clk,  // 100MHz
    input  logic        reset,
    input  logic        vsync,
    input  logic        capture,
    input  logic [9:0]  x_pixel_VGA,
    input  logic [9:0]  y_pixel_VGA,
    input  logic [15:0] imgPxlData,
    output logic [$clog2(320*240)-1:0] imgPxlAddr,
    output logic [11:0] wData_cap,
    output logic [$clog2(80*110)-1:0] wAddr_cap,
    output logic        we_cap,
    output logic        done_cap,
    output logic [11:0] RGBport
);

    logic [11:0] RGB_capture;

    logic [9:0] x_pixel, y_pixel;
    assign x_pixel = x_pixel_VGA >> 1;
    assign y_pixel = y_pixel_VGA >> 1;
    assign imgPxlAddr = 320*(y_pixel) + (319-(x_pixel));
    
    Capture U_capture(
        .clk(clk),
        .reset(reset),
        .vsync(vsync),
        .capture(capture),
        .x_pixel_QVGA(x_pixel),
        .y_pixel_QVGA(y_pixel),
        .imgPxlData(imgPxlData),
        .wAddr_cap(wAddr_cap),
        .wData_cap(wData_cap),
        .we_cap(we_cap),
        .o_rgb(RGB_capture),
        .done(done_cap)
    );
    mux_2x1 #(
        .BIT_DEPTH(12)
    ) U_MUX (
        .sel(capture && !done_cap),
        .in0(RGB_capture),
        .in1(12'h000),
        .out(RGBport)
    );
endmodule


module Capture(
    input  logic        clk,
    input  logic        reset,
    input  logic        vsync,
    input  logic        capture,
    input  logic [9:0]  x_pixel_QVGA,
    input  logic [9:0]  y_pixel_QVGA,
    input  logic [15:0] imgPxlData,
    // captureRAM
    output logic [$clog2(80*110)-1:0] wAddr_cap,
    output logic [11:0] wData_cap,
    output logic        we_cap,
    // frame output
    output logic [11:0] o_rgb,
    output logic        done
);
    logic [$clog2(100_000_000)-1:0] cnt_reg;

    localparam IDLE = 0, RD3 = 1, RD2 = 2, RD1 = 3, CAP = 4, DONE = 5;
    localparam P1 = 1, P2 = 2, P3 = 3;
    logic [2:0] state;
    logic [1:0] CAPstate;

    // logic [80*110-1:0] capDone;
    logic [$clog2(80*110)-1:0] cap_cnt;

// 1. QVGA(320x240) 중앙의 80x110 영역 검출 (가로: 120~199, 세로: 65~174)
    logic DE_QQQVGA;
    assign DE_QQQVGA = (x_pixel_QVGA >= 10'd120 && x_pixel_QVGA < 10'd200) && 
                       (y_pixel_QVGA >= 10'd65  && y_pixel_QVGA < 10'd175);

    // 2. 오프셋을 적용한 상대 좌표 계산 (가로: 0~79, 세로: 0~109)
    logic [9:0] x_pixel, y_pixel;
    assign x_pixel = DE_QQQVGA ? (x_pixel_QVGA - 10'd120) : '0;
    assign y_pixel = DE_QQQVGA ? (y_pixel_QVGA - 10'd65)  : '0;

    // x: 115~194 (80), y: 45~144 (110)
    // assign wAddr_cap = (x_pixel - 115) + (y_pixel - 45) * 80;
    // assign wData_cap = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
    // assign we_cap = ((state == CAP && CAPstate == P3)
    //                 && (x_pixel >= 115 && x_pixel < 195) && (y_pixel >= 45 && y_pixel < 145)
    //                 && !capDone[wAddr_cap]) ? 1'b1 : 1'b0;

    // wire [15:0] y_offset = y_pixel - 45;
    // assign wAddr_cap = (x_pixel - 115) + ((y_offset << 6) + ((y_offset << 4)));
    // assign wData_cap = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
    // assign we_cap = ((state == CAP && CAPstate == P3)
                    // && (x_pixel >= 115 && x_pixel < 195) && (y_pixel >= 45 && y_pixel < 145)
                    // && !capDone[wAddr_cap]) ? 1'b1 : 1'b0;

    always_ff @(posedge clk, posedge reset) begin
        if(reset) begin
            state    <= IDLE;
            CAPstate <= IDLE;
            done     <= 1'b0;
            // capDone  <= 0;
            cnt_reg  <= 0;
        end else begin
            case(state)
                IDLE: begin
                    if(capture) begin
                        state    <= RD3;
                        CAPstate <= IDLE;
                        done     <= 1'b0;
                        // capDone  <= 0;
                        cap_cnt  <= 0;
                        cnt_reg  <= 0;
                    end
                end
                RD3: begin
                    if(cnt_reg == 100_000_000 -1) begin
                        cnt_reg <= 0;
                        state   <= RD2;
                    end else begin
                        cnt_reg <= cnt_reg + 1;
                    end
                end
                RD2: begin
                    if(cnt_reg == 100_000_000 -1) begin
                        cnt_reg <= 0;
                        state   <= RD1;
                    end else begin
                        cnt_reg <= cnt_reg + 1;
                    end
                end
                RD1: begin
                    if(cnt_reg == 100_000_000 -1) begin
                        cnt_reg <= 0;
                        state   <= CAP;
                    end else begin
                        cnt_reg <= cnt_reg + 1;
                    end
                end
                CAP: begin
                    case(CAPstate)
                        P1: begin
                            if(cnt_reg == 100_000_000 -1) begin
                                cnt_reg  <= 0;
                                CAPstate <= P2;
                            end else begin
                                cnt_reg <= cnt_reg + 1;
                            end
                                end
                        P2: begin
                            CAPstate <= P3;
                        end
                        P3: begin
                            // if (we_cap) begin
                            //     capDone[(x_pixel-115) + (y_pixel-45)*80] <= 1'b1;
                            //     cap_cnt <= cap_cnt + 1;
                            if(vsync && cap_cnt < 60*110) begin
                                we_cap    <= 1'b1;
                                wData_cap <= {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                                wAddr_cap <= cap_cnt;
                                cap_cnt   <= cap_cnt + 1;
                            end
                            if (vsync && cap_cnt == 80*110) begin
                                we_cap   <= 1'b0;
                                state    <= DONE;
                                CAPstate <= IDLE;
                            end
                        end
                    endcase
                end
                DONE: begin
                    state <= IDLE;
                    done <= 1'b1;
                end
            endcase
        end
    end

    always_comb begin
        o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
        case(state)
            RD3: begin
                /*** 3 ***/
                if     ((x_pixel >= 110) && (x_pixel < 200) && (y_pixel >=  40) && (y_pixel <  60)) o_rgb = 0;
                else if((x_pixel >= 110) && (x_pixel < 200) && (y_pixel >= 110) && (y_pixel < 130)) o_rgb = 0;
                else if((x_pixel >= 110) && (x_pixel < 200) && (y_pixel >= 180) && (y_pixel < 200)) o_rgb = 0;
                else if((x_pixel >= 200) && (x_pixel < 220) && (y_pixel >=  40) && (y_pixel < 200)) o_rgb = 0;
                else o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
            end
            RD2: begin
                /*** 2 ***/
                if     ((x_pixel >= 110) && (x_pixel < 220) && (y_pixel >=  40) && (y_pixel <  60)) o_rgb = 0;
                else if((x_pixel >= 110) && (x_pixel < 220) && (y_pixel >= 110) && (y_pixel < 130)) o_rgb = 0;
                else if((x_pixel >= 110) && (x_pixel < 220) && (y_pixel >= 180) && (y_pixel < 200)) o_rgb = 0;
                else if((x_pixel >= 200) && (x_pixel < 220) && (y_pixel >=  40) && (y_pixel < 130)) o_rgb = 0;
                else if((x_pixel >= 110) && (x_pixel < 130) && (y_pixel >= 130) && (y_pixel < 200)) o_rgb = 0;
                else o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
            end
            RD1: begin
                /*** 1 ***/
                if     ((x_pixel >= 120) && (x_pixel < 150) && (y_pixel >=  50) && (y_pixel <  70)) o_rgb = 0;
                else if((x_pixel >= 120) && (x_pixel < 200) && (y_pixel >= 180) && (y_pixel < 200)) o_rgb = 0;
                else if((x_pixel >= 150) && (x_pixel < 170) && (y_pixel >=  40) && (y_pixel < 200)) o_rgb = 0;
                else o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
            end
            CAP: begin
                case(CAPstate)
                    P1: begin
                        /*** face guide ***/
                        if     ((x_pixel >= 110) && (x_pixel < 200) && (y_pixel >=  40) && (y_pixel <  45)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
                        else if((x_pixel >= 110) && (x_pixel < 120) && (y_pixel >=  40) && (y_pixel < 150)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
                        else if((x_pixel >= 195) && (x_pixel < 200) && (y_pixel >=  40) && (y_pixel < 150)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
                        else if((x_pixel >= 110) && (x_pixel < 200) && (y_pixel >= 145) && (y_pixel < 150)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
                        else o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                    end
                    P2: begin
                        /*** shot ***/
                        if     ((x_pixel >= 110) && (x_pixel < 200) && (y_pixel >=  40) && (y_pixel <  45)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
                        else if((x_pixel >= 110) && (x_pixel < 115) && (y_pixel >=  40) && (y_pixel < 150)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
                        else if((x_pixel >= 195) && (x_pixel < 200) && (y_pixel >=  40) && (y_pixel < 150)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
                        else if((x_pixel >= 110) && (x_pixel < 200) && (y_pixel >= 145) && (y_pixel < 150)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
                        else o_rgb = 12'hfff;
                    end
                    P3: begin
                        o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                    //     if((capDone[80*110-1] == 1'b1)) begin
                    //         if((x_pixel >= 115) && (x_pixel < 195) && (y_pixel >= 45) && (y_pixel < 145))
                    //              o_rgb = capImg[x_pixel*y_pixel];
                    //         else o_rgb = 12'h000;
                    //     end else begin
                    //         if((x_pixel >= 115) && (x_pixel < 195) && (y_pixel >= 45) && (y_pixel < 145)) begin
                    //             capImg[x_pixel*y_pixel]  = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                    //             capDone[x_pixel*y_pixel] = 1'b1;
                    //         end
                    //     end
                    end
                endcase
            end
            default: begin
                o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
            end
        endcase
    end
endmodule