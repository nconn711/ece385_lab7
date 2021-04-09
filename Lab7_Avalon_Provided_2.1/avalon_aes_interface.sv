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

	logic [31:0] register [15:0];
	logic [128:0] key, msg_enc, msg_dec;
	logic start, done;

	assign EXPORT_DATA = {key[127:112], 8'b0, key[7:0]};

	AES AES_0 (
		.CLK(CLK),
		.RESET(RESET),
		.AES_START(start),
		.AES_DONE(done),
		.AES_KEY(key),
		.AES_MSG_ENC(msg_enc),
		.AES_MSG_DEC(msg_dec)
	);

	reg_file reg_file_0	(
		.Clk(CLK),
		.Reset(RESET),
		.W(AVL_WRITE),
		.Addr(AVL_ADDR),
		.Byte_En(AVL_BYTE_EN),
		.Write_Data(AVL_WRITEDATA),
		.Read_Data(AVL_READDATA),
		.Dec(msg_dec),
		.Done(done),
		.Key(key),
		.Enc(msg_enc),
		.Start(start)
	);

endmodule
