module SevenSegmentDisplay(
    input  rst_n,
    input  clk_100k,
    input  recorder_start,
    input  recorder_pause,
    input  recorder_stop,
    input  player_start,
    input  player_pause,
    input  player_stop,
    output [5:0] o_display
);

    //parameters
    localparam S_IDLE  = 0;
    localparam S_COUNT = 1;
    localparam S_PAUSE = 2;
    localparam Second  = 17'd100000;

    //registers and wires
    logic [1:0]  state_r, state_w;
    logic [16:0] cycle_counter_r, cycle_counter_w;
    logic [5:0]  o_display_r, o_display_w;

    //output
    assign o_display = o_display_r;//(recorder_start || player_start);/*{4'b0, state_r}*/

    //combinational circuit
    always_comb begin
        case(state_r)
            S_IDLE: begin
                if(recorder_start || player_start) begin
                    state_w = S_COUNT;
                    cycle_counter_w = 17'd1;
                    o_display_w = 6'd0;
                end
                else begin
                    state_w = state_r;
                    cycle_counter_w = 17'd0;
                    o_display_w = 6'd0;
                end
            end
            S_COUNT: begin
                if(recorder_stop || player_stop) begin
                    state_w = S_IDLE;
                    cycle_counter_w = 17'd0;
                    o_display_w = 6'd0;
                end
                else if(recorder_pause || player_pause) begin
                    state_w = S_PAUSE;
                    cycle_counter_w = cycle_counter_r;
                    o_display_w = o_display_r;
                end
                else begin
                    state_w = state_r;
                    cycle_counter_w = (cycle_counter_r == Second)? 17'd1 : (cycle_counter_r + 17'd1);
                    o_display_w = (cycle_counter_r == Second)? o_display_r + 6'd1 : o_display_r;
                end
            end
            S_PAUSE: begin
                if(recorder_start || player_start) begin
                    state_w = S_COUNT;
                    cycle_counter_w = (cycle_counter_r == Second)? 17'd1 : (cycle_counter_r + 17'd1);
                    o_display_w = (cycle_counter_r == Second)? o_display_r + 6'd1 : o_display_r;
                end
                else if(recorder_stop || player_stop) begin
                    state_w = S_IDLE;
                    cycle_counter_w = 17'd0;
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
                cycle_counter_w = 17'd0;
                o_display_w = 6'd0;
            end
        endcase
    end
    
    //sequential circuit
    always_ff@(posedge clk_100k or negedge rst_n) begin
        if(~rst_n) begin
            state_r         <= S_COUNT;
            cycle_counter_r <= 17'd0;
            o_display_r     <= 6'd1;
        end
        else begin
            state_r         <= state_w;
            cycle_counter_r <= cycle_counter_w;
            o_display_r     <= o_display_w;
        end
    end


endmodule