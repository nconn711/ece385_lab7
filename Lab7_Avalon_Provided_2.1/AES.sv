/************************************************************************
AES Decryption Core Logic

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

module AES (
	input  logic CLK,
	input  logic RESET,
	input  logic AES_START,
	output logic AES_DONE,
	input  logic [127:0] AES_KEY,
	input  logic [127:0] AES_MSG_ENC,
	output logic [127:0] AES_MSG_DEC
);

	logic [127:0] AES_STATE;
	logic [127:0] MUX_STATES [3:0];
	logic [1407:0] AES_ROUNDKEY;

	logic [3:0] round;
	logic [1:0] select, mix;
	logic ld_state, ld_state_mix;
	
	assign AES_MSG_DEC = AES_STATE;
	
	always_ff @ (posedge CLK) begin
		if (round == 4'b1111 && ld_state && AES_START)
			AES_STATE <= AES_MSG_ENC;
		else if (ld_state)
			AES_STATE <= MUX_STATES[select];
		else if (ld_state_mix)
			AES_STATE[32*mix +: 32] <= MUX_STATES[select][31:0];
	end


	KeyExpansion KeyExpansion_0 ( .clk(CLK), .Cipherkey(AES_KEY), .KeySchedule(AES_ROUNDKEY) );

	InvShiftRows InvShiftRows_0 ( .data_in(AES_STATE), .data_out(MUX_STATES[0]) );

	InvSubBytes InvSubBytes_0 [15:0] ( .clk(CLK), .in(AES_STATE), .out(MUX_STATES[1]));

	InvAddKey InvAddKey_0 ( .data_in(AES_STATE), .key(AES_ROUNDKEY[128*round +: 128]), .data_out(MUX_STATES[2]) );

	InvMixColumns InvMixColumns_0 ( .in(AES_STATE[32*mix +: 32]), .out(MUX_STATES[3][31:0]) );

	state_machine sm_0 ( .Clk(CLK), .Reset(RESET), .Start(AES_START), .Done(AES_DONE), .Round(round), .Select(select), .MIX(mix), .LD_STATE(ld_state), .LD_STATE_MIX(ld_state_mix) );

endmodule
