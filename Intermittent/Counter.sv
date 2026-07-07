module Counter #(
    parameter CYCLE_COUNT = 1000  // Number of cycles between periodic interrupts
)(
    input  logic clk,
    input  logic rst_n,
    output logic interrupt
);

    localparam COUNTER_WIDTH = $clog2(CYCLE_COUNT);
    logic [COUNTER_WIDTH-1:0] counter;
	logic [10:0] interrupt_counter;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= '0;
            interrupt <= 1'b0;
			interrupt_counter <= 8'd0;
        end else begin
            if (counter == CYCLE_COUNT-1 && interrupt_counter == 8'd300) begin
                counter <= '0;
                interrupt <= 1'b0;
				interrupt_counter <= 8'd0;
			end else if (counter == CYCLE_COUNT-1) begin
				interrupt <= 1'b1;
				interrupt_counter <= interrupt_counter + 1;
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule