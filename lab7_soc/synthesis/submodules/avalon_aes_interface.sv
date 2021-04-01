/************************************************************************
Avalon-MM Interface for AES Decryption IP Core

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department

Register Map:

 0-3 : 4x 32bit AES Key
 4-7 : 4x 32bit AES Encrypted Message
 8-11: 4x 32bit AES Decrypted Message
   12: Not Used
	13: Not Used
   14: 32bit Start Register
   15: 32bit Done Register

************************************************************************/

module avalon_aes_interface (
	// Avalon Clock Input
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,						// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,		// Avalon-MM Byte Enable
	input  logic [3:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,	// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data
	
	// Exported Conduit
	output logic [31:0] EXPORT_DATA		// Exported Conduit Signal to LEDs
);

	always_ff @ (posedge CLK) begin
		if (RESET)
			EXPORT_DATA <= 32'b0;
		else if (AVL_WRITE && AVL_ADDR == 4'b0000) // address to upper 4 bytes of AES_KEY
			EXPORT_DATA[31:16] <= AVL_WRITEDATA[31:16];
		else if (AVL_WRITE && AVL_ADDR == 4'b0011) // address to lower 4 bytes of AES_KEY
			EXPORT_DATA[7:0] <= AVL_WRITEDATA[7:0];
	end

	reg_file reg_file_0	(
		.Clk(CLK),
		.Reset(RESET),
		.W(AVL_WRITE),
		.Addr(AVL_ADDR),
		.Byte_En(AVL_BYTE_EN),
		.Write_Data(AVL_WRITEDATA),
		.Read_Data(AVL_READDATA)
	);

endmodule
