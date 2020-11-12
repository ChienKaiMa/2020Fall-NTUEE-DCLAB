module AudPlayer(
    input i_rst_n,
    input i_bclk,
    input i_daclrck,
    input i_en,
    input [15:0] i_dac_data,
    output o_aud_dacdat
);
    /*parameters*/
    localparam S_IDLE = 0;
    localparam S_TRANSMIT = 1;
    localparam S_WAIT = 2;

    /*registers and wires*/
    logic[1:0] state_r, state_w;
    logic      o_aud_dacdat_w, o_aud_dacdat_r;
    logic[4:0] counter_w, counter_r;
    
    /*output assign*/
    assign o_aud_dacdat = o_aud_dacdat_r;

    /*combinational circuit*/
    always_comb begin
        state_w = state_r;
        counter_w = counter_r;
        o_aud_dacdat_w = o_aud_dacdat_r;
        case(state_r)
            S_IDLE: begin
                if(i_en & ~i_daclrck) begin
                    state_w = S_TRANSMIT;
                    counter_w = 5'd0;
                    o_aud_dacdat_w = o_aud_dacdat_r;
                end
                else begin
                    state_w = S_IDLE;
                    counter_w = counter_r;
                    o_aud_dacdat_w = o_aud_dacdat_r;
                end
            end
            S_TRANSMIT: begin
                if(counter_r == 5'd16) begin
                    state_w = S_WAIT;
                    counter_w = counter_r;
                    o_aud_dacdat_w = o_aud_dacdat_r;
                end
                else begin
                    state_w = S_TRANSMIT;
                    counter_w = counter_r + 5'd1;
                    o_aud_dacdat_w = i_dac_data[15-counter_r];
                end
            end
            S_WAIT: begin
                if(i_daclrck) begin
                    state_w = S_IDLE;
                    counter_w = counter_r;
                    o_aud_dacdat_w = o_aud_dacdat_r;
                end
                else begin
                    state_w = S_WAIT;
                    counter_w = counter_r;
                    o_aud_dacdat_w = o_aud_dacdat_r;
                end
            end
            default: begin
                state_w = state_r;
                counter_w = counter_r;
                o_aud_dacdat_w = o_aud_dacdat_r;
            end      
        endcase
    end

    /*sequential circuit*/
    always_ff@(posedge i_bclk or negedge i_rst_n) begin
        if(~i_rst_n) begin
            state_r <= S_IDLE;
            counter_r <= 5'd0;
            o_aud_dacdat_r <= 1'b0;
        end
        else begin
            state_r <= state_w;
            counter_r <= counter_w;
            o_aud_dacdat_r <= o_aud_dacdat_w;
        end
    end

endmodule
