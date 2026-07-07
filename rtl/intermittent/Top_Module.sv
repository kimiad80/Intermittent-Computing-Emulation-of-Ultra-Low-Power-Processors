module Top_Module (
    input  logic clk,
    input  logic NV_RESET
);
    // Internal signals
    logic interrupt, reset_n, instr_req, instr_gnt, instr_rvalid, instr_err;
	logic dummy_instr_id, dummy_instr_wb, rf_we;
    logic [31:0] instr_addr, instr, data_addr, memdata_in, memdata_out, rf_rdata_a, rf_rdata_b;
	logic [31:0] rf_wdata;
	logic [4:0] rf_addr_a, rf_addr_b, rf_waddr;
    logic datemem_we, mem_ready, mem_data_req;
	logic [31:0] milestone;
	
	parameter logic [1:0] MILESTONE_INTERRUPT = 2'b00;
	parameter logic [1:0] IEMU_INTERRUPT = 2'b01;
	parameter logic [1:0] PERIODIC_INTERRUPT = 2'b10;
	
	// Instruction memory
	Instruction_Memory instr_memory(
		.instr_req_i(instr_req),
		.instr_gnt_o(instr_gnt),
		.instr_rvalid_o(instr_rvalid),
		.instr_addr_i(instr_addr),
		.instr_rdata_o(instr),
		.instr_err_o(instr_err)
	);
		
    // Intermittent module interrupts
    Intermittent_Setup #(
		.INTERRUPT_SELECT(MILESTONE_INTERRUPT)
	) intermittent (
		.clk(clk),
		.milestone(milestone),
		.reset_n(reset_n),
		.interrupt(interrupt)
	);

    // Ibex core
    ibex_core #(
        .PMPEnable(1'b0), // Disable PMP
        .RV32E(1'b0),     // Use full 32-bit register file
		.BranchTargetALU(1'b0), // Disable branch target
		.WritebackStage(1'b0),  // Disable Writeback stage
        .ICache(1'b0),     // Disable instruction cache
        .BranchPredictor(1'b0) // Disable branch predictor
    ) ibex (
        .clk_i(clk),
        .rst_ni(reset_n), // Active-low reset
		
        .hart_id_i(32'h0), // Hart ID (hardware thread ID)
        .boot_addr_i(32'h00000000), // Boot address
		
		// Instruction Memory
        .instr_req_o(instr_req),
        .instr_gnt_i(instr_gnt),
        .instr_rvalid_i(instr_rvalid),
        .instr_addr_o(instr_addr),
        .instr_rdata_i(instr),
		.instr_err_i(instr_err),
		
		// Data Memory
        .data_req_o(mem_data_req),
        .data_gnt_i(mem_ready),
        .data_rvalid_i(mem_ready),
        .data_we_o(datemem_we),
        .data_be_o(),
        .data_addr_o(data_addr),
        .data_wdata_o(memdata_in),
        .data_rdata_i(memdata_out),
		.data_err_i(1'b0),
		
		// Register file interface
		.dummy_instr_id_o(dummy_instr_id),
		.dummy_instr_wb_o(dummy_instr_wb),
		.rf_raddr_a_o(rf_addr_a),
		.rf_raddr_b_o(rf_addr_b),
		.rf_waddr_wb_o(rf_waddr),
		.rf_we_wb_o(rf_we),
		.rf_wdata_wb_ecc_o(rf_wdata),
		.rf_rdata_a_ecc_i(rf_rdata_a),
		.rf_rdata_b_ecc_i(rf_rdata_b),

		// RAMs interface (disabled)
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
		
		// Interrupt inputs
        .irq_software_i(1'b0), // Software interrupt (disabled)
        .irq_timer_i(1'b0), // Timer interrupt (disabled)
        .irq_external_i(1'b0), // External interrupt
        .irq_fast_i({14'd0, interrupt}),
        .irq_nm_i(1'b0), // Non-maskable interrupt (disabled)
		.irq_pending_o(),
		
		// Debug Interface
        .debug_req_i(1'b0), // Debug request (disabled)
		.crash_dump_o(),
		.double_fault_seen_o(),
		
		// CPU Control Signals
        .fetch_enable_i(4'b0101),
		.alert_minor_o(),
		.alert_major_internal_o(),
		.alert_major_bus_o(),
        .core_busy_o() // Core busy status (not used here)
    );
	
	// Ibex Register File
	ibex_register_file_ff #(
		.RV32E(1'b0)
	) ibex_rf (
		.clk_i(clk),
		.rst_ni(reset_n),

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
	
    // Memory Setup
    Memory_Setup memory (
        .clk(clk),
		.NV_RESET(NV_RESET),
		.reset_n(reset_n),
        .addr(data_addr),
        .data_in(memdata_in),
        .data_out(memdata_out),
		.milestone(milestone),
		.ready(mem_ready),
        .we(datemem_we),
        .en(mem_data_req)
    );
	

endmodule