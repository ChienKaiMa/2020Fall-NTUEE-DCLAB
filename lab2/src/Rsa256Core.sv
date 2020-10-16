module Rsa256Core (
	input          i_clk,
	input          i_rst,
	input          i_start,
	input  [255:0] i_a, // cipher text y
	input  [255:0] i_d, // private key
	input  [255:0] i_n,
	output [255:0] o_a_pow_d, // plain text x
	output         o_finished,
	output [1:0]   o_state
);
localparam S_IDLE = 2'd0;
localparam S_PREP = 2'd1;
localparam S_MONT = 2'd2;
localparam S_CALC = 2'd3;
//wire
logic i_prep_flag;
logic i_mont_flag;
logic o_mont1_flag;
logic o_mont2_flag;
logic o_prep_flag;
logic [255:0] o_mont1;
logic [255:0] o_mont2;
logic [255:0] o_prep;
//reg
logic [1:0] state;
logic [1:0] state_nxt;
logic [7:0] counter;
logic [7:0] counter_nxt;
logic [255:0] t,t_nxt,m,m_nxt;
logic [255:0] s_a, s_a_nxt;
logic [255:0] c_d, c_d_nxt;
logic finish, finish_nxt;
logic delay_i_rst;
logic new_i_rst;
// operations for RSA256 decryption
// namely, the Montgomery algorithm
//FSM
RsaMont rsa_mont1(.i_clk(i_clk), .i_rst(new_i_rst), .i_start(i_mont_flag), .i_a(m), .i_b(t), .i_n(i_n), .o_ab(o_mont1), .o_finished(o_mont1_flag));
RsaMont rsa_mont2(.i_clk(i_clk), .i_rst(new_i_rst), .i_start(i_mont_flag), .i_a(t), .i_b(t), .i_n(i_n), .o_ab(o_mont2), .o_finished(o_mont2_flag));
PreMult pre_mult(.i_clk(i_clk), .i_rst(new_i_rst),  .i_start(i_prep_flag), .i_a(s_a), .i_n(i_n), .o_aMul256(o_prep), .o_finished(o_prep_flag));


assign o_a_pow_d = m;
assign o_finished = finish;
assign o_state = state;
assign new_i_rst = ~(delay_i_rst^i_rst);

