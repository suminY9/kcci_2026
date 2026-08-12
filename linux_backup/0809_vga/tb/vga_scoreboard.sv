`ifndef VGA_SCOREBOARD_SV
`define VGA_SCOREBOARD_SV

`uvm_analysis_imp_decl(_in)
`uvm_analysis_imp_decl(_out)

class vga_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(vga_scoreboard)

    uvm_analysis_imp_in #(vga_seq_item, vga_scoreboard) in_imp;
    uvm_analysis_imp_out #(vga_seq_item, vga_scoreboard) out_imp;

    bit [31:0] ref_Pdata[128];
    bit [27:0] temp;
    int i = 0;
    int j = 0;
    int num_match = 0;
    int num_miss  = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        in_imp = new("in_imp", this);
        out_imp = new("out_imp", this);
    endfunction

    virtual function void write_in(vga_seq_item tx);
        bit [7:0]  gray;

        if((tx.x_pixel >= 316) && (tx.x_pixel < 764) && (tx.x_pixel[1:0] == 2'b00)
            &&(tx.y_pixel >= 304) && (tx.y_pixel < 416) && (tx.y_pixel[1:0] == 2'b00)) begin

            gray = (tx.RGB[23:16]>>2) + (tx.RGB[15:8]>>1) + (tx.RGB[15:8]>>3) + (tx.RGB[7:0]>>3);
            if(gray >= 8'b1111_0000) temp[i] = 1'b1;
            else                     temp[i] = 1'b0;

            if(i == 27) begin
                i = 0;
                if((j < 2) || ((j >= 30) && (j < 34)) || ((j >= 62) && (j < 66)) || ((j >= 94) && (j < 98)) || ((j >= 126))) begin
                    ref_Pdata[j] = 32'hffff_ffff;
                end else ref_Pdata[j] = {2'b11, temp, 2'b11};
                j++;
            end else begin
                i++;
            end
        end
    endfunction

    virtual function void write_out(vga_seq_item tx);
        bit [31:0] expected_data = ref_Pdata[tx.pixel_addr];

        if(tx.pixel_data === expected_data) num_match++;
        else                                num_miss++;
    endfunction

    virtual function void report_phase(uvm_phase phase);
        string result = (num_miss == 0) ? "** PASS **" : "** FAIL **";
        `uvm_info(get_type_name(), "********** summary report **********", UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Result  : %s", result), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Matched : %0d", num_match), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Miss    : %0d", num_miss), UVM_MEDIUM)
        `uvm_info(get_type_name(), "************************************", UVM_MEDIUM)
    endfunction
endclass

`endif