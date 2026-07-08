module SCCB_Controller(
    input  logic clk,
    input  logic reset,
    output logic scl,
    output logic sda
);

    logic [15:0] WdataBlock, RdataBlock;
    logic WR, SCCBstart, SCCBdone;

    SCCB_Data_Controller U_SCCB_DCtrl(
        .clk(clk),
        .reset(reset),
        .SCCBdone(SCCBdone),
        .WdataBlock(WdataBlock),
        .SCCBstart(SCCBstart),
        .SCCBwr(WR)
    );
    SCCB_sender U_SCCB_Sender(
        .clk(clk),
        .reset(reset),
        .WR(WR),
        .start(SCCBstart),
        .tx_data(WWdataBlock),
        .SCCBdone(SCCBdone),
        .scl(scl),
        .sda(sda),
        .rx_data(RdataBlock)
    );

endmodule

module SCCB_Data_Controller(
    input  logic        clk,
    input  logic        reset,
    input  logic        SCCBdone,
    output logic [15:0] WdataBlock,
    output logic        SCCBstart,
    output logic        SCCBwr
);

    localparam MEM_DEPTH = 8;   // memory depth setting
    logic [15:0] ROM[0:MEM_DEPTH];

    logic CNTstart30, CNTstart10, CNTflag30, CNTflag10;
    logic [$clog2(MEM_DEPTH-1):0] instrAddr;

    localparam IDLE = 0, WRITE = 1, WAIT = 2, READ = 3, DELAY = 4;
    logic [1:0] state;

    initial begin
        $readmemh("OV7670setting.mem", mem);
    end

    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            state      <= 2'd0;
            instrAddr  <= 0;
            CNTstart30 <= 1'b0;
            CNTstart10 <= 1'b0;
            CNTflag30  <= 1'b0;
            CNTflag10  <= 1'b0;
        end else begin
            case(state)
                IDLE: begin
                    if(instrAddr == 0) begin
                        state <= WRITE;
                    end
                end
                WRITE: begin
                    WdataBlock <= ROM[instrAddr];
                    SCCBstart <= 1'b1;
                    SCCBwr    <= 1'b1;
                    state     <= WAIT;
                end
                READ: begin
                    SCCBstart <= 1'b1;
                    SCCBwr    <= 1'b0;
                    state     <= WAIT;
                end
                WAIT: begin
                    if(SCCBdone) begin
                        // delay 조절 여기서
                        // read 선택도 여기서
                        if(instrAddr == 0) begin
                            state      <= DELAY;
                            CNTstart30 <= 1'b1;
                        end else if(instrAddr == 1) begin
                            state      <= DELAY;
                            CNTstart10 <= 1'b1;
                        end else if(instrAddr == 5) begin
                            instrAddr  <= instrAddr + 1;
                            state      <= READ;
                        end else begin
                            instrAddr <= instrAddr + 1;
                            state     <= WRITE;
                        end
                    end
                end
                DELAY: begin
                    SCCBstart <= 1'b0;
                    if(CNTflag30 == 1'b1) begin
                        state     <= WRITE;
                        CNTflag30 <= 1'b0;
                    end else if(CNTflag10 == 1'b1) begin
                        state     <= WRITE;
                        CNTflag10 <= 1'b0;
                    end
                end
            endcase
        end
    end

    Counter #(
        .TIMES(30)
    ) U_Counter30 (
        .clk(clk),
        .reset(reset),
        .start(CNTstart30),
        .flag(CNTflag30)
    );
    Counter #(
        .TIMES(10)
    ) U_Counter10 (
        .clk(clk),
        .reset(reset),
        .start(CNTstart10),
        .flag(CNTflag10)
    );

endmodule


module Counter #(
    parameter TIMES = 1000
) (
    input  logic clk,
    input  logic reset,
    input  logic start,
    output logic flag
);
    reg [$clog2(TIMES)-1:0] counter_reg;

    localparam STAY = 0, COUNT = 1;
    logic state;

    assign o_count = counter_reg;

    always_ff @(posedge clk, posedge reset) begin
        if(reset) begin
            state       <= STAY;
            counter_reg <= 0;
            flag        <= 1'b0;
        end else begin
            case(state)
                STAY: begin
                    counter_reg <= 0;
                    flag        <= 1'b0;
                    if(start == 1'b1)   state <= COUNT;
                end
                COUNT: begin
                    if(counter_reg == TIMES-1) begin
                        state <= STAY;
                        flag  <= 1'b1;
                    end else begin
                        counter_reg <= counter_reg + 1;
                    end
                end
            endcase
        end
    end
endmodule