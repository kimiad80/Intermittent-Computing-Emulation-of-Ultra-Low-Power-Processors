module Instruction_Memory (
    input logic instr_req_i,
    output logic instr_gnt_o,
    output logic instr_rvalid_o,
    input logic [31:0] instr_addr_i,
    output logic [31:0] instr_rdata_o,
    output logic instr_err_o
);

    logic [31:0] instmem [0:32767];
	logic [31:0] addr;

    initial begin
		$readmemh("program.mem", instmem);
	end

    assign instr_gnt_o = instr_req_i;

    // Read logic
    always_comb begin
		instr_rvalid_o = 1'b0;
		addr = {19'b0, instr_addr_i[16:2]};
        if (instr_req_i) begin
            if (instr_addr_i < 32'h00008000) begin
                instr_rvalid_o <= 1'b1;
                instr_rdata_o <= instmem[addr];
                instr_err_o <= 1'b0;
            end else begin
                instr_rvalid_o <= 1'b1;
                instr_rdata_o <= 32'h00000000;
                instr_err_o <= 1'b1;
            end
        end else begin
            instr_rvalid_o <= 1'b0;
            instr_rdata_o <= 32'h00000000;
            instr_err_o <= 1'b0;
        end
    end

endmodule