module Region_Detector(
    input  logic        clk,
    input  logic        reset,
    input  logic        vsync,
    input  logic        DE,
    input  logic [15:0] frame_data,
    output logic [15:0] frame_addr,
    output logic        scanning,
    // output logic        pushed,
    output logic [3:0]  region
);

    // edge detect
    logic vsync_prev;

    // Region Detect
    localparam TARGET_PX = 50,
               X_PX      = 320,
               Y_PX      = 240,
               TOT_PX    = X_PX * Y_PX;
    logic [$clog2(TOT_PX)-1:0]         scan_addr;
    logic [$clog2(TOT_PX)-1:0]         pixel_cnt;
    logic [$clog2(TOT_PX*X_PX)-1:0]    sum_x;
    logic [$clog2(X_PX)-1:0]           avg_x;
    logic [$clog2(X_PX)-1:0]           player_x_reg;
    logic [$clog2(X_PX)-1:0]           curr_x, curr_y;

    // Color Detect
    logic [3:0]  r_check, g_check, b_check;
    logic isRED;
    assign r_check = frame_data[15:12];   // RGB565 -> RGB444
    assign g_check = frame_data[10:7];    // ignore smaller bit
    assign b_check = frame_data[4:1];
    assign isRED = (r_check > 4'b0100) &&
                   (g_check < 4'b0111) &&
                   (b_check < 4'b0111) &&
                   (r_check >= (g_check + 4'b0010)) && (r_check >= (b_check + 4'b0010));
                   
    // FSM
    localparam IDLE = 0, SCAN = 1, CAL_DIV = 2, CAL_REGION = 3;
    logic [1:0] state;

    always_ff @(posedge clk, posedge reset) begin
        if(reset) begin
            //edge detector
            vsync_prev   <= 1'b0;
            //region detector
            scan_addr    <= 0;
            pixel_cnt    <= 0;
            sum_x        <= 0;
            avg_x        <= 0;
            player_x_reg <= 0;
            curr_x       <= 0;
            curr_y       <= 0;
            //output
            frame_addr   <= 0;
            scanning     <= 1'b0;
            // pushed       <= 1'b0;
            region       <= 4'd0;
            // FSM
            state        <= 2'd0;
        end else begin
            vsync_prev <= vsync;
            case(state)
                IDLE: begin
                    if(!vsync_prev && vsync) begin
                        state     <= SCAN;
                        scanning  <= 1'b1;
                        scan_addr <= 0;
                        pixel_cnt <= 0;
                        sum_x     <= 0;
                        curr_x    <= 0;
                    end
                end
                SCAN: begin
                    if(!DE) begin
                        if(scan_addr == TOT_PX) state <= CAL_DIV;
                        else begin
                            // count RED pixel
                            if(isRED) begin
                                sum_x     <= sum_x + curr_x;
                                pixel_cnt <= pixel_cnt + 1;
                            end

                            // scanning pixel position
                            if(curr_x == 320-1) begin
                                curr_x <= 0;
                                curr_y <= curr_y + 1;
                            end else begin
                                curr_x <= curr_x + 1;
                            end

                            frame_addr <= scan_addr;
                            scan_addr  <= scan_addr + 1;
                        end
                    end
                end
                CAL_DIV: begin
                    if(!DE) begin
                        if(pixel_cnt > TARGET_PX) begin
                            avg_x <= sum_x / pixel_cnt;
                            state <= CAL_REGION;
                        end else begin
                            region <= 4'd0;
                            // pushed <= 1'b0;
                            state  <= IDLE;
                        end
                    end
                end
                CAL_REGION: begin
                    if(!DE) begin
                        state <= IDLE;
                        if(pixel_cnt > TARGET_PX) begin
                            logic [$clog2(X_PX)-1:0] player_x, target_x;

                            // RL reverse
                            if(avg_x > 320) target_x = 0;
                            else            target_x = 320 - avg_x;

                            // EMA filter
                            player_x     = (player_x_reg * 31 + target_x) >> 5;
                            player_x_reg <= player_x;

                            // region decision
                            if((player_x >= 0) && (player_x < 80)) region <= 4'b0001;
                            else if((player_x >= 80)  && (player_x < 160)) region <= 4'b0010;
                            else if((player_x >= 160) && (player_x < 240)) region <= 4'b0100;
                            else if((player_x >= 240) && (player_x < 320)) region <= 4'b1000;
                            // pushed <= 1'b1;
                        end else begin
                            region <= 4'd0;
                            // pushed <= 1'b0;
                        end
                    end
                end
            endcase
        end
    end

endmodule