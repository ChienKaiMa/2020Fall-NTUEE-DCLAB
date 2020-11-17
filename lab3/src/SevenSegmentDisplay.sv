module SevenSegmentDisplayTime(
    input  rst_n,
    input  clk,
    input  recorder_start,
    input  recorder_pause,
    input  recorder_stop,
    input  player_start,
    input  player_pause,
    input  player_stop,
    input  [2:0]i_speed,
    input  i_fast,
    input  i_slow,
    input  i_state,
    output [5:0] o_display
);

    //parameters
    localparam S_IDLE  = 0;
    localparam S_COUNT = 1;
    localparam S_PAUSE = 2;

    //registers and wires
    logic [1:0]  state_r, state_w;
    logic [25:0] cycle_counter_r, cycle_counter_w;
    logic [5:0]  o_display_r, o_display_w;
    logic [25:0] Second;

    assign Second = (i_fast && i_state) ? (26'd12000000 / (i_speed + 1)) :
                    (i_slow && i_state) ? (26'd12000000 * (i_speed + 1)) : 26'd12000000;

    //output
    assign o_display = o_display_r;

    //combinational circuit
    always_comb begin
        case(state_r)
            S_IDLE: begin
                if(recorder_start || player_start) begin
                    state_w = S_COUNT;
                    cycle_counter_w = 26'd1;
                    o_display_w = 6'd0;
                end
                else begin
                    state_w = state_r;
                    cycle_counter_w = 26'd0;
                    o_display_w = 6'd0;
                end
            end
            S_COUNT: begin
                if(recorder_stop || player_stop) begin
                    state_w = S_IDLE;
                    cycle_counter_w = 26'd0;
                    o_display_w = 6'd0;
                end
                else if(recorder_pause || player_pause) begin
                    state_w = S_PAUSE;
                    cycle_counter_w = cycle_counter_r;
                    o_display_w = o_display_r;
                end
                else begin
                    state_w = state_r;
                    cycle_counter_w = (cycle_counter_r == Second)? 26'd1 : (cycle_counter_r + 26'd1);
                    o_display_w = (cycle_counter_r == Second)? o_display_r + 6'd1 : o_display_r;
                end
            end
            S_PAUSE: begin
                if(recorder_start || player_start) begin
                    state_w = S_COUNT;
                    cycle_counter_w = (cycle_counter_r == Second)? 26'd1 : (cycle_counter_r + 26'd1);
                    o_display_w = (cycle_counter_r == Second)? o_display_r + 6'd1 : o_display_r;
                end
                else if(recorder_stop || player_stop) begin
                    state_w = S_IDLE;
                    cycle_counter_w = 26'd0;
                    o_display_w = 6'd0;
                end
                else begin
                    state_w = state_r;
                    cycle_counter_w = cycle_counter_r;
                    o_display_w = o_display_r;
                end
            end
            default: begin
                state_w = state_r;
                cycle_counter_w = 26'd0;
                o_display_w = 6'd0;
            end
        endcase
    end
    
    //sequential circuit
    always_ff@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            state_r         <= S_IDLE;
            cycle_counter_r <= 26'd0;
            o_display_r     <= 6'd1;
        end
        else begin
            state_r         <= state_w;
            cycle_counter_r <= cycle_counter_w;
            o_display_r     <= o_display_w;
        end
    end


endmodule
