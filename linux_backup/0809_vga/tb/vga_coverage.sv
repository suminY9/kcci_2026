`ifndef VGA_COVERAGE_SV
`define VGA_COVERAGE_SV

`include "vga_seq_item.sv"

class vga_coverage extends uvm_subscriber#(vga_seq_item);
    `uvm_component_utils(vga_coverage)
    vga_seq_item tx;

    covergroup vga_cg;
        option.per_instance = 1;

        cp_red: coverpoint tx.RGB[23:16] {
            bins zero     = {8'h00};
            bins low      = {[8'h01 : 8'h40]};
            bins mid_low  = {[8'h41 : 8'h80]};
            bins mid_high = {[8'h81 : 8'hC0]};
            bins high     = {[8'hC1 : 8'hFE]};
            bins max      = {8'hFF};
        }
        cp_green: coverpoint tx.RGB[15:8] {
            bins zero     = {8'h00};
            bins low      = {[8'h01 : 8'h40]};
            bins mid_low  = {[8'h41 : 8'h80]};
            bins mid_high = {[8'h81 : 8'hC0]};
            bins high     = {[8'hC1 : 8'hFE]};
            bins max      = {8'hFF};
        }
        cp_blue: coverpoint tx.RGB[7:0] {
            bins zero     = {8'h00};
            bins low      = {[8'h01 : 8'h40]};
            bins mid_low  = {[8'h41 : 8'h80]};
            bins mid_high = {[8'h81 : 8'hC0]};
            bins high     = {[8'hC1 : 8'hFE]};
            bins max      = {8'hFF};
        }
        cp_colors: coverpoint tx.RGB{
            bins black = {24'h00_00_00};
            bins white = {24'hff_ff_ff};
            bins gray  = {24'hf0_f0_f0};
            bins grayL = {24'h0f_0f_0f};
        }
        cross_rgb: cross cp_red, cp_green, cp_blue;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        vga_cg = new();
    endfunction

    virtual function void write(vga_seq_item t);
        tx = t;
        vga_cg.sample();
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "  ===== Coverage Summary =====  ", UVM_LOW);
        `uvm_info(get_type_name(), $sformatf("   Overall   : %.1f%%", vga_cg.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf("    red      : %.1f%%", vga_cg.cp_red.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf("    green    : %.1f%%", vga_cg.cp_green.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf("    blue     : %.1f%%", vga_cg.cp_blue.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf("    colors   : %.1f%%", vga_cg.cp_colors.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf("  cross(rgb) : %.1f%%", vga_cg.cross_rgb.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), "  ===== Coverage Summary =====  \n\n", UVM_LOW);
    endfunction
endclass

`endif