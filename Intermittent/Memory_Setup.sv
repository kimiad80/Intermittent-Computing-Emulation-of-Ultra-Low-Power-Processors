module Memory_Setup (
    input  logic clk,
    input  logic NV_RESET,
	input  logic reset_n,
    input  logic [31:0] addr,
    input  logic [31:0] data_in,
    output logic [31:0] data_out,
	output logic [31:0] milestone,
    output logic ready,
    input  logic we,
    input  logic en
);
    // Memory modules
    logic [31:0] sram [0:32767]; // 64KB SRAM (32K x 32-bit)
    logic [31:0] nv_reg [0:15];  // 16-word NV memory
    logic [31:0] sensor_data = 32'd1000; // Peripheral: Sensor data
    logic [31:0] radio_data = 32'd0;     // Peripheral: Radio data

    // Address decoding
    logic sram_sel, nv_sel, peripheral_sel;
    assign sram_sel = (addr >= 32'h00008000 && addr < 32'h00010000);
    assign nv_sel = (addr >= 32'h00010000 && addr < 32'h00010040);
    assign peripheral_sel = (addr >= 32'h20000000 && addr < 32'h20000008);

    // State machine for memory access
    logic [7:0] delay_counter;
    typedef enum logic [1:0] {IDLE, DELAY, READ, WRITE} state_t;
    state_t state;
	
	logic milestone_reg = 1'b0;

    // Initialize memory on reset
    always_ff @(posedge clk or posedge NV_RESET or negedge reset_n) begin
        if (NV_RESET) begin
            // Initialize NV registers
            for (int i = 0; i < 16; i = i + 1) begin
                nv_reg[i] <= 32'h00000000;
            end
            // Initialize state machine
            state <= IDLE;
            ready <= 1'b0;
            delay_counter <= 8'd0;
        end else if(~reset_n) begin
			// Initialize SRAM
            for (int i = 0; i < 32768; i = i + 1) begin
                sram[i] <= 32'd0;
            end
			state <= IDLE;
            ready <= 1'b0;
            delay_counter <= 8'd0;
		end else begin
            case (state)
                IDLE: begin
					ready <= 1'b0;
                    if (en) begin
                        if (nv_sel) begin
                            state <= DELAY;
                            delay_counter <= 8'd6; // 6 cycles for 120 µs
                        end else if (sram_sel) begin
                            state <= DELAY;
                            delay_counter <= 8'd5; // 5 cycles for 100 µs
                        end else if (peripheral_sel) begin
							if (we) begin
								case (addr)
									32'h20000004: radio_data <= data_in;
								endcase
							end else begin
								case (addr)
									32'h20000000: data_out <= sensor_data;
									32'h20000004: data_out <= radio_data;
								endcase
							end
							ready <= 1'b1;
						end else if (we && addr == 32'h20000008) begin
							milestone_reg <= data_in;
							ready <= 1'b1;
						end
                    end
                end

                DELAY: begin
                    if (delay_counter > 0) begin
                        delay_counter <= delay_counter - 1;
                    end else begin
                        if (we) begin
                            state <= WRITE;
                        end else begin
                            state <= READ;
                        end
                    end
                end

                READ: begin
                    if (nv_sel) begin
                        data_out <= nv_reg[addr[11:0]>>2];
                    end else if (sram_sel) begin
                        data_out <= sram[(addr[15:0] - 16'h8000)>>2];
                    end
                    state <= IDLE;
                    ready <= 1'b1;
                end

                WRITE: begin
                    if (nv_sel) begin
                        nv_reg[addr[11:0]>>2] <= data_in;
                    end else if (sram_sel) begin
                        sram[(addr[15:0] - 16'h8000)>>2] <= data_in;
                    end
                    state <= IDLE;
                    ready <= 1'b1;
                end
				
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
	
	assign milestone = milestone_reg;
	
endmodule