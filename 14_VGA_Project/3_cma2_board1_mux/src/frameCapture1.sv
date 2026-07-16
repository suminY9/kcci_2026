module frameCapture(
    input  logic        clk,
    input  logic        reset,
    input  logic        capture,
    input  logic        vsync,
    input  logic [9:0]  x_pixel_VGA,
    input  logic [9:0]  y_pixel_VGA,
    input  logic [15:0] imgPxlData,
    output logic [$clog2(80*60)-1:0] imgPxlAddr,
    output logic [11:0] wData_cap,
    output logic [$clog2(80*60)-1:0] wAddr_cap,
    output logic        we_cap,
    output logic        done_cap,
    output logic [11:0] RGBport
);

    logic [11:0] RGB_capture;

    assign x_pixel = x_pixel_VGA >> 1;
    assign y_pixel = y_pixel_VGA >> 1;
    assign imgPxlAddr = 320*(y_pixel) + x_pixel;

    Capture U_capture(
        .clk(clk),
        .reset(reset),
        .capture(capture),
        .vsync(vsync),
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
        .in1(12'hf0f),
        .out(RGBport)
    );

endmodule


module Capture(
    input  logic        clk,
    input  logic        reset,
    input  logic        capture,
    input  logic        vsync,
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

    logic DE_QQQVGA;
    assign DE_QQQVGA = (x_pixel_QVGA >= 130 && x_pixel_QVGA < 190) && (y_pixel_QVGA >= 80 && y_pixel_QVGA < 160);

    logic [9:0] x_pixel, y_pixel;
    assign x_pixel = DE_QQQVGA ? (y_pixel_QVGA -  80) : '0;
    assign y_pixel = DE_QQQVGA ? (189 - x_pixel_QVGA) : '0;
    assign imgPxlAddr = (80*y_pixel) + x_pixel;

    logic [$clog2(100_000_000)-1:0] cnt_reg;

    localparam IDLE = 0, RD3 = 1, RD2 = 2, RD1 = 3, CAP = 4, DONE = 5;
    localparam P1 = 1, P2 = 2, P3 = 3;
    logic [2:0] state;
    logic [1:0] CAPstate;

    logic [$clog2(80*110)-1:0] cap_cnt;


    always_ff @(posedge clk, posedge reset) begin
        if(reset) begin
            state    <= IDLE;
            CAPstate <= IDLE;
            done     <= 1'b0;
            cap_cnt  <= 1'b0;
            cnt_reg  <= 1'b0;
        end else begin
            case(state)
                IDLE: begin
                    if(capture) begin
                        state    <= RD3;
                        CAPstate <= IDLE;
                        done     <= 1'b0;
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
                            if(vsync && (cap_cnt < 60*80)) begin
                                we_cap    <= 1'b1;
                                wData_cap <= {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                                wAddr_cap <= cap_cnt;
                                cap_cnt   <= cap_cnt + 1;
                            end else if(vsync && (cap_cnt == 60*80)) begin
                                we_cap   <= 1'b0;
                                state    <= DONE;
                                CAPstate <= IDLE;
                            end
                        end
                    endcase
                end
                DONE: begin
                    state <= IDLE;
                    done  <= 1'b1;
                end
            endcase
        end
    end
    
    always_comb begin
        o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
        case(state)
            RD3: begin
                /*** 3 ***/
                if     ((x_pixel_QVGA >= 110) && (x_pixel_QVGA < 200) && (y_pixel_QVGA >=  40) && (y_pixel_QVGA <  60)) o_rgb = 0;
                else if((x_pixel_QVGA >= 110) && (x_pixel_QVGA < 200) && (y_pixel_QVGA >= 110) && (y_pixel_QVGA < 130)) o_rgb = 0;
                else if((x_pixel_QVGA >= 110) && (x_pixel_QVGA < 200) && (y_pixel_QVGA >= 180) && (y_pixel_QVGA < 200)) o_rgb = 0;
                else if((x_pixel_QVGA >= 200) && (x_pixel_QVGA < 220) && (y_pixel_QVGA >=  40) && (y_pixel_QVGA < 200)) o_rgb = 0;
                else o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
            end
            RD2: begin
                /*** 2 ***/
                if     ((x_pixel_QVGA >= 110) && (x_pixel_QVGA < 220) && (y_pixel_QVGA >=  40) && (y_pixel_QVGA <  60)) o_rgb = 0;
                else if((x_pixel_QVGA >= 110) && (x_pixel_QVGA < 220) && (y_pixel_QVGA >= 110) && (y_pixel_QVGA < 130)) o_rgb = 0;
                else if((x_pixel_QVGA >= 110) && (x_pixel_QVGA < 220) && (y_pixel_QVGA >= 180) && (y_pixel_QVGA < 200)) o_rgb = 0;
                else if((x_pixel_QVGA >= 200) && (x_pixel_QVGA < 220) && (y_pixel_QVGA >=  40) && (y_pixel_QVGA < 130)) o_rgb = 0;
                else if((x_pixel_QVGA >= 110) && (x_pixel_QVGA < 130) && (y_pixel_QVGA >= 130) && (y_pixel_QVGA < 200)) o_rgb = 0;
                else o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
            end
            RD1: begin
                /*** 1 ***/
                if     ((x_pixel_QVGA >= 120) && (x_pixel_QVGA < 150) && (y_pixel_QVGA >=  50) && (y_pixel_QVGA <  70)) o_rgb = 0;
                else if((x_pixel_QVGA >= 120) && (x_pixel_QVGA < 200) && (y_pixel_QVGA >= 180) && (y_pixel_QVGA < 200)) o_rgb = 0;
                else if((x_pixel_QVGA >= 150) && (x_pixel_QVGA < 170) && (y_pixel_QVGA >=  40) && (y_pixel_QVGA < 200)) o_rgb = 0;
                else o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
            end
            CAP: begin
                case(CAPstate)
                    P1: begin
                        /*** face guide ***/
                        if     ((x_pixel_QVGA >= 110) && (x_pixel_QVGA < 200) && (y_pixel_QVGA >=  50) && (y_pixel_QVGA <  55)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
                        else if((x_pixel_QVGA >= 110) && (x_pixel_QVGA < 120) && (y_pixel_QVGA >=  50) && (y_pixel_QVGA < 150)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
                        else if((x_pixel_QVGA >= 195) && (x_pixel_QVGA < 200) && (y_pixel_QVGA >=  50) && (y_pixel_QVGA < 150)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
                        else if((x_pixel_QVGA >= 110) && (x_pixel_QVGA < 200) && (y_pixel_QVGA >= 145) && (y_pixel_QVGA < 150)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
                        else o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                    end
                    P2: begin
                        /*** shot ***/
                        if     ((x_pixel_QVGA >= 110) && (x_pixel_QVGA < 200) && (y_pixel_QVGA >=  50) && (y_pixel_QVGA <  55)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
                        else if((x_pixel_QVGA >= 110) && (x_pixel_QVGA < 115) && (y_pixel_QVGA >=  50) && (y_pixel_QVGA < 150)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
                        else if((x_pixel_QVGA >= 195) && (x_pixel_QVGA < 200) && (y_pixel_QVGA >=  50) && (y_pixel_QVGA < 150)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
                        else if((x_pixel_QVGA >= 110) && (x_pixel_QVGA < 200) && (y_pixel_QVGA >= 145) && (y_pixel_QVGA < 150)) o_rgb = {2'b00, imgPxlData[15:14], 4'b0000, 2'b00, imgPxlData[4:3]};
                        else o_rgb = 12'hfff;
                    end
                    P3: begin
                        o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
                    end
                endcase
            end
            default: begin
                o_rgb = {imgPxlData[15:12], imgPxlData[10:7], imgPxlData[4:1]};
            end
        endcase
    end
endmodule