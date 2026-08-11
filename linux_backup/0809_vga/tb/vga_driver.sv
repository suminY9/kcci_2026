`ifndef VGA_DRIVER_SV
`define VGA_DRIVER_SV

class vga_driver extends uvm_driver#(vga_seq_item);
    `uvm_component_utils(vga_driver)
    virtual vga_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual vga_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "driver에서 uvm_config_db 에러 발생.");
    endfunction

    virtual task run_phase(uvm_phase phase);
        vif.drv_cb.vga_start  <= 1'b0;
        vif.drv_cb.RGB        <= '0;
        vif.drv_cb.x_pixel    <= '0;
        vif.drv_cb.y_pixel    <= '0;
        vif.drv_cb.pixel_addr <= '0;

        wait(vif.reset == 1'b0);
        @(vif.drv_cb);

        forever begin
            seq_item_port.get_next_item(req);
            drive_vga(req);
            // req.set_id_info(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_vga(vga_seq_item item);
        if(item.vga_start == 1'b1) begin
            vif.drv_cb.vga_start <= 1'b1;
            @(vif.drv_cb);
            vif.drv_cb.vga_start <= 1'b0;
        end else if(item.y_pixel < 480) begin
            vif.drv_cb.RGB     <= item.RGB;
            vif.drv_cb.x_pixel <= item.x_pixel;
            vif.drv_cb.y_pixel <= item.y_pixel;
            @(vif.drv_cb);
        end else begin
            vif.drv_cb.pixel_addr <= item.pixel_addr;
            @(vif.drv_cb);
            item.pixel_data = vif.drv_cb.pixel_data;

            seq_item_port.put_response(item);
        end
    endtask
endclass

`endif