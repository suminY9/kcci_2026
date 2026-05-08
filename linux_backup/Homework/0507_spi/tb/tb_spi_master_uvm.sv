`include "uvm_macros.svh"
import uvm_pkg::*;

/***** interface *****/
interface axi_if(input logic clk, input logic rst_n);
    logic [3:0] awaddr;
    logic       awvalid;
    logic       awready;
    logic [31:0] wdata;
    logic [3:0]  wstrb;
    logic        wvalid;
    logic        wready;
    logic [1:0]  bresp;
    logic        bvalid;
    logic        bready;
    logic [3:0]  araddr;
    logic        arvalid;
    logic        arready;
    logic [31:0] rdata;
    logic [1:0]  rresp;
    logic        rvalid;
    logic        rready;
endinterface

interface spi_if(input logic clk);
    logic sclk;
    logic mosi;
    logic miso;
    logic cs_n;
    logic intr;
	logic busy;
endinterface


/***** object *****/
class spi_seq_item extends uvm_sequence_item;
	rand logic 		 cpol;
	rand logic  	 cpha;
	rand logic [7:0] tx_data; // master to slave
	rand logic [7:0] rx_data; // slave to master
	rand logic [7:0] clk_div;
	logic 	   [7:0] mosi_collected;
	logic	   [7:0] miso_collected;

	constraint c_cpol { cpol inside { 0, 1 };}
	constraint c_cpha { cpha inside { 0, 1 };}
	constraint c_config { clk_div == 8'd4; }

	`uvm_object_utils_begin(spi_seq_item)
		`uvm_field_int(cpol, UVM_ALL_ON)
		`uvm_field_int(cpha, UVM_ALL_ON)
		`uvm_field_int(tx_data, UVM_ALL_ON)
		`uvm_field_int(rx_data, UVM_ALL_ON)
		`uvm_field_int(mosi_collected, UVM_ALL_ON)
		`uvm_field_int(miso_collected, UVM_ALL_ON)
	`uvm_object_utils_end
	
	function new(string name = "spi_seq_item");
		super.new(name);
	endfunction

	function string convert2string ();
		return $sformatf("cpol=%0b cpha=%0b tx_data=%0h", cpol, cpha, tx_data);
	endfunction
endclass


class spi_rand_seq extends uvm_sequence #(spi_seq_item);
	`uvm_object_utils(spi_rand_seq)
	int num_loop = 0;

	function new(string name = "spi_rand_seq");
		super.new(name);
	endfunction

	virtual task body();
		for(int i = 0; i < num_loop; i++) begin
			spi_seq_item item;
			item = spi_seq_item::type_id::create("item");

			start_item(item);
				if(!item.randomize())
 	                   `uvm_fatal(get_type_name(), "randomization fail.");
			finish_item(item);
			`uvm_info(get_type_name(), item.convert2string(), UVM_MEDIUM)
		end
	endtask
endclass


