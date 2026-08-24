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
            item.x_pixel = x;
            item.y_pixel = y;
        finish_item(item);

        `uvm_info(get_type_name(), $sformatf("capture() 전송 완료: x_pixel=%03d, y_pixel=%03d, RGB=%06h",
                                                                  item.x_pixel, item.y_pixel, item.RGB), UVM_MEDIUM)
    endtask

    task read(bit [7:0] raddr, output bit [31:0] read_data);
        vga_seq_item item;
        vga_seq_item rsp;
        item = vga_seq_item::type_id::create("item");

        start_item(item);
            item.y_pixel    = 720;
            item.pixel_addr = raddr;
        finish_item(item);

        get_response(rsp);
        read_data = rsp.pixel_data;

        `uvm_info(get_type_name(), $sformatf("read() 전송 완료: pixel_addr=%03d, pixel_data=%032b",
                                                     raddr, read_data), UVM_MEDIUM)
    endtask

    virtual task body();
        bit [23:0] target_colors[$] = '{24'h00_00_00, 24'hff_ff_ff, 24'hf0_f0_f0, 24'h0f_0f_0f};

        vga_seq_item item;
        item = vga_seq_item::type_id::create("item");

        start_item(item);
            item.vga_start = 1'b1;
        finish_item(item);
        for(int y = 0; y <= 719; y++) begin
            for(int x = 0; x <= 1079; x++) begin
                bit [23:0] rand_rgb;
                int rand_pct;

                rand_pct = $urandom_range(1, 100);
                if(rand_pct <= 50) rand_rgb = target_colors[$urandom_range(0, target_colors.size()-1)];
                else               rand_rgb = $urandom;

                capture(rand_rgb, x[10:0], y[10:0]);
            end
        end
        for(int raddr = 0; raddr <= 127; raddr++) begin
            bit [31:0] rdata;
            read(raddr[7:0], rdata);
        end
    endtask
endclass


class vga_testImage_seq extends uvm_sequence#(vga_seq_item);
    `uvm_object_utils(vga_testImage_seq)

    function new(string name = "vga_testImage_seq");
        super.new(name);
    endfunction

    task capture(bit [23:0] rgb, bit [10:0] x, bit [10:0] y);
        vga_seq_item item;
        item = vga_seq_item::type_id::create("item");

        start_item(item);
            item.RGB     = rgb;
            item.x_pixel = x;
            item.y_pixel = y;
        finish_item(item);

        `uvm_info(get_type_name(), $sformatf("capture() 전송 완료: x_pixel=%03d, y_pixel=%03d, RGB=%06h",
                                                                  item.x_pixel, item.y_pixel, item.RGB), UVM_MEDIUM)
    endtask

    task read(bit [7:0] raddr, output bit [31:0] read_data);
        vga_seq_item item;
        vga_seq_item rsp;
        item = vga_seq_item::type_id::create("item");

        start_item(item);
            item.y_pixel    = 720;
            item.pixel_addr = raddr;
        finish_item(item);

        get_response(rsp);
        read_data = rsp.pixel_data;

        `uvm_info(get_type_name(), $sformatf("read() 전송 완료: pixel_addr=%03d, pixel_data=%032b",
                                                     raddr, read_data), UVM_MEDIUM)
    endtask

    virtual task body();
        bit [23:0] image_mem [0:1080*720-1];

        vga_seq_item item;
        item = vga_seq_item::type_id::create("item");

        $readmemh("tb/testImage3_UVM.mem", image_mem);

        start_item(item);
            item.vga_start = 1'b1;
        finish_item(item);
        for(int y = 0; y <= 719; y++) begin
            for(int x = 0; x <= 1079; x++) begin
                bit [23:0] rgb;
                rgb = image_mem[y*1080+x];

                if((x < 3) && (y < 3))
                    `uvm_info("MEM_TEST", $sformatf("x=%0d, y=%0d, RGB=%06h", x, y, rgb), UVM_LOW)

                capture(rgb, x[10:0], y[10:0]);
            end
        end
        for(int raddr = 0; raddr <= 127; raddr++) begin
            bit [31:0] rdata;
            read(raddr[7:0], rdata);
        end
    endtask
endclass
`endif