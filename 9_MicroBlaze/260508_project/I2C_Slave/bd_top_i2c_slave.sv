`timescale 1ns / 1ps

module board_top_i2c_slave (
    input  logic       clk,
    input  logic       reset,
    input  logic [7:0] rx_data,
    input  wire        scl,
    inout  logic       sda,
    // fnd output
    output logic [7:0] fnd_data,
    output logic [3:0] fnd_digit
);

    slave_fnd U_SLAVE_FND (
        .clk(clk),
        .reset(reset),
        .rx_data(rx_data),
        .scl(scl),
        .sda(sda),
        .fnd_data(fnd_data),
        .fnd_digit(fnd_digit)
    );
endmodule
