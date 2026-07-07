`timescale 1us / 1us

module intermittent_tb ();

logic clk, nv_rst;

initial begin
    clk = 0;
	nv_rst = 0;
	#5 nv_rst = 1;
	#5 nv_rst = 0;
end

always #10 clk = ~clk;

initial begin
	#700000 $finish;
end

Top_Module top (
	.clk(clk),
	.NV_RESET(nv_rst)
);

endmodule