/***** structure *****/
class axi_driver extends uvm_driver #(spi_seq_item);
	`uvm_component_utils(axi_driver)
	uvm_analysis_port #(spi_seq_item) ap;
	virtual axi_if aif;

	localparam ADDR_CONFIG  = 4'h0; // slv_reg0: cpol, cpha, clk_div
    localparam ADDR_TXDATA  = 4'h4; // slv_reg1: tx_data, start
    localparam ADDR_RXDATA  = 4'h8; // slv_reg2: rx_data (Read Only)
    localparam ADDR_STATUS  = 4'hC; // slv_reg3: done, busy (Read Only)

	function new(string name, uvm_component parent);
		super.new(name, parent);
		ap = new("ap", this);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual axi_if)::get(this, "", "aif", aif))
			`uvm_fatal(get_type_name(), "FAIL: CAN NOT FIND <aif>")
		`uvm_info(get_type_name(), "build_phase COMPLETE.", UVM_HIGH);
	endfunction

	task drive_item(spi_seq_item tr);
		logic [31:0] status_reg;

		uvm_config_db#(logic)::set(null, "*", "cpol", tr.cpol);
    	uvm_config_db#(logic)::set(null, "*", "cpha", tr.cpha);
        // STEP 1: SPI 모드 및 클럭 분주 설정 (Reg0)
        // bit[0]:cpol, bit[1]:cpha, bit[2]:intr_en, bit[15:8]:clk_div
        axi_write(ADDR_CONFIG, {16'd0, tr.clk_div, 5'd0, 1'b1, tr.cpha, tr.cpol});

        // STEP 2: 데이터 전송 및 Start 명령 (Reg1)
        // bit[7:0]:tx_data, bit[8]:start
        axi_write(ADDR_TXDATA, {23'd0, 1'b1, tr.tx_data});
		// axi_write(ADDR_TXDATA, (0 << 8) | tr.tx_data);
        
		do begin
        	axi_read(ADDR_STATUS, status_reg);
    	end while (status_reg[1] == 1'b0); // Done 비트가 1이 될 때까지 루프

		repeat(5) @(posedge aif.clk);

        `uvm_info(get_type_name(), $sformatf("SPI Done! TX:0x%h", tr.tx_data), UVM_LOW)
    endtask

	virtual task run_phase(uvm_phase phase);
		spi_seq_item item;

		//reset
        aif.awvalid <= 0;
		aif.wvalid <= 0;
		aif.bready <= 0;
        aif.arvalid <= 0;
		aif.rready <= 0;
        
        forever begin
            seq_item_port.get_next_item(item);
            drive_item(item);
			ap.write(item);
            seq_item_port.item_done();
        end
    endtask

	task axi_write(logic [3:0] addr, logic [31:0] data);
        @(posedge aif.clk);
        aif.awaddr  <= addr;
        aif.awvalid <= 1'b1;
        aif.wdata   <= data;
        aif.wstrb   <= 4'hf;
        aif.wvalid  <= 1'b1;
        aif.bready  <= 1'b1;

        // Address & Data Ready 대기
        wait(aif.awready && aif.wready);
        @(posedge aif.clk);
        aif.awvalid <= 1'b0;
        aif.wvalid  <= 1'b0;
        
        // Response 대기
        wait(aif.bvalid);
        @(posedge aif.clk);
        aif.bready  <= 1'b0;
    endtask

    task axi_read(logic [3:0] addr, output logic [31:0] data);
        @(posedge aif.clk);
        aif.araddr  <= addr;
        aif.arvalid <= 1'b1;
        aif.rready  <= 1'b1;

        wait(aif.arready);
        @(posedge aif.clk);
        aif.arvalid <= 1'b0;

        wait(aif.rvalid);
        data = aif.rdata;
        @(posedge aif.clk);
        aif.rready  <= 1'b0;
    endtask
endclass

// class spi_driver extends uvm_driver #(spi_seq_item);
// 	`uvm_component_utils(axi_driver)
// 	uvm_analysis_port #(spi_seq_item) ap;
// 	virtual spi_if sif;

// 	function new(string name, uvm_component parent);
// 		super.new(name, parent);
// 		ap = new("ap", this);
// 	endfunction

// 	virtual function void build_phase(uvm_phase phase);
// 		super.build_phase(phase);
// 		if(!uvm_config_db#(virtual spi_if)::get(this, "", "sif", sif))
// 			`uvm_fatal(get_type_name(), "FAIL: CAN NOT FIND <sif>")
// 		`uvm_info(get_type_name(), "build_phase COMPLETE.", UVM_HIGH);
// 	endfunction

// 	task drive_miso(logic [7:0] data_to_send);
//     	forever begin
//     	    @(negedge sif.cs_n); 
//     	    repeat(8) begin
//     	        @(posedge (sif.sclk));
//     	        sif.miso <= data_to_send[7];
//     	        data_to_send = data_to_send << 1;
//     	    end
// 	    end
// 	endtask

	// virtual task run_phase(uvm_phase phase);
	// 	spi_seq_item item;

	// 	//reset
        
    //     forever begin
    //         seq_item_port.get_next_item(item);
	// 		ap.write(item);
    //         drive_item(item);
    //         seq_item_port.item_done();
    //     end
    // endtask
// endclass


