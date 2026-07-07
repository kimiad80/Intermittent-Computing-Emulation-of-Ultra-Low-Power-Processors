module IEMU (
    input  logic clk,
    output logic interrupt,
    output logic reset
);
    parameter logic [31:0] HARD_THRESHOLD = 32'd2800;
    parameter logic [31:0] SOFT_THRESHOLD = 32'd2900;
    
    logic [31:0] voltage_trace;
    logic [31:0] voltage_ROM [0:1568];  // ROM with 1569 values
	logic rst = 1'b0;
    initial begin
        $readmemh("voltage_rom.vmem", voltage_ROM);
    end
	
    logic [31:0] i = 32'd0;
    logic [31:0] index_counter = 32'd0;
	logic [31:0] cycle_count = 32'd2500;

    always_ff @(posedge clk) begin
        if (i == 1568 * cycle_count + cycle_count - 32'd1) // (1568 * 2500) + 2499
            i <= 32'd1;
        else
            i <= i + 32'd1;

        if ((i % cycle_count) == 32'd0) // Increment index every 2500 cycles
            index_counter <= index_counter + 32'd1;
    end

    always_ff @(posedge clk) begin
        voltage_trace <= voltage_ROM[index_counter];
    end
	
	logic initialized = 1'b0;
    always_ff @(posedge clk) begin
		interrupt <= 1'b0;
		if (~initialized) begin
			rst <= 1'b1;
			initialized = 1'b1;
		end
		else begin
			if (voltage_trace < HARD_THRESHOLD) begin
				rst <= 1'b0;
				interrupt <= 1'b0;
			end
			else if (voltage_trace < SOFT_THRESHOLD) begin
				interrupt <= 1'b1;
				rst <= 1'b1;
			end
			else rst <= 1'b1;
		end
    end
	assign reset = rst;
endmodule