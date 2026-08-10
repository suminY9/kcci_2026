`ifndef VGA_SEQUENCE_SV
`define VGA_SEQUENCE_SV

class vga_randRGB_seq extends uvm_sequence#(vga_seq_item);
    `uvm_object_utils(vga_randRGB_seq)

    function new(string name = "vga_randRGB_seq");
        super.new(name);
    endfunction

    task capture(bit [23:0] rgb, bit [10:0] x, bit [10:0] y);
        vga_seq_item item;
        item = vga_seq_item::type_id::create("item");

        start_item(item);
            if(!item.randomize() with { RGB == rgb; })
                `uvm_fatal(get_type_name(), "capture() randomize fail!")
        finish_item(item);

        clear_response_queue();

        `uvm_info(get_type_name(), $sformatf("capture() 전송 완료: x_pixel=%03d, y_pixel=%03d, RGB=%06h",
                                                                  x, y, rgb), UVM_MEDIUM)
    endtask

    task read(bit [7:0] raddr, output bit [31:0] read_data);
        vga_seq_item item;
        uvm_sequence_item rsp;
        item = vga_seq_item::type_id::create("item");

        start_item(item);
            item.pixel_addr = raddr;
        finish_item(item);

        get_response(rsp);
        begin
            vga_seq_item rsp_item;
            if(!$cast(rsp_item, rsp)) begin
                `uvm_fatal(get_type_name(), "Failed to cast rsp to vga_seq_item.")
            end
            read_data = rsp_item.pixel_data;
        end

        `uvm_info(get_type_name(), $sformatf("read() 전송 완료: pixel_addr=%03d, pixel_data=%032b",
                                                     raddr, read_data), UVM_MEDIUM)
    endtask

    virtual task body();
        vga_seq_item item;
        item = vga_seq_item::type_id::create("item");

        start_item(item);
            item.vga_start <= 1'b1;
        finish_item(item);
        for(int y = 0; y <= 479; y++) begin
            for(int x = 0; x <= 639; x++) begin
                bit [23:0] rand_rgb;
                rand_rgb = $urandom;
                capture(rand_rgb, x[10:0], y[10:0]);
            end
        end
        for(int raddr = 0; raddr <= 127; raddr++) begin
            bit [31:0] rdata;
            read(raddr[7:0], rdata);
        end
    endtask
endclass

`endif