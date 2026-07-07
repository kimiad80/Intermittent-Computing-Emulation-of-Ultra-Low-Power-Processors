module Milestone (
	input logic clk,
    input logic rst_n,
    input logic [31:0] milestone_condition,
    output logic milestone_interrupt
);
	always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            milestone_interrupt <= 1'b0;
        else begin
            if (milestone_condition == 1'd1) begin
                milestone_interrupt <= 1'b1;
            end else begin
                milestone_interrupt <= 1'b0;
            end
        end
    end
endmodule