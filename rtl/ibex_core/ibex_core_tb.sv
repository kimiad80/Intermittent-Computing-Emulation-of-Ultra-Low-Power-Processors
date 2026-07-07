`timescale 1us / 1ns

module ibex_core_tb;

	logic clk, reset;

	initial begin
		clk = 0;
		forever
		begin
			#10 clk = ~clk; 
		end
	end


	initial begin
		reset = 0;
		#100 reset = 1;
		#1000 $finish;
	end

    logic [31:0] rf_rdata_a, rf_rdata_b, rf_wdata, instr_addr, instr;
	logic [4:0] rf_addr_a, rf_addr_b, rf_waddr;
	logic dummy_instr_id, dummy_instr_wb, rf_we, instr_req, instr_gnt, instr_rvalid;
    

    ibex_core u_core (
    .clk_i                 (clk),
    .rst_ni                (reset),
    
    .hart_id_i             (32'b0),
    .boot_addr_i           (32'h00000000),
    
    .instr_req_o           (instr_req),
    .instr_gnt_i           (instr_gnt),
    .instr_rvalid_i        (instr_rvalid),
    .instr_addr_o          (instr_addr),
    .instr_rdata_i         (instr),
    .instr_err_i           (1'b0),
    
    .data_req_o            (),
    .data_gnt_i            (),
    .data_rvalid_i         (),
    .data_we_o             (),
    .data_be_o             (),
    .data_addr_o           (),
    .data_wdata_o          (),
    .data_rdata_i          (),
    .data_err_i            (1'b0),
	
	// Register File
	.dummy_instr_id_o(dummy_instr_id),
	.dummy_instr_wb_o(dummy_instr_wb),
	.rf_raddr_a_o(rf_addr_a),
	.rf_raddr_b_o(rf_addr_b),
	.rf_waddr_wb_o(rf_waddr),
	.rf_we_wb_o(rf_we),
	.rf_wdata_wb_ecc_o(rf_wdata),
	.rf_rdata_a_ecc_i(rf_rdata_a),
	.rf_rdata_b_ecc_i(rf_rdata_b),
	
	// RAMs interface
	.ic_tag_req_o(),
	.ic_tag_write_o(),
	.ic_tag_addr_o(),
	.ic_tag_wdata_o(),
	.ic_tag_rdata_i(),
	.ic_data_req_o(),
	.ic_data_write_o(),
	.ic_data_addr_o(),
	.ic_data_wdata_o(),
	.ic_data_rdata_i(),
	.ic_scr_key_valid_i(),
	.ic_scr_key_req_o(),
    
    .irq_software_i        (1'b0),
    .irq_timer_i           (1'b0),
    .irq_external_i        (1'b0),
    .irq_fast_i            (15'b0),
    .irq_nm_i              (1'b0),
	.irq_pending_o(),
    
    .debug_req_i           (1'b0),
	.crash_dump_o(),
	.double_fault_seen_o(),
    
    .fetch_enable_i        (4'b0101),
	.alert_minor_o(),
	.alert_major_internal_o(),
	.alert_major_bus_o(),
	.core_busy_o()
    );
	
	ibex_register_file_ff #(
		.RV32E(1'b0)
	) ibex_rf (
		.clk_i(clk),
		.rst_ni(reset),

		.test_en_i(1'b0),
		.dummy_instr_id_i(dummy_instr_id),
		.dummy_instr_wb_i(dummy_instr_wb),

		//Read port R1
		.raddr_a_i(rf_addr_a),
		.rdata_a_o(rf_rdata_a),

		//Read port R2
		.raddr_b_i(rf_addr_b),
		.rdata_b_o(rf_rdata_b),


		// Write port W1
		.waddr_a_i(rf_waddr),
		.wdata_a_i(rf_wdata),
		.we_a_i(rf_we),

		// This indicates whether spurious WE or non-one-hot encoded raddr are detected.
		.err_o()
	);
    
	Instruction_Memory instmem (
		.instr_req_i(instr_req),
		.instr_gnt_o(instr_gnt),
		.instr_rvalid_o(instr_rvalid),
		.instr_addr_i(instr_addr),
		.instr_rdata_o(instr),
		.instr_err_o()
	);
endmodule
