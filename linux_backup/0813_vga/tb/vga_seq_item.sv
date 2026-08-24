`ifndef VGA_SEQ_ITEM_SV
`define VGA_SEQ_ITEM_SV

class vga_seq_item extends uvm_sequence_item;
    rand  logic [23:0] RGB;
          logic [10:0] x_pixel;
          logic [10:0] y_pixel;
          logic [7:0]  pixel_addr;
          logic [31:0] pixel_data;
          logic        vga_start;
          logic        vga_done;

    `uvm_object_utils_begin(vga_seq_item)
        `uvm_field_int(RGB, UVM_ALL_ON)
        `uvm_field_int(x_pixel, UVM_ALL_ON)
        `uvm_field_int(y_pixel, UVM_ALL_ON)
        `uvm_field_int(pixel_addr, UVM_ALL_ON)
        `uvm_field_int(pixel_data, UVM_ALL_ON)
        `uvm_field_int(vga_start, UVM_ALL_ON)
        `uvm_field_int(vga_done, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "vga_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf("x_pixel = %03d, y_pixel = %03d, RGB = %06h",
                          x_pixel, y_pixel, RGB);
    endfunction
endclass

`endif 