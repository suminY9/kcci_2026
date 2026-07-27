`timescale 1ns / 1ps

module tb_uart();
    logic        clk;
    logic        reset;
    logic        inf_done;
    logic [31:0] inf_data;
    logic        tx;

    UART_top dut(
        .clk(clk),
        .reset(reset),
        .i_inf_done(inf_done),
        .i_inf_data(inf_data),
        .o_tx(tx)
    );
    
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // initial reset
        reset = 1;
        repeat(3) @(posedge clk);
        reset = 0;

        // inf_data 1
        inf_done = 0;
        inf_data = 32'hDDCCBBAA;
        @(posedge clk);

        // inf_done tick
        inf_done = 1;
        @(posedge clk);
        inf_data = 0;
        inf_done = 0;

        // inf_data 2
        #400_000;
        inf_data = 32'h00112233;
        @(posedge clk);

        // inf_done tick
        inf_done = 1;
        @(posedge clk);
        inf_data = 0;
        inf_done = 0;

        $finish;
    end

endmodule
