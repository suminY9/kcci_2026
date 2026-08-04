module WiFi_UART_top(
    input  logic clk,
    input  logic reset,
    
    input  logic [15:0] sw,
    input  logic        btn,
    output logic        led,
    output logic        tx
);
    logic w_btn;

    btn_debounce U_BTN_DEB(
        .clk(clk),
        .reset(reset),
        .i_btn(btn),
        .o_btn(w_btn)
    );
    UART_top U_UART(
        .clk(clk),
        .reset(reset),
        .i_inf_done(w_btn),
        .i_inf_data(sw),
        .o_tx(tx)
    );
endmodule