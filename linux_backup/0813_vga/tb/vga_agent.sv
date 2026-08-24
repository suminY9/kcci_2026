`ifndef VGA_AGENT_SV
`define VGA_AGENT_SV

typedef uvm_sequencer #(vga_seq_item) vga_sequencer;
class vga_agent extends uvm_agent;
    `uvm_component_utils(vga_agent)
    vga_driver drv;
    vga_monitor mon;
    uvm_sequencer#(vga_seq_item) sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv = vga_driver::type_id::create("drv", this);
        mon = vga_monitor::type_id::create("mon", this);
        sqr = uvm_sequencer#(vga_seq_item)::type_id::create("sqr", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
endclass

`endif