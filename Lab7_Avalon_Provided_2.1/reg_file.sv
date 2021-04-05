module reg_file (
	input logic Clk, Reset,
	input logic W,
	input logic [3:0] Addr, Byte_En,
	input logic [31:0] Write_Data,
	output logic [31:0] Read_Data
);

	logic w [15:0];
	logic [31:0] read_data [15:0];
	logic [31:0] write_data;
	
	always_comb begin
		w = '{16{1'b0}};
		w[Addr] = W;
		Read_Data = read_data[Addr];
		write_data[7:0] = Byte_En[0] ? Write_Data[7:0] : Read_Data[7:0];
		write_data[15:8] = Byte_En[1] ? Write_Data[15:8] : Read_Data[15:8];
		write_data[23:16] = Byte_En[2] ? Write_Data[23:16] : Read_Data[23:16];
		write_data[31:24] = Byte_En[3] ? Write_Data[31:24] : Read_Data[31:24];
	end

	reg_32 registers [15:0]	(
		.Clk(Clk),
		.Reset(Reset),
		.W(w),
		.Write_Data({16{write_data}}),
		.Read_Data(read_data)
	);

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