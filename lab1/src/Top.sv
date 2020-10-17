module Top (
	input        i_clk,
	input        i_rst_n, //key 1
	input        i_start, //key 0
	output [3:0] o_random_out,
	input  		 i_seed_0, //SW 0
	input  		 i_seed_1, //SW 1
	input  		 i_seed_2, //SW 2
	input  		 i_seed_3, //SW 3
	input  		 i_seed_4, //SW 4
	input  		 i_seed_5, //SW 5
	input  		 i_seed_6, //SW 6
	input  		 i_trace  //key 2
);

// please check out the working example in lab1 README (or Top_exmaple.sv) first
// ===== States =====
parameter S_IDLE = 1'b0;
parameter S_PROC = 1'b1;

// ===== Output Buffers =====
logic [3:0] o_random_out_r, o_random_out_w;

// ===== Registers & Wires =====
logic state_r, state_w;
logic [29:0] count_r, count_w, comparator_r, comparator_w;
logic [3:0] lfsr4_r, lfsr4_w;
logic [2:0] lfsr3_r, lfsr3_w;
logic [1:0] lfsr2_r, lfsr2_w;
logic 	    lfsr1_r, lfsr1_w;
logic [3:0] previous_out_r [0:1];
logic [3:0] previous_out_w [0:1];

// ===== Output Assignments =====
assign o_random_out = o_random_out_r;