class spi_monitor extends uvm_monitor;
	`uvm_component_utils(spi_monitor)
	uvm_analysis_port #(spi_seq_item) ap;
	virtual spi_if sif;

	logic rand_cpol = 0; 
    logic rand_cpha = 0;
	int skip_cnt = 0;

	function new(string name, uvm_component parent);
		super.new(name, parent);
		ap = new("ap", this);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual spi_if)::get(this, "", "sif", sif))
			`uvm_fatal(get_type_name(), "FAIL: CAN NOT FIND <sif>")
		`uvm_info(get_type_name(), "build_phase COMPLETE.", UVM_HIGH);
	endfunction

	task run_phase(uvm_phase phase);
        spi_seq_item tr;
        
		`uvm_info(get_type_name(), "Start SPI Master monitoring...", UVM_DEBUG);

        forever begin
			// wait(sif.cs_n === 1'b1);
			if (sif.busy !== 1'b0) @(negedge sif.busy);
            @(posedge sif.busy);
if (skip_cnt % 3 == 0) begin
            tr = spi_seq_item::type_id::create("tr");

			void'(uvm_config_db#(logic)::get(this, "", "cpol", rand_cpol));
        	void'(uvm_config_db#(logic)::get(this, "", "cpha", rand_cpha));
            
            for (int i = 7; i >= 0; i--) begin
                sample_edge(); 
                // tr.miso_collected[i] = sif.miso;
                tr.mosi_collected[i] = sif.mosi;
            end

			if (sif.busy === 1'b1) @(negedge sif.busy);
        	
			tr.cpol = rand_cpol; // config_db에서 가져온 값을 객체에 할당
			tr.cpha = rand_cpha;
			tr.tx_data = tr.mosi_collected;
            ap.write(tr);
end else begin
            `uvm_info("MON", $sformatf("Captured SPI: mosi_collected=0x%h", 
                      tr.mosi_collected), UVM_LOW)
end
skip_cnt++;
        end
    endtask

    task sample_edge();
        case ({rand_cpol, rand_cpha})
            2'b00: @(posedge sif.sclk); // Mode 0: Rising
            2'b01: @(negedge sif.sclk); // Mode 1: Falling
            2'b10: @(negedge sif.sclk); // Mode 2: Falling
            2'b11: @(posedge sif.sclk); // Mode 3: Rising
        endcase
		#2;
    endtask
endclass


class spi_agent extends uvm_agent;
	`uvm_component_utils(spi_agent)

	uvm_sequencer#(spi_seq_item) sqr;
	axi_driver drv;
	spi_monitor mon;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		sqr = uvm_sequencer#(spi_seq_item)::type_id::create("sqr", this);
		drv = axi_driver::type_id::create("drv", this);
		mon = spi_monitor::type_id::create("mon", this);
	endfunction
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		drv.seq_item_port.connect(sqr.seq_item_export);
	endfunction
endclass


class spi_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(spi_scoreboard)

	uvm_tlm_analysis_fifo #(spi_seq_item) exp_fifo;
    uvm_tlm_analysis_fifo #(spi_seq_item) act_fifo;

	int num_mosi = 0;
	// int num_miso = 0;
	int num_err_mosi = 0;
	// int num_err_miso = 0;

	function new(string name, uvm_component parent);
		super.new(name, parent);
		exp_fifo = new("exp_fifo", this);
		act_fifo = new("act_fifo", this);
	endfunction

	virtual task run_phase(uvm_phase phase);
        spi_seq_item exp_item;
        spi_seq_item act_item;

        forever begin
            exp_fifo.get(exp_item);
            act_fifo.get(act_item);

            if (exp_item.tx_data !== act_item.mosi_collected) begin
				num_err_mosi++;
                `uvm_error(get_type_name(), $sformatf("MOSI Protocol Error! Input:%h, Bus:%h", 
                            exp_item.tx_data, act_item.mosi_collected))
			end else begin
				num_mosi++;
				`uvm_info(get_type_name(), $sformatf("==MOSI PASS== Input:%h BUS:%h", exp_item.tx_data, act_item.mosi_collected), UVM_MEDIUM)
			end
        end
    endtask
	virtual function void report_phase(uvm_phase phase);
		string result = (num_err_mosi == 0) ? "** PASS **" : "** FAIL **";
        `uvm_info(get_type_name(), "========== SPI MASTER Summary ==========", UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf(" Result      : %s", result), UVM_MEDIUM)
        // `uvm_info(get_type_name(), $sformatf(" MISO PASSED : %0d", num_miso), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf(" MOSI PASSED : %0d", num_mosi), UVM_MEDIUM)
        // `uvm_info(get_type_name(), $sformatf(" MISO ERROR  : %0d", num_err_miso), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf(" MOSI ERROR  : %0d", num_err_mosi), UVM_MEDIUM)
        `uvm_info(get_type_name(), "=======================================", UVM_MEDIUM)
	endfunction
endclass


class spi_coverage extends uvm_subscriber #(spi_seq_item);
	`uvm_component_utils(spi_coverage)
	spi_seq_item tx;

	covergroup spi_cg;
		cp_cpol: coverpoint tx.cpol;
    	cp_cpha: coverpoint tx.cpha;
    	cp_mosi_data: coverpoint tx.tx_data { 	bins lowlow    = {[8'h00:8'h2F]};
												bins low	   = {[8'h20:8'h4F]};
        								    	bins mid       = {[8'h40:8'h6F]};
												bins high      = {[8'h60:8'h8F]};
        								   		bins highhigh  = {[8'h80:8'hFF]}; }
    	// cp_miso_data: coverpoint tx.miso_data { bins lowlow    = {[8'h00:8'h2F]};
		// 										bins low	   = {[8'h20:8'h4F]};
        // 								    	bins mid       = {[8'h40:8'h6F]};
		// 										bins high      = {[8'h60:8'h8F]};
        // 								   		bins highhigh  = {[8'h80:8'hFF]}; }
		cross_mode: cross cp_cpol, cp_cpha;
	endgroup

	function new(string name, uvm_component parent);
		super.new(name, parent);
		spi_cg = new();
	endfunction

	function void write(spi_seq_item t);
		tx = t;
		spi_cg.sample();
	endfunction
	virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "  ===== Coverage Summary =====  ", UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(" mosi_data : %.1f%%", spi_cg.cp_mosi_data.get_coverage()), UVM_LOW);
        // `uvm_info(get_type_name(), $sformatf(" miso_data : %.1f%%", spi_cg.cp_miso_data.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf("      mode : %.1f%%", spi_cg.cross_mode.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), "  ===== Coverage Summary =====  \n\n", UVM_LOW);
    endfunction
endclass


class spi_environment extends uvm_env;
	`uvm_component_utils(spi_environment)

	spi_agent agt;
	spi_scoreboard scb;
	spi_coverage cov;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		agt = spi_agent::type_id::create("agt", this);
		scb = spi_scoreboard::type_id::create("scb", this);
		cov = spi_coverage::type_id::create("cov", this);
	endfunction
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		agt.drv.ap.connect(scb.exp_fifo.analysis_export);
		agt.mon.ap.connect(scb.act_fifo.analysis_export);
		agt.mon.ap.connect(cov.analysis_export);
	endfunction
endclass


class spi_test extends uvm_test;
	`uvm_component_utils(spi_test)

	spi_environment env;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = spi_environment::type_id::create("env", this);
	endfunction
	virtual task run_phase(uvm_phase phase);
		spi_rand_seq seq;

		phase.raise_objection(this);
			seq = spi_rand_seq::type_id::create("seq");
			seq.num_loop = 1000;
			seq.start(env.agt.sqr);
		phase.drop_objection(this);
	endtask
endclass



/***** dut *****/
module tb_axi_spi_master_uvm();
	logic clk;
    logic rst_n;

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz
    end

    initial begin
        rst_n = 0;
        #100;
        rst_n = 1;
    end

	axi_if aif(clk, rst_n);
	spi_if sif(clk);
	
	SPI_Mater_v1_0 #(
        .C_S00_AXI_DATA_WIDTH(32),
        .C_S00_AXI_ADDR_WIDTH(4)
    ) dut (
        // AXI Slave Interface
        .s00_axi_aclk    (clk),
        .s00_axi_aresetn (rst_n),
        .s00_axi_awaddr  (aif.awaddr),
        .s00_axi_awprot  (3'b000), // 기본값
        .s00_axi_awvalid (aif.awvalid),
        .s00_axi_awready (aif.awready),
        .s00_axi_wdata   (aif.wdata),
        .s00_axi_wstrb   (aif.wstrb),
        .s00_axi_wvalid  (aif.wvalid),
        .s00_axi_wready  (aif.wready),
        .s00_axi_bresp   (aif.bresp),
        .s00_axi_bvalid  (aif.bvalid),
        .s00_axi_bready  (aif.bready),
        .s00_axi_araddr  (aif.araddr),
        .s00_axi_arprot  (3'b000),
        .s00_axi_arvalid (aif.arvalid),
        .s00_axi_arready (aif.arready),
        .s00_axi_rdata   (aif.rdata),
        .s00_axi_rresp   (aif.rresp),
        .s00_axi_rvalid  (aif.rvalid),
        .s00_axi_rready  (aif.rready),
        // SPI Master Interface
        .sclk (sif.sclk),
        .mosi (sif.mosi),
        .miso (sif.miso),
        .cs_n (sif.cs_n),
        .intr (sif.intr)
    );

	assign sif.busy = dut.SPI_Mater_v1_0_S00_AXI_inst.busy;

	initial begin
		uvm_config_db#(virtual spi_if)::set(null, "*", "sif", sif);
		uvm_config_db#(virtual axi_if)::set(null, "*", "aif", aif);
		run_test("spi_test");
	end
	
    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, tb_axi_spi_master_uvm, "+all");
    end
endmodule