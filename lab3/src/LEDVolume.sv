module LEDVolume(
    input  i_record,
    input  [15:0] i_data,
    output [17:0] o_led_r
);

    always_comb begin
        if(i_record) begin
            if(~i_data[15]) begin
                o_led_r = {i_data[14:10] == 5'd31, i_data[14:10] >= 5'd29, i_data[14:10] >= 5'd27, i_data[14:10] >= 5'd25, i_data[14:10] >= 5'd23, i_data[14:10] >= 5'd21, 
                           i_data[14:10] >= 5'd19, i_data[14:10] >= 5'd17, i_data[14:10] >= 5'd15, i_data[14:10] >= 5'd13, i_data[14:10] >= 5'd11, i_data[14:10] >= 5'd9, 
                           i_data[14:10] >= 5'd8,  i_data[14:10] >= 5'd7,  i_data[14:10] >= 5'd6,  i_data[14:10] >= 5'd5,  i_data[14:10] >= 5'd4,  i_data[14:10] >= 5'd3 };
            end 
            else begin
                o_led_r = {i_data[14:10] == 5'd0 , i_data[14:10] <= 5'd2,  i_data[14:10] <= 5'd4,  i_data[14:10] <= 5'd6 , i_data[14:10] <= 5'd8 , i_data[14:10] <= 5'd10, 
                           i_data[14:10] <= 5'd12, i_data[14:10] <= 5'd14, i_data[14:10] <= 5'd16, i_data[14:10] <= 5'd18, i_data[14:10] <= 5'd20, i_data[14:10] <= 5'd21, 
                           i_data[14:10] <= 5'd22, i_data[14:10] <= 5'd23, i_data[14:10] <= 5'd24, i_data[14:10] <= 5'd25, i_data[14:10] <= 5'd26, i_data[14:10] <= 5'd27 };
            end
        end
        else begin
            o_led_r = 17'b0;
        end
    end

endmodule