// ===== Combinational Circuits =====
always_comb begin
	// Default Values
	o_random_out_w 	= o_random_out_r;
	state_w        	= state_r;
	count_w 	   	= count_r;
	comparator_w   	= comparator_r;
	lfsr4_w			= lfsr4_r;
	lfsr3_w			= lfsr3_r;
	lfsr2_w			= lfsr2_r;
	lfsr1_w			= lfsr1_r;
	previous_out_w[0] = previous_out_r[0];
	previous_out_w[1] = previous_out_r[1];
	//previous_out_w[2] = previous_out_r[2];

	// FSM
	case(state_r)
		S_IDLE: begin
			if (i_start) begin
				state_w        	= S_PROC;
				lfsr4_w			= lfsr4_r;
				lfsr3_w			= lfsr3_r;
				lfsr2_w			= lfsr2_r;
				lfsr1_w			= lfsr1_r;
				o_random_out_w 	= {lfsr4_r[0],lfsr3_r[0],lfsr2_r[0],lfsr1_r};
				count_w        	= 30'b0;
				comparator_w   	= 30'b1000_0000_0000;
				previous_out_w[0] = previous_out_r[0];
				previous_out_w[1] = previous_out_r[1];
				//previous_out_w[2] = previous_out_r[2];
			end
			else if (i_trace) begin
				state_w        	= S_IDLE;
				lfsr4_w			= lfsr4_r;
				lfsr3_w			= lfsr3_r;
				lfsr2_w			= lfsr2_r;
				lfsr1_w			= lfsr1_r;
				o_random_out_w 	= previous_out_r[1];
				count_w        	= 30'b0;
				comparator_w   	= 30'b1000_0000_0000;
				previous_out_w[0] = previous_out_r[0];
				previous_out_w[1] = previous_out_r[1];
				//previous_out_w[2] = previous_out_r[2];
			end
		end

		S_PROC: begin
			if (i_start) begin
				state_w 		= S_IDLE;
				lfsr4_w			= lfsr4_r;
				lfsr3_w			= lfsr3_r;
				lfsr2_w			= lfsr2_r;
				lfsr1_w			= lfsr1_r;
				o_random_out_w 	= {lfsr4_r[0],lfsr3_r[0],lfsr2_r[0],lfsr1_r};
				count_w 		= count_r + 1'b1;
				comparator_w 	= comparator_r;
				previous_out_w[0] = o_random_out_w;
				previous_out_w[1] = previous_out_r[0];
				//previous_out_w[2] = previous_out_r[1];
			end
			else if (count_r == 30'b111_1111_1111_1111_1111_1111_1111) begin
				state_w 		= S_IDLE;
				lfsr4_w			= {(lfsr4_r[1]^lfsr4_r[0]),lfsr4_r[3],lfsr4_r[2],lfsr4_r[1]};
				lfsr3_w			= {(lfsr3_r[1]^lfsr3_r[0]),lfsr3_r[2],lfsr3_r[1]};
				lfsr2_w			= {(lfsr2_r[1]^lfsr2_r[0]),lfsr2_r[1]};
				lfsr1_w			= ~lfsr1_r;
				o_random_out_w  = {lfsr4_r[0],lfsr3_r[0],lfsr2_r[0],lfsr1_r};
				count_w 		= count_r + 1'b1;
				comparator_w 	= comparator_r << 1;
				previous_out_w[0] = o_random_out_w;
				previous_out_w[1] = previous_out_r[0];
				//previous_out_w[2] = previous_out_r[1];
			end
			else if (count_r == comparator_r) begin
				state_w 		= S_PROC;
				lfsr4_w			= {(lfsr4_r[1]^lfsr4_r[0]),lfsr4_r[3],lfsr4_r[2],lfsr4_r[1]};
				lfsr3_w			= {(lfsr3_r[1]^lfsr3_r[0]),lfsr3_r[2],lfsr3_r[1]};
				lfsr2_w			= {(lfsr2_r[1]^lfsr2_r[0]),lfsr2_r[1]};
				lfsr1_w			= ~lfsr1_r;
				o_random_out_w 	= {lfsr4_r[0],lfsr3_r[0],lfsr2_r[0],lfsr1_r};
				count_w 		= count_r + 1'b1;
				comparator_w 	= comparator_r << 1;
				previous_out_w[0] = previous_out_r[0];
				previous_out_w[1] = previous_out_r[1];
				//previous_out_w[2] = previous_out_r[2];
			end
			else begin
				state_w 		= S_PROC;
				lfsr4_w			= lfsr4_r;
				lfsr3_w			= lfsr3_r;
				lfsr2_w			= lfsr2_r;
				lfsr1_w			= lfsr1_r;
				o_random_out_w 	= {lfsr4_r[0],lfsr3_r[0],lfsr2_r[0],lfsr1_r};
				count_w 		= count_r + 1'b1;
				comparator_w 	= comparator_r;
				previous_out_w[0] = previous_out_r[0];
				previous_out_w[1] = previous_out_r[1];
				//previous_out_w[2] = previous_out_r[2];
			end
		end

	endcase
end

// ===== Sequential Circuits =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (!i_rst_n) begin
		o_random_out_r <= 4'd0;
		state_r        <= S_IDLE;
		count_r		   <= 30'b0;
		comparator_r   <= 30'b1000_0000_0000;
		lfsr4_r		   <= {1'b1,i_seed_6,i_seed_5,i_seed_4};
		lfsr3_r		   <= {1'b1,i_seed_3,i_seed_2};
		lfsr2_r		   <= {1'b1,i_seed_1};
		lfsr1_r		   <= {i_seed_0};
		previous_out_r[0] <= 4'b0;
		previous_out_r[1] <= 4'b0;
		//previous_out_r[2] <= 4'b0;
	end
	else begin
		o_random_out_r <= o_random_out_w;
		state_r        <= state_w;
		count_r        <= count_w;
		comparator_r   <= comparator_w;
		lfsr4_r		   <= lfsr4_w;
		lfsr3_r		   <= lfsr3_w;
		lfsr2_r		   <= lfsr2_w;
		lfsr1_r		   <= lfsr1_w;
		previous_out_r[0] <= previous_out_w[0];
		previous_out_r[1] <= previous_out_w[1];
		//previous_out_r[2] <= previous_out_w[2];
	end
end

endmodule
