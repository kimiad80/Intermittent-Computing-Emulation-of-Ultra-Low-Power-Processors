module Intermittent_Setup #(
	INTERRUPT_SELECT = 2'b00 // Default: MILESTONE INTERRUPT
) (
	input logic clk,
	input logic	[31:0] milestone,
	output logic reset_n,
	output logic interrupt
);
	
	logic iemu_interrupt, periodic_interrupt, milestone_interrupt;
	
	IEMU iemu (
        .clk(clk),
        .interrupt(iemu_interrupt),
        .reset(reset_n)
    );
	
	Counter #(
		.CYCLE_COUNT(10000)
	) periodic (
		.clk(clk),
		.rst_n(reset_n),
		.interrupt(periodic_interrupt)
	);
	
	Milestone milestone_setup (
		.clk(clk),
		.rst_n(reset_n),
		.milestone_condition(milestone),
		.milestone_interrupt(milestone_interrupt)
	);
	
	always_comb begin
        case (INTERRUPT_SELECT)
            2'b00: interrupt = milestone_interrupt;
            2'b01: interrupt = iemu_interrupt;
            2'b10: interrupt = periodic_interrupt;
            default: interrupt = 1'b0;
        endcase
    end
endmodule