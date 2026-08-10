`include "uvm_macros.svh"
import uvm_pkg::*;

`include "vga_interface.sv"
`include "vga_seq_item.sv"
`include "vga_sequence.sv"
`include "vga_driver.sv"
`include "vga_monitor.sv"
`include "vga_agent.sv"
`include "vga_scoreboard.sv"
`include "vga_coverage.sv"
`include "vga_env.sv"
`include "vga_test.sv"

module tb_vga();
    logic pclk;
    logic reset;

    always #5 pclk = ~pclk;

    vga_if vif(pclk, reset);

    VGA_top dut(
        .i_pixel_clk(pclk),
        .reset(reset),
        .i_RGB(vif.RGB),
        .i_x_pixel(vif.x_pixel),
        .i_y_pixel(vif.y_pixel),
        .i_pixel_addr(vif.pixel_addr),
        .o_pixel_data(vif.pixel_data),
        .i_vga_start(vif.vga_start),
        .o_vga_done(vif.vga_done)
    );

    initial begin
        pclk  = 0;
        reset = 1;
        repeat(5) @(posedge pclk);
        reset = 0;
    end

    initial begin
        uvm_config_db#(virtual vga_if)::set(null, "*", "vif", vif);
        run_test();
    end

    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, tb_vga, "+all");
    end
endmodule