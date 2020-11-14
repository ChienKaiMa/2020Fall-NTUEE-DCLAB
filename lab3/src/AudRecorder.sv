module AudRecorder(
	input i_rst_n,
	input i_clk,
	input i_lrc,
	input i_start,
	input i_pause,
	input i_stop,
	input i_data,
	output [19:0] o_address,
	output [15:0] o_data,
	output [19:0] o_stop_address //////////////////////////////////////////////////////////////////////////////////
	//output [2:0] o_state
);
	logic [2:0] state, state_nxt;
	logic [5:0] Bctr,Bctr_nxt; //bit counter for 16 bit audio 
	logic [19:0] addr,addr_nxt;
	logic [15:0] data,data_nxt;
	assign o_address = addr;
	assign o_data = data; 
	//assign o_state = state;
	assign o_stop_address = addr; /////////////////////////////////////////////////////////////////////////////////
	localparam ADD_BASE = 20'b11111111111111111111; //= -1
	localparam S_IDLE = 3'd0;
	localparam S_WAIT = 3'd1;
	localparam S_DATA = 3'd2;
	localparam S_PAUSE1 = 3'd3;
	localparam S_PAUSE2 = 3'd4;
	always_comb begin
		case(state)
			S_IDLE: begin
				if(i_start) begin
					state_nxt = S_WAIT;
					addr_nxt = ADD_BASE;/////////////////////////////////////////////////////////////////////////////////
				end
				else begin
					state_nxt = state;
					addr_nxt = addr;//////////////////////////////////////////////////////////////////////////////////////
				end
				Bctr_nxt = 5'd0;
				data_nxt = 16'd0;
			end
			S_WAIT: begin
				if(i_stop) begin
					state_nxt = S_IDLE;
				end
				else if(i_pause) begin
					state_nxt = S_PAUSE1;
				end
				else if(i_lrc) begin //record right channel
					state_nxt = S_DATA;
				end
				else begin
					state_nxt = state;
				end
				Bctr_nxt = 5'd0;
				addr_nxt = addr;
				data_nxt = 16'd0;
			end
			S_DATA: begin
				if(i_stop) begin
					state_nxt = S_IDLE;
					Bctr_nxt = 5'd0;
					addr_nxt = addr;
					data_nxt = 16'd0;
				end
				else if(i_pause) begin
					state_nxt = S_PAUSE1;
					Bctr_nxt = 5'd0;
					addr_nxt = addr;
					data_nxt = 16'd0;
				end
				else if(Bctr<5'd16) begin //record right channel
					state_nxt = S_DATA;
					Bctr_nxt = Bctr + 5'd1;
					addr_nxt = addr;
					data_nxt = {data[15:0],i_data};
				end
				else if(!i_lrc) begin
					state_nxt = S_WAIT;
					Bctr_nxt = 5'd0;
					addr_nxt = addr + 20'd1; //only change o_address when output(i_lrc=1=right channel)
					data_nxt = data;
				end
				else begin
					state_nxt = state;
					Bctr_nxt = Bctr;
					addr_nxt = addr;
					data_nxt = data;
				end
			end
			S_PAUSE1: begin
				if(i_start) begin
					state_nxt = S_WAIT;
				end
				else begin
					state_nxt = state;
				end
				Bctr_nxt = 5'd0;
				addr_nxt = addr;
				data_nxt = 16'd0;
			end
		endcase
	end
	always_ff @(posedge i_clk or negedge i_rst_n) begin
		if(~i_rst_n) begin
			state <= S_IDLE;
			Bctr <= 5'd0;
			addr <= ADD_BASE;
			data <= 16'd0;
		end else begin
			state <= state_nxt;
			Bctr <= Bctr_nxt;
			addr <= addr_nxt;
			data <= data_nxt;
		end
	end
endmodule
