module RegionDetector(
    input  logic        clk,
    input  logic        reset,
    input  logic        vsync,
    input  logic        DE,
    input  logic [15:0] frame_data,
    output logic [15:0] frame_addr,
    output logic        scanning,
    output logic [3:0]  region_RED,
    output logic [3:0]  region_BLUE
);

    // edge detect
    logic vsync_prev;

    // Region Detect
    localparam TARGET_PX = 50,
               X_PX      = 320,
               Y_PX      = 240,
               TOT_PX    = X_PX * Y_PX;
    logic [$clog2(TOT_PX)-1:0]         scan_addr;
    logic [$clog2(TOT_PX)-1:0]         pixel_cnt_R, pixel_cnt_B;
    logic [$clog2(TOT_PX*X_PX)-1:0]    sum_x_R, sum_x_B;
    logic [$clog2(X_PX)-1:0]           avg_x_R, avg_x_B;
    logic [$clog2(X_PX)-1:0]           x_reg_R, x_reg_B;
    logic [$clog2(X_PX)-1:0]           curr_x, curr_y;

    // Color Detect
    logic [3:0]  r_check, g_check, b_check;
    logic isRED, isBLUE;
    assign r_check = frame_data[15:12];   // RGB565 -> RGB444
    assign g_check = frame_data[10:7];    // ignore smaller bit
    assign b_check = frame_data[4:1];
    assign isRED  = (r_check > 4'b0100) &&
                    (g_check < 4'b0111) &&
                    (b_check < 4'b0111) &&
                    (r_check > 4'(g_check + 4'b0010)) && (r_check > 4'(b_check + 4'b0010));
    assign isBLUE = (r_check < 4'b0111) &&
                    (g_check < 4'b0111) &&
                    (b_check > 4'b0100) &&
                    (b_check > 4'(r_check + 4'b0010)) && (b_check > 4'(g_check + 4'b0010));
                   
    // FSM
    localparam IDLE = 0, SCAN = 1, CAL_DIV = 2, CAL_REGION = 3;
    logic       state;
    logic [1:0] REDstate, BLUEstate;

    always_ff @(posedge clk, posedge reset) begin
        if(reset) begin
            //edge detector
            vsync_prev     <= 1'b0;
            //region detector
            scan_addr      <= 0;
            curr_x         <= 0;
            curr_y         <= 0;
            //RED
            pixel_cnt_R    <= 0;
            sum_x_R        <= 0;
            avg_x_R        <= 0;
            x_reg_R        <= 0;
            //BLUE
            pixel_cnt_B    <= 0;
            sum_x_B        <= 0;
            avg_x_B        <= 0;
            x_reg_B        <= 0;
            //output
            frame_addr     <= 0;
            scanning       <= 1'b0;
            region_RED     <= 4'd0;
            region_BLUE    <= 4'd0;
            // FSM
            state          <= 1'b0;
            REDstate       <= 2'd0;
            BLUEstate      <= 2'd0;
        end else begin
            //edge detector
            vsync_prev <= vsync;
            if(!vsync_prev && vsync) begin
                state       <= SCAN;
                scanning    <= 1'b1;
                scan_addr   <= 0;
                pixel_cnt_R <= 0;
                pixel_cnt_B <= 0;
                sum_x_R     <= 0;
                sum_x_B     <= 0;
                curr_x      <= 0;
            end
            
            case(state)
                SCAN: begin
                    if(!DE) begin
                        if(scan_addr == TOT_PX) begin
                            REDstate  <= CAL_DIV;
                            BLUEstate <= CAL_DIV;
                            state     <= IDLE;
                        end else begin
                            // count Color pixel
                            if(isRED) begin
                                sum_x_R     <= sum_x_R + curr_x;
                                pixel_cnt_R <= pixel_cnt_R + 1;
                            end
                            if(isBLUE) begin
                                sum_x_B     <= sum_x_B + curr_x;
                                pixel_cnt_B <= pixel_cnt_B + 1;
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
            endcase

            case(REDstate)
                CAL_DIV: begin
                    if(!DE) begin
                        if(pixel_cnt_R > TARGET_PX) begin
                            avg_x_R    <= sum_x_R / pixel_cnt_R;
                            REDstate   <= CAL_REGION;
                        end else begin
                            region_RED  <= 4'd0;
                            REDstate    <= IDLE;
                        end
                    end
                end
                CAL_REGION: begin
                    if(!DE) begin
                        REDstate <= IDLE;
                        if(pixel_cnt_R > TARGET_PX) begin
                            logic [$clog2(X_PX)-1:0] player_x_R, target_x_R;

                            // RL reverse
                            if(avg_x_R > 320) target_x_R = 0;
                            else              target_x_R = 320 - avg_x_R;

                            // EMA filter
                            // player_x     = (player_x_reg + target_x) >> 1;
                            // player_x_reg <= player_x;
                            player_x_R = target_x_R;

                            // region decision
                            if((player_x_R >= 0) && (player_x_R < 80))         region_RED <= 4'b0001;
                            else if((player_x_R >= 80)  && (player_x_R < 160)) region_RED <= 4'b0010;
                            else if((player_x_R >= 160) && (player_x_R < 240)) region_RED <= 4'b0100;
                            else if((player_x_R >= 240) && (player_x_R < 320)) region_RED <= 4'b1000;
                        end else begin
                            region_RED <= 4'd0;
                        end
                    end
                end
            endcase

            case(BLUEstate)
                CAL_DIV: begin
                    if(!DE) begin
                        if(pixel_cnt_B > TARGET_PX) begin
                            avg_x_B    <= sum_x_B / pixel_cnt_B;
                            BLUEstate  <= CAL_REGION;
                        end else begin
                            region_BLUE <= 4'd0;
                            BLUEstate   <= IDLE;
                        end
                    end
                end
                CAL_REGION: begin
                    if(!DE) begin
                        BLUEstate <= IDLE;
                        if(pixel_cnt_B > TARGET_PX) begin
                            logic [$clog2(X_PX)-1:0] player_x_B, target_x_B;

                            // RL reverse
                            if(avg_x_B > 320) target_x_B = 0;
                            else              target_x_B = 320 - avg_x_B;

                            // EMA filter
                            // player_x     = (player_x_reg + target_x) >> 1;
                            // player_x_reg <= player_x;
                            player_x_B = target_x_B;

                            // region decision
                            if((player_x_B >= 0) && (player_x_B < 80))         region_BLUE <= 4'b0001;
                            else if((player_x_B >= 80)  && (player_x_B < 160)) region_BLUE <= 4'b0010;
                            else if((player_x_B >= 160) && (player_x_B < 240)) region_BLUE <= 4'b0100;
                            else if((player_x_B >= 240) && (player_x_B < 320)) region_BLUE <= 4'b1000;
                        end else begin
                            region_BLUE <= 4'd0;
                        end
                    end
                end
            endcase
        end
    end

endmodule