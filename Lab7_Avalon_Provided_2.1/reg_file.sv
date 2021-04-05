module reg_file (
	input logic Clk, Reset,
	input logic W,
	input logic [3:0] Addr, Byte_En,
	input logic [31:0] Write_Data,
	output logic [31:0] Read_Data
);

module reg_file (
	input logic Clk, Reset,
	input logic W,
	input logic [3:0] Addr, Byte_En,
	input logic [31:0] Write_Data,
	output logic [31:0] Read_Data
);

	logic [31:0] register [15:0];

	assign Read_Data = register[Addr];

	always_ff @ (posedge Clk) begin
		if (Reset)
			register <= {16{32'b0}};
		else if (W) begin
			register[Addr][7:0] <= Byte_En[0] ? Write_Data[7:0] : register[Addr][7:0];
			register[Addr][15:8] <= Byte_En[1] ? Write_Data[15:8] : register[Addr][15:8];
			register[Addr][23:16] <= Byte_En[2] ? Write_Data[23:16] : register[Addr][23:16];
			register[Addr][31:24] <= Byte_En[3] ? Write_Data[31:24] : register[Addr][31:24];
		end
	end

endmodule

endmodule