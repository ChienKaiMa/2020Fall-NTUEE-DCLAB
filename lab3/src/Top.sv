module Top (
	input i_rst_n,
	input i_clk,
	input i_key_0,
	input i_key_1,
	input i_key_2,
	input [2:0] i_speed, // design how user can decide mode on your own
	input i_fast,
	input i_slow_0,
	input i_slow_1,
	
	// AudDSP and SRAM
	//output [25:0] o_D_addr,
	//output [15:0] o_D_wdata,
	//input [15:0] i_D_rdata,
	//output o_D_we_n,
	output [19:0] o_SRAM_ADDR,
	inout  [15:0] io_SRAM_DQ,
	output        o_SRAM_WE_N,
	output        o_SRAM_CE_N,
	output        o_SRAM_OE_N,
	output        o_SRAM_LB_N,
	output        o_SRAM_UB_N,
	
	// I2C
	input  i_clk_100k,
	output o_I2C_SCLK,
	inout  io_I2C_SDAT,
	
	// AudPlayer
	input  i_AUD_ADCDAT,
	inout  i_AUD_ADCLRCK,
	inout  i_AUD_BCLK,
	inout  i_AUD_DACLRCK,
	output o_AUD_DACDAT,

	// SEVENDECODER (optional display)
	output [5:0] o_display_time
	// output [5:0] o_play_time,

	// LCD (optional display)
	// input        i_clk_800k,
	// inout  [7:0] o_LCD_DATA,
	// output       o_LCD_EN,
	// output       o_LCD_RS,
	// output       o_LCD_RW,
	// output       o_LCD_ON,
	// output       o_LCD_BLON,

	// LED
	// output  [8:0] o_ledg,
	// output [17:0] o_ledr
);

	// design the FSM and states as you like
	localparam S_INIT   	  = 0;
	localparam S_IDLE   	  = 1;
	localparam S_RECORD 	  = 2;
	localparam S_PLAY   	  = 3;
	localparam S_RECORD_PAUSE = 4;
	localparam S_PLAY_PAUSE	  = 5;
	logic[2:0] state_r, state_w;

	logic i2c_oen;
	wire  i2c_sdat;
	logic [19:0] addr_record, addr_play, stop_addr;
	logic [15:0] data_record, data_play;
	logic [15:0] dac_data;

	logic i2c_start, i2c_finish, i2c_state;
	logic dsp_start, dsp_stop, dsp_pause;
	logic player_enable;
	logic recorder_start, recorder_pause, recorder_stop;

	assign io_I2C_SDAT = (i2c_oen) ? i2c_sdat : 1'bz;

	//assign o_D_addr[19:0] = (state_r == S_RECORD) ? addr_record : addr_play[19:0];
	//assign o_D_addr[25:20] = 0;
	//assign o_D_wdata = (state_r == S_RECORD) ? data_record : 16'd0;
	//assign i_data_play = (state_r != S_RECORD) ? i_D_rdata : 16'd0; 
	assign o_SRAM_ADDR = (state_r == S_RECORD) ? addr_record : addr_play[19:0];
	assign io_SRAM_DQ  = (state_r == S_RECORD) ? data_record : 16'dz; // sram_dq as output
	assign data_play   = (state_r != S_RECORD) ? io_SRAM_DQ : 16'd0; // sram_dq as input

	//assign o_D_we_n = (state_r == S_RECORD) ? 1'b0 : 1'b1;
	assign o_SRAM_WE_N = (state_r == S_RECORD) ? 1'b0 : 1'b1;
	assign o_SRAM_CE_N = 1'b0;
	assign o_SRAM_OE_N = 1'b0;
	assign o_SRAM_LB_N = 1'b0;
	assign o_SRAM_UB_N = 1'b0;

	assign dsp_start 	  = i_key_0 && ((state_r == S_IDLE) || (state_r == S_PLAY_PAUSE));
	assign dsp_pause 	  = i_key_1 && (state_r == S_PLAY);
	assign dsp_stop  	  = i_key_2 && ((state_r == S_PLAY) || (state_r == S_PLAY_PAUSE));
	assign player_enable  = (state_w == S_PLAY);
	assign recorder_start = i_key_1 && ((state_r == S_IDLE) || (state_r == S_RECORD_PAUSE));
	assign recorder_pause = i_key_0 && (state_r == S_RECORD);
	assign recorder_stop  = i_key_2 && ((state_r == S_RECORD) || (state_r == S_RECORD_PAUSE));

	// below is a simple example for module division
	// you can design these as you like

	// === I2cInitializer ===
	// sequentially sent out settings to initialize WM8731 with I2C protocal
	I2cInitializer init0(
		.i_rst_n(i_rst_n),
		.i_clk(i_clk_100k),
		.i_start(i2c_start),
		.o_finished(i2c_finish),
		.o_sclk(o_I2C_SCLK),
		.o_sdat(i2c_sdat),
		.o_oen(i2c_oen), // you are outputing (you are not outputing only when you are "ack"ing.)
		.o_state(i2c_state)
	);

	// === AudDSP ===
	// responsible for DSP operations including fast play and slow play at different speed
	// in other words, determine which data addr to be fetch for player 
	AudDSP dsp0(
		.i_rst_n(i_rst_n),
		.i_clk(i_clk),
		.i_start(dsp_start),
		.i_pause(dsp_pause),
		.i_stop(dsp_stop),
		.i_speed(i_speed),
		.i_fast(i_fast),
		.i_slow_0(i_slow_0), // constant interpolation
		.i_slow_1(i_slow_1), // linear interpolation
		.i_daclrck(i_AUD_DACLRCK),
		.i_sram_data(data_play),
		.i_stop_addr(stop_addr),
		.o_dac_data(dac_data),
		.o_sram_addr(addr_play)
	);

	// === AudPlayer ===
	// receive data address from DSP and fetch data to sent to WM8731 with I2S protocal
	AudPlayer player0(
		.i_rst_n(i_rst_n),
		.i_bclk(i_AUD_BCLK),
		.i_daclrck(i_AUD_DACLRCK),
		.i_en(player_enable), // enable AudPlayer only when playing audio, work with AudDSP
		.i_dac_data(dac_data), //dac_data
		.o_aud_dacdat(o_AUD_DACDAT)
	);

	// === AudRecorder ===
	// receive data from WM8731 with I2S protocal and save to SRAM
	AudRecorder recorder0(
		.i_rst_n(i_rst_n), 
		.i_clk(i_AUD_BCLK),
		.i_lrc(i_AUD_ADCLRCK),
		.i_start(recorder_start),
		.i_pause(recorder_pause),
		.i_stop(recorder_stop),
		.i_data(i_AUD_ADCDAT),
		.o_address(addr_record),
		.o_stop_address(stop_addr),
		.o_data(data_record)
	);

	// === SevenSegmentDisplay ===
	//SevenSegmentDisplay seven0(
	//	.rst_n(i_rst_n),
	//	.clk_100k(i_clk_100k),
	//	.recorder_start(recorder_start),
	//	.recorder_pause(recorder_pause),
	//	.recorder_stop(recorder_stop),
	//	.player_start(dsp_start),
	//	.player_pause(dsp_pause),
	//	.player_stop(dsp_stop),
	//	.o_display(o_display_time)
	//);

	always_comb begin
		// design your control here
		case(state_r) 
			S_INIT: begin
				if(i2c_finish) begin
					state_w = S_IDLE;
				end
				else begin
					state_w = state_r;
				end
			end
			S_IDLE: begin
				if(recorder_start) begin
					state_w = S_RECORD;
				end
				else if(dsp_start) begin
					state_w = S_PLAY;
				end
				else begin
					state_w = state_r;
				end
			end
			S_RECORD: begin
				if(recorder_stop) begin
					state_w = S_IDLE;
				end
				else if(recorder_pause) begin
					state_w = S_RECORD_PAUSE;
				end
				else begin
					state_w = state_r;
				end
			end
			S_PLAY: begin
				if(dsp_stop) begin
					state_w = S_IDLE;
				end
				else if(dsp_pause) begin
					state_w = S_PLAY_PAUSE;
				end
				else begin
					state_w = state_r;
				end
			end
			S_RECORD_PAUSE: begin
				if(recorder_start) begin
					state_w = S_RECORD;
				end
				else if(recorder_stop) begin
					state_w = S_IDLE;
				end
				else begin
					state_w = state_r;
				end
			end
			S_PLAY_PAUSE: begin
				if(dsp_start) begin
					state_w = S_PLAY;
				end
				else if(dsp_stop) begin
					state_w = S_IDLE;
				end
				else begin
					state_w = state_r;
				end
			end
			default: begin
				state_w = state_r;
			end
		endcase
	end

	always_ff @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) begin
			state_r <= S_INIT;
			i2c_start <= 1;
		end
		else begin
			state_r <= state_w;
			i2c_start <= 1;
		end
	end


	//7 segment display part
	    //parameters
    localparam S_7_IDLE  = 0;
    localparam S_7_COUNT = 1;
    localparam S_7_PAUSE = 2;
    localparam Second  = 26'd12000000;

    //registers and wires
    logic [1:0]  state_r_7, state_w_7;
    logic [25:0] cycle_counter_r_7, cycle_counter_w_7;
    logic [5:0]  o_display_r_7, o_display_w_7;

    //output
    assign o_display_time = o_display_r_7;//(recorder_start || player_start);/*{4'b0, state_r}*/

    //combinational circuit
    always_comb begin
        case(state_r_7)
            S_7_IDLE: begin
                if(recorder_start || dsp_start) begin
                    state_w_7 = S_7_COUNT;
                    cycle_counter_w_7 = 25'd1;
                    o_display_w_7 = 6'd0;
                end
                else begin
                    state_w_7 = state_r_7;
                    cycle_counter_w_7 = 25'd0;
                    o_display_w_7 = 6'd0;
                end
            end
            S_7_COUNT: begin
                if(recorder_stop || dsp_stop) begin
                    state_w_7 = S_7_IDLE;
                    cycle_counter_w_7 = 25'd0;
                    o_display_w_7 = 6'd0;
                end
                else if(recorder_pause || dsp_pause) begin
                    state_w_7 = S_7_PAUSE;
                    cycle_counter_w_7 = cycle_counter_r_7;
                    o_display_w_7 = o_display_r_7;
                end
                else begin
                    state_w_7 = state_r_7;
                    cycle_counter_w_7 = (cycle_counter_r_7 == Second)? 25'd1 : (cycle_counter_r_7 + 25'd1);
                    o_display_w_7 = (cycle_counter_r_7 == Second)? o_display_r_7 + 6'd1 : o_display_r_7;
                end
            end
            S_7_PAUSE: begin
                if(recorder_start || dsp_start) begin
                    state_w_7 = S_7_COUNT;
                    cycle_counter_w_7 = (cycle_counter_r_7 == Second)? 25'd1 : (cycle_counter_r_7 + 25'd1);
                    o_display_w_7 = (cycle_counter_r_7 == Second)? o_display_r_7 + 6'd1 : o_display_r_7;
                end
                else if(recorder_stop || dsp_stop) begin
                    state_w_7 = S_7_IDLE;
                    cycle_counter_w_7 = 25'd0;
                    o_display_w_7 = 6'd0;
                end
                else begin
                    state_w_7 = state_r_7;
                    cycle_counter_w_7 = cycle_counter_r_7;
                    o_display_w_7 = o_display_r_7;
                end
            end
            default: begin
                state_w_7 = state_r_7;
                cycle_counter_w_7 = 25'd0;
                o_display_w_7 = 6'd0;
            end
        endcase
    end
    
    //sequential circuit
    always_ff@(posedge i_clk or negedge i_rst_n) begin
        if(~i_rst_n) begin
            state_r_7         <= S_7_IDLE;
            cycle_counter_r_7 <= 25'd0;
            o_display_r_7     <= 6'd1;
        end
        else begin
            state_r_7         <= state_w_7;
            cycle_counter_r_7 <= cycle_counter_w_7;
            o_display_r_7     <= o_display_w_7;
        end
    end

endmodule
