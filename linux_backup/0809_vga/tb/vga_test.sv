`ifndef VGA_TEST_SV
`define VGA_TEST_SV

class vga_test extends uvm_test;
    `uvm_component_utils(vga_test)
    vga_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = vga_env::type_id::create("env", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info(get_type_name(), "===== UVM 계층 구조 =====", UVM_MEDIUM)
        uvm_top.print_topology();
    endfunction

    virtual task run_phase(uvm_phase phase);
        vga_randRGB_seq seq;

        phase.raise_objection(this);
        phase.phase_done.set_drain_time(this, 2000ns);
        seq = vga_randRGB_seq::type_id::create("seq");
        seq.start(env.agt.sqr);
        phase.drop_objection(this);
    endtask

    virtual function void report_phase(uvm_phase phase);
        uvm_report_server svr = uvm_report_server::get_server();
        if(svr.get_severity_count(UVM_ERROR) == 0)
            `uvm_info(get_type_name(), "===== TEST PASS =====", UVM_LOW)
        else `uvm_info(get_type_name(), "===== TEST FAIL =====", UVM_LOW)
        uvm_top.print_topology();
    endfunction
endclass

`endif