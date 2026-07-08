module SCCB_Data_Controller(
    input  logic clk, // 100MHz
    input  logic reset,
    output logic scl,
    inout  logic sda
);

    logic SCCBstart, SCCBrw, SCCBdone, SCCBrp;
    logic [7:0]  RdataBlock;
    logic [15:0] WdataBlock;

    // QVGA Resolution
    localparam hstart = 168,
               hstop  = 24,
               vstart = 12,
               vstop  = 492,
               HSTART = (hstart>>3)&8'hff,
               HSTOP  = (hstop>>3)&8'hff,
               HREF   = ((hstop&8'h07)<<3)|(hstart&8'h07),
               VSTART = (vstart>>2)&8'hff,
               VSTOP  = (vstop>>2)&8'hff,
               VREF   = ((vstop&8'h03)<<2)|(vstart&8'h03);

    // enable setting (en = 1)
    localparam AutoExposureMode_EN = 1,
               AutoGainMode_EN     = 1;

    // brightness setting
    localparam BRIGHTNESS = 128;

    localparam IDLE = 0,
               ResetSW = 1,
               ShowColorBar = 2,
               AutoExposureMode = 3,
               SetBrightness = 4,
               AutoGainMode = 5;
    localparam P1 = 1,
               P2 = 2,
               P3 = 3,
               P4 = 4,
               P5 = 5,
               P6 = 6,
               P7 = 7,
               P8 = 8,
               P9 = 9,
               WRITE = 10,
               READ1 = 11,
               READ2 = 12,
               DONE  = 13;

    localparam ROM_DEPTH = 70;
    logic [15:0] ROM[0:ROM_DEPTH-1];
    logic [7:0] ConfigRAM[0:5];

    logic [3:0] state;
    logic [3:0] Fstate, Rstate;
    logic [4:0] done;
    logic Rdone;
    logic [$clog2(3_000_000)-1:0] cnt_reg;
    logic [$clog2(ROM_DEPTH)-1:0] instrAddr;
    logic [$clog2(6)-1:0] configAddr;

    initial begin
        $readmemh("OV7670setting.mem", ROM);
    end

    always_comb begin
        ConfigRAM = '{HSTART, HSTOP, HREF, VSTART, VSTOP, VREF};
    end
    
    always_ff @(posedge clk, posedge reset) begin
        if(reset) begin
            state      <= IDLE;
            Fstate     <= IDLE;
            Rstate     <= IDLE;
            done       <= 0;
            instrAddr  <= 0;
            configAddr <= 0;
            Rdone      <= 0;
            SCCBstart  <= 1'b0;
            cnt_reg    <= 0;
            SCCBrp     <= 0;
            WdataBlock <= 0;
            RdataBlock <= 0;
        end else begin
            case(state)
                IDLE: begin
                    if(!done) state <= ResetSW;
                    SCCBstart <= 1'b0;
                end
                ResetSW: begin
                    case(Fstate)
                        IDLE: begin // WriteSCCB(REG_COM7, 0x80)
                            WdataBlock <= ROM[instrAddr];
                            SCCBrw     <= 1'b1;
                            SCCBstart  <= 1'b1;
                            Rstate     <= P1;
                            Fstate     <= WRITE;
                        end
                        P1: begin // delay 30ms
                            cnt_reg <= cnt_reg + 1;
                            if(cnt_reg == 3_000_000-1) begin
                                Fstate    <= P2;
                                cnt_reg   <= 0;
                                instrAddr <= 0;
                            end
                        end
                        P2: begin // Config(defaults)
                            WdataBlock <= ROM[instrAddr];
                            SCCBrw     <= 1'b1;
                            SCCBstart  <= 1'b1;
                            Fstate     <= WRITE;
                            Rstate     <= P2;
                        end
                        P3: begin // delay 1ms
                            cnt_reg <= cnt_reg + 1;
                            if(instrAddr == 44)      Rstate <= P4;
                            else if(instrAddr == 52) Rstate <= P6;
                            if(cnt_reg == 100_000-1) begin
                                cnt_reg <= 0;
                                Fstate  <= Rstate;
                            end
                        end
                        P4: begin // delay 10ms
                            cnt_reg <= cnt_reg + 1;
                            if(cnt_reg == 1_000_000-1) begin
                                if(instrAddr == 59) done[0] <= 1'b1;
                                else                Fstate <= P2;
                                cnt_reg <= 0;
                            end
                        end
                        P5: begin // SetResolution(QVGA)_SetFrameControl
                            WdataBlock <= {ROM[instrAddr][15:8], ConfigRAM[configAddr]};
                            SCCBrw     <= 1'b1;
                            SCCBstart  <= 1'b1;
                            Rstate     <= P5;
                            Fstate     <= WRITE;
                        end
                        P6: begin // SetColorFormat
                            if(Rdone) begin
                                if(instrAddr == 57) begin
                                    WdataBlock[7:0] <= WdataBlock[7:0] & 8'b11111010;
                                    Rstate <= P6;
                                end
                                if(instrAddr == 58) begin
                                    WdataBlock[7:0] <= WdataBlock[7:0] & 8'b00001111;
                                    Rstate <= P4;
                                end
                                SCCBrw     <= 1'b1;
                                SCCBstart  <= 1'b1;
                                Fstate     <= WRITE;
                                Rdone      <= 1'b0;
                            end else begin
                                WdataBlock <= ROM[instrAddr];
                                SCCBrw    <= 1'b1;
                                SCCBstart <= 1'b1;
                                SCCBrp    <= 1'b1;
                                Rstate    <= P6;
                                Fstate    <= READ1;
                            end
                        end
                        // P7: begin // AutoExposureMode
                        //     WdataBlock <= ROM[instrAddr];
                        //     if(Rdone) begin
                        //         if(AutoExposureMode_EN) WdataBlock[7:0] <= WdataBlock[7:0] & 8'h01;
                        //         else                    WdataBlock[7:0] <= WdataBlock[7:0] & 8'hfe;
                        //         SCCBrw    <= 1'b1;
                        //         SCCBstart <= 1'b1;
                        //         Fstate    <= WRITE;
                        //         Rdone     <= 1'b0;
                        //         Rstate    <= P8;
                        //     end else begin
                        //         SCCBrw    <= 1'b0;
                        //         SCCBstart <= 1'b1;
                        //         Rstate    <= P7;
                        //         Fstate    <= READ;
                        //     end
                        // end
                        // P8: begin // SetBrightness
                        //     if(BRIGHTNESS >= 127) WdataBlock <= {ROM[instrAddr][15:8], BRIGHTNESS-127};
                        //     else                  WdataBlock <= {ROM[instrAddr][15:8], 255-BRIGHTNESS};
                        //     SCCBrw     <= 1'b1;
                        //     SCCBstart  <= 1'b1;
                        //     Fstate     <= WRITE;
                        //     Rstate     <= P9;
                        // end
                        // P9: begin // AutoGainMode
                        //     WdataBlock <= ROM[instrAddr];
                        //     if(Rdone) begin
                        //         if(AutoGainMode_EN) WdataBlock[7:0] <= WdataBlock[7:0] & 8'h04;
                        //         else                WdataBlock[7:0] <= WdataBlock[7:0] & 8'hfb;
                        //         SCCBrw    <= 1'b1;
                        //         SCCBstart <= 1'b1;
                        //         Fstate    <= WRITE;
                        //         Rdone     <= 1'b0;
                        //         Rstate    <= DONE;
                        //     end else begin
                        //         SCCBrw    <= 1'b0;
                        //         SCCBstart <= 1'b1;
                        //         Rstate    <= P9;
                        //         Fstate    <= READ;
                        //     end
                        // end
                        WRITE: begin
                            SCCBstart <= 1'b0;
                            if(SCCBdone) begin
                                Fstate    <= P3;
                                instrAddr <= instrAddr + 1;
                                if(instrAddr > 50 && instrAddr < 57) configAddr <= configAddr + 1;
                            end
                        end
                        READ1: begin
                            SCCBstart <= 1'b0;
                            if(SCCBdone) begin
                                Fstate    <= READ2;
                                SCCBstart <= 1'b1;
                                SCCBrw    <= 1'b0;
                                SCCBrp    <= 1'b1;
                            end
                        end
                        READ2: begin
                            SCCBstart <= 1'b0;
                            if(SCCBdone) begin
                                Fstate          <= Rstate;
                                WdataBlock[7:0] <= RdataBlock;
                                SCCBrp          <= 1'b0;
                                Rdone           <= 1'b1;
                            end
                        end
                    endcase
                    if(done[0]) begin
                        state  <= AutoExposureMode;
                        Fstate <= P1;
                    end
                end
                ShowColorBar: begin
                    
                    if(done[1]) begin
                        state  <= AutoExposureMode;
                        Fstate <= P1;
                    end
                end
                AutoExposureMode: begin
                    case(Fstate)
                        P1: begin
                            if(Rdone) begin
                                if(AutoExposureMode_EN) WdataBlock[7:0] <= WdataBlock[7:0] & 8'h01;
                                else                    WdataBlock[7:0] <= WdataBlock[7:0] & 8'hfe;
                                SCCBrw    <= 1'b1;
                                SCCBstart <= 1'b1;
                                Fstate    <= WRITE;
                                Rdone     <= 1'b0;
                                Rstate    <= DONE;
                            end else begin
                                WdataBlock <= ROM[instrAddr];
                                SCCBrw    <= 1'b0;
                                SCCBstart <= 1'b1;
                                Rstate    <= P1;
                                Fstate    <= READ1;
                            end
                        end
                        WRITE: begin
                            SCCBstart <= 1'b0;
                            if(SCCBdone) begin
                                if(Rstate == DONE) done[2] <= 1'b1;
                                Fstate    <= Rstate;
                                instrAddr <= instrAddr + 1;
                            end
                        end
                        READ1: begin
                            SCCBstart <= 1'b0;
                            if(SCCBdone) begin
                                Fstate    <= READ2;
                                SCCBstart <= 1'b1;
                                SCCBrw    <= 1'b0;
                                SCCBrp    <= 1'b1;
                            end
                        end
                        READ2: begin
                            SCCBstart <= 1'b0;
                            if(SCCBdone) begin
                                Fstate          <= Rstate;
                                WdataBlock[7:0] <= RdataBlock;
                                SCCBrp          <= 1'b0;
                                Rdone           <= 1'b1;
                            end
                        end
                    endcase
                    if(done[2]) begin
                        state  <= SetBrightness;
                        Fstate <= P1;
                    end
                end
                SetBrightness: begin
                    case(Fstate)
                        P1: begin
                            if(BRIGHTNESS >= 127) WdataBlock <= {ROM[instrAddr][15:8], BRIGHTNESS-127};
                            else                  WdataBlock <= {ROM[instrAddr][15:8], 255-BRIGHTNESS};
                            SCCBrw     <= 1'b1;
                            SCCBstart  <= 1'b1;
                            Fstate     <= WRITE;
                        end
                        WRITE: begin
                            SCCBstart <= 1'b0;
                            if(SCCBdone) begin
                                Fstate    <= DONE;
                                done[3]   <= 1'b1;
                                instrAddr <= instrAddr + 1;
                            end
                        end
                    endcase
                    if(done[3]) begin
                        state  <= AutoGainMode;
                        Fstate <= P1;
                    end
                end
                AutoGainMode: begin
                    case(Fstate)
                        P1: begin // AutoGainMode
                            if(Rdone) begin
                                if(AutoGainMode_EN) WdataBlock[7:0] <= WdataBlock[7:0] & 8'h04;
                                else                WdataBlock[7:0] <= WdataBlock[7:0] & 8'hfb;
                                SCCBrw    <= 1'b1;
                                SCCBstart <= 1'b1;
                                Fstate    <= WRITE;
                                Rdone     <= 1'b0;
                                Rstate    <= DONE;
                            end else begin
                                WdataBlock <= ROM[instrAddr];
                                SCCBrw    <= 1'b0;
                                SCCBstart <= 1'b1;
                                Rstate    <= P1;
                                Fstate    <= READ1;
                            end
                        end
                        WRITE: begin
                            SCCBstart <= 1'b0;
                            if(SCCBdone) begin
                                if(Rstate == DONE) done[4] <= 1'b1;
                                Fstate    <= Rstate;
                                instrAddr <= instrAddr + 1;
                            end
                        end
                        READ1: begin
                            SCCBstart <= 1'b0;
                            if(SCCBdone) begin
                                Fstate    <= READ2;
                                SCCBstart <= 1'b1;
                                SCCBrw    <= 1'b0;
                                SCCBrp    <= 1'b1;
                            end
                        end
                        READ2: begin
                            SCCBstart <= 1'b0;
                            if(SCCBdone) begin
                                Fstate          <= Rstate;
                                WdataBlock[7:0] <= RdataBlock;
                                SCCBrp          <= 1'b0;
                                Rdone           <= 1'b1;
                            end
                        end
                        // READ: begin
                        //     SCCBstart <= 1'b0;
                        //     if(SCCBdone) begin
                        //         Fstate          <= Rstate;
                        //         WdataBlock[7:0] <= RdataBlock;
                        //         Rdone           <= 1'b1;
                        //     end
                        // end
                    endcase
                    if(done[4]) begin
                        state  <= IDLE;
                        Fstate <= P1;
                    end
                end
            endcase
        end
    end

    SCCB_sender U_SCCB_SENDER(
        .clk(clk),
        .reset(reset),
        .WR(SCCBrw),
        .start(SCCBstart),
        .tx_data(WdataBlock),
        .SCCBdone(SCCBdone),
        .SCCBrp(SCCBrp),
        .scl(scl),
        .sda(sda),
        .rx_data(RdataBlock)
    );
endmodule