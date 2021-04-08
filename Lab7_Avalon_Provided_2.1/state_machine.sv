module state_machine (
	input   logic Clk, Reset,
    input   logic Start,
	output  logic Done,
    output  logic [3:0] Round,
    output  logic [1:0] Select, MIX,
    output  logic LD_STATE, LD_STATE_MIX
);

    logic next_Done;
    logic [3:0] next_Round;

	enum logic [4:0] {IDLE, START, DONE, SHIFT, SUB_0, SUB_1, ADD, MIX_0, MIX_1, MIX_2, MIX_3} state, next_state;

	always_ff @ (posedge Clk) begin
		if (Reset) begin
			state <= IDLE;
            Done <= 1'b0;
            Round <= 4'b1111;
		end
		else begin
			state <= next_state;
            Done <= next_Done;
            Round <= next_Round;
		end
	end
	
	always_comb begin
	
        next_state = state;
		next_Done = 1'b0;
        next_Round = round;
        
        Select = 2'b0;
        MIX = 2'b0;
        LD_STATE = 1'b0;
        LD_STATE_MIX = 1'b0;

		unique case (next_state)
            IDLE:		if (Start)
                            next_state = START;
			START:		next_state = ADD;
            ADD:        next_state = (Round == 0) ? SHIFT : (Round == 10) ? DONE : MIX_0;
            SHIFT, SUB_0, SUB_1, MIX_0, MIX_1, MIX_2, MIX_3:    next_state = next_state.next();
			DONE:		if (~Start)
							next_state = IDLE;
		endcase
		
		unique case (state)

			IDLE:       begin
                            next_Round = 4'b1111;
                            next_Done = 1'b0;
                        end
            START:      begin
                            next_Round = 4'b0;
                        end
            DONE:       begin
                            next_Round = 4'b1111;
                            next_Done = 1'b1;
                        end
			SHIFT:      begin
                            next_Round = round + 1;
                            LD_STATE = 1'b1;
                            Select = 2'b00;
                        end
            SUB_0:      begin
                        end
            SUB_1:      begin
                            LD_STATE = 1'b1;
                            Select = 2'b01;
                        end
            ADD:        begin
                            LD_STATE = 1'b1;
                            Select = 2'b10;
                        end
            MIX_0:      begin
                            MIX = 2'b00;
                            LD_STATE_MIX = 1'b1;
                            Select = 2'b11;
                        end
            MIX_1:      begin
                            MIX = 2'b01;
                            LD_STATE_MIX = 1'b1;
                            Select = 2'b11;
                        end
            MIX_2:      begin
                            MIX = 2'b10;
                            LD_STATE_MIX = 1'b1;
                            Select = 2'b11;
                        end
            MIX_3:      begin
                            MIX = 2'b11;
                            LD_STATE_MIX = 1'b1;
                            Select = 2'b11;
                        end

		endcase
		
	end
	
endmodule