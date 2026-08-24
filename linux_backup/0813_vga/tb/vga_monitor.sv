`ifndef VGA_MONITOR_SV
`define VGA_MONITOR_SV

class vga_monitor extends uvm_monitor;
    `uvm_component_utils(vga_monitor)

    uvm_analysis_port #(vga_seq_item) in_ap;  // RGB, x, y
    uvm_analysis_port #(vga_seq_item) out_ap; // pixel_addr, pixel_data

    virtual vga_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        in_ap  = new("in_ap", this);
        out_ap = new("out_ap", this);
        if(!uvm_config_db#(virtual vga_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "monitor에서 uvm_config_db 에러 발생.");
    endfunction

    virtual task run_phase(uvm_phase phase);
        fork
            collect_input();
            collect_output();
        join
    endtask

    task collect_input();
        vga_seq_item in_tx;

        wait(vif.mon_cb.vga_start == 1'b1);

        forever begin
            @(vif.mon_cb);
            if(vif.mon_cb.y_pixel < 480) begin
                in_tx = vga_seq_item::type_id::create("in_tx");
                in_tx.RGB     = vif.mon_cb.RGB;
                in_tx.x_pixel = vif.mon_cb.x_pixel;
                in_tx.y_pixel = vif.mon_cb.y_pixel;

                in_ap.write(in_tx);
            end
        end
    endtask

    task collect_output();
        vga_seq_item out_tx;

        wait(vif.mon_cb.vga_done == 1'b1);
        @(vif.mon_cb.pixel_addr);

        for(int i = 0; i < 128; i++) begin
            @(vif.mon_cb);
            out_tx = vga_seq_item::type_id::create("out_tx");
            out_tx.pixel_addr = vif.mon_cb.pixel_addr;
            out_tx.pixel_data = vif.mon_cb.pixel_data;
            // `uvm_info(get_type_name(), $sformatf("[%0d/128] Paddr: %0d -> Pdata: %32b",
                                                    // i+1, out_tx.pixel_addr, out_tx.pixel_data), UVM_HIGH)
            out_ap.write(out_tx);
        end

        wait(vif.mon_cb.vga_done == 1'b0);
    endtask
endclass

`endif