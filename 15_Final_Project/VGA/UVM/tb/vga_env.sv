`ifndef VGA_ENVIRONMENT_SV
`define VGA_ENVIRONMENT_SV

class vga_env extends uvm_env;
    `uvm_component_utils(vga_env)
    vga_agent agt;
    vga_scoreboard scb;
    vga_coverage cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = vga_agent::type_id::create("agt", this);
        scb = vga_scoreboard::type_id::create("scb", this);
        cov = vga_coverage::type_id::create("cov", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.mon.in_ap.connect(scb.in_imp);
        agt.mon.out_ap.connect(scb.out_imp);
        agt.mon.in_ap.connect(cov.analysis_export);
    endfunction
endclass

`endif