always_comb begin
	case(state)
	S_IDLE: begin
		if(i_start) begin
			state_nxt = S_PREP;
			s_a_nxt = i_a;
		end
		else begin
			state_nxt = state;
			s_a_nxt = s_a;
		end
		counter_nxt = 8'd0;
		i_prep_flag = 1'd0;
		i_mont_flag = 1'd0;
		t_nxt = 256'd0;
		m_nxt = 256'd1;
		finish_nxt = 1'd0;
		c_d_nxt = i_d;
	end
	S_PREP: begin
		if(o_prep_flag) begin
			state_nxt = S_MONT;
			i_prep_flag = 1'd0;
			t_nxt = o_prep;
		end
		else begin
			state_nxt = state;
			i_prep_flag = 1'd1;
			t_nxt = t;
		end
		counter_nxt = 8'd0;
		i_mont_flag = 1'd0;
		m_nxt = m;
		finish_nxt = 1'd0;
		s_a_nxt = s_a;
		c_d_nxt = i_d;
	end
	S_MONT: begin
		if(o_mont1_flag&o_mont2_flag) begin
			state_nxt = S_CALC;
			i_mont_flag = 1'd0;
			t_nxt = o_mont2;
			m_nxt = (c_d[0])? o_mont1 : m;
		end
		else begin
			state_nxt = state;
			i_mont_flag = 1'd1;
			t_nxt = t;
			m_nxt = m;
		end
		counter_nxt = counter;
		i_prep_flag = 1'd0;
		finish_nxt = 1'd0;
		s_a_nxt = s_a;
		c_d_nxt = c_d;
	end
	S_CALC: begin
		if(counter == 8'd255) begin
			state_nxt = S_IDLE;
			counter_nxt = 8'd0;
			finish_nxt = 1'd1;
		end
		else begin
			state_nxt = S_MONT;
			counter_nxt = counter + 8'd1;
			finish_nxt = 1'd0;
		end
		i_prep_flag = 1'd0;
		i_mont_flag = 1'd0;
		t_nxt = t;
		m_nxt = m;
		s_a_nxt = s_a;
		c_d_nxt = c_d >> 1;
	end
	endcase

end
always_ff @(posedge i_clk) begin
	delay_i_rst <= i_rst;
end

always_ff @(posedge i_clk or negedge new_i_rst) begin
	if(~new_i_rst) begin
		state <= S_IDLE;
		counter <= 8'd0;
		t <= 256'd0;
		m <= 256'd1;
		finish <= 1'd0;
		c_d <= i_d;
	end 
	else begin
		state <= state_nxt;
		counter <= counter_nxt;
		t <= t_nxt;
		m <= m_nxt;
		finish <= finish_nxt;
		c_d <= c_d_nxt;
	end
	s_a <= s_a_nxt;
end
endmodule

module RsaMont (
	input          i_clk,
	input          i_rst,
	input 		   reset_flag,
	input          i_start,
	input  [255:0] i_a, 
	input  [255:0] i_b, 
	input  [255:0] i_n,
	output [255:0] o_ab, 
	output         o_finished
);
localparam S_IDLE = 1'b0;
localparam S_PROC = 1'b1;
//wire
logic [257:0] m1,m2,m3; //need extra 2 bit to prevent overflow
//reg
logic state;
logic state_nxt;
logic [7:0] counter;
logic [7:0] counter_nxt;
logic [257:0] data; //need extra 2 bit to prevent overflow
logic [257:0] data_nxt; //need extra 2 bit to prevent overflow
logic [255:0] c_a;
logic [255:0] c_a_next;
logic finish, finish_nxt;

assign o_finished = finish;
assign o_ab = data[255:0];

always_comb begin 
	if(c_a[0]) begin
		m1 = data + {2'b0,i_b};
	end
	else begin
		m1 = data;
	end
	if(m1[0]) begin
		m2 = m1 + {2'b0,i_n};
	end
	else begin
		m2 = m1;
	end
	m3 = m2 >> 1;
end
always_comb begin
	case(state)
	S_IDLE: begin
		if(i_start) begin
			state_nxt = S_PROC;
		end
		else begin
			state_nxt = state;
		end
		counter_nxt = 8'd0;
		data_nxt = 257'd0;
		c_a_next = i_a;
		finish_nxt =1'd0;
	end
	S_PROC: begin
		if(counter == 8'd255) begin
			state_nxt = S_IDLE;
			counter_nxt = 8'd0;
			data_nxt = (m3 >= {2'b0,i_n})? m3 - {2'b0,i_n} : m3;
			finish_nxt = 1'd1;
		end
		else begin
			state_nxt = state;
			counter_nxt = counter + 8'd1;
			data_nxt = m3;
			finish_nxt =1'd0;
		end
		c_a_next = c_a >> 1;
	end
	endcase
end

always_ff @(posedge i_clk or negedge i_rst) begin
	if(~i_rst) begin
		state <= S_IDLE;
		counter <= 8'd0;
		data <= 257'd0;
		c_a <= i_a;
		finish <= 1'd0;
	end 
	else begin
		state <= state_nxt;
		counter <= counter_nxt;
		data <= data_nxt;
		c_a <= c_a_next;
		finish <= finish_nxt;
	end
end

endmodule

module PreMult (
	input          i_clk,
	input          i_rst,
	input 		   reset_flag,
	input          i_start,
	input  [255:0] i_a, 
	input  [255:0] i_n,
	output [255:0] o_aMul256,
	output         o_finished
);
localparam S_IDLE = 1'b0;
localparam S_PROC = 1'b1;
//wire
logic [256:0] tempt1,tempt2;


//reg
logic state;
logic state_nxt;
logic [7:0] counter;
logic [7:0] counter_nxt;
logic [256:0] data;
logic [256:0] data_nxt;
logic finish, finish_nxt;

assign o_finished = finish;
assign o_aMul256 = data[255:0];

always_comb begin 
	tempt1 = data << 1;
	tempt2 = (tempt1 > i_n)? tempt1 - i_n : tempt1; 
end
always_comb begin
	case(state)
	S_IDLE: begin
		if(i_start) begin
			state_nxt = S_PROC;
			data_nxt = {1'b0,i_a};
		end
		else begin
			state_nxt = state;
			data_nxt = 257'd0;
		end
		counter_nxt = 8'd0;
		finish_nxt =1'd0;
	end
	S_PROC: begin
		if(counter == 8'd255) begin
			state_nxt = S_IDLE;
			counter_nxt = 8'd0;
			finish_nxt =1'd1;
		end
		else begin
			state_nxt = state;
			counter_nxt = counter + 8'd1;
			finish_nxt =1'd0;
		end
		data_nxt = tempt2;
	end
	endcase
end

always_ff @(posedge i_clk or negedge i_rst) begin
	if(~i_rst) begin
		state <= S_IDLE;
		counter <= 8'd0;
		data <= 257'd0;
		finish <= 1'd0;
	end 
	else begin
		state <= state_nxt;
		counter <= counter_nxt;
		data <= data_nxt;
		finish <= finish_nxt;
	end
end

endmodule

