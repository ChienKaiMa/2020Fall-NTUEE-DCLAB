module SevenHexDecoder (
	input        [5:0] i_hex,
	output logic [6:0] o_seven_ten,
	output logic [6:0] o_seven_one
);

/* The layout of seven segment display, 1: dark
 *    00
 *   5  1
 *    66
 *   4  2
 *    33
 */
parameter D0 = 7'b1000000;
parameter D1 = 7'b1111001;
parameter D2 = 7'b0100100;
parameter D3 = 7'b0110000;
parameter D4 = 7'b0011001;
parameter D5 = 7'b0010010;
parameter D6 = 7'b0000010;
parameter D7 = 7'b1011000;
parameter D8 = 7'b0000000;
parameter D9 = 7'b0010000;
always_comb begin
	case(i_hex)
		6'd0 : begin o_seven_ten = D0; o_seven_one = D0; end
		6'd1 : begin o_seven_ten = D0; o_seven_one = D1; end
		6'd2 : begin o_seven_ten = D0; o_seven_one = D2; end
		6'd3 : begin o_seven_ten = D0; o_seven_one = D3; end
		6'd4 : begin o_seven_ten = D0; o_seven_one = D4; end
		6'd5 : begin o_seven_ten = D0; o_seven_one = D5; end
		6'd6 : begin o_seven_ten = D0; o_seven_one = D6; end
		6'd7 : begin o_seven_ten = D0; o_seven_one = D7; end
		6'd8 : begin o_seven_ten = D0; o_seven_one = D8; end
		6'd9 : begin o_seven_ten = D0; o_seven_one = D9; end
		6'd10: begin o_seven_ten = D1; o_seven_one = D0; end
		6'd11: begin o_seven_ten = D1; o_seven_one = D1; end
		6'd12: begin o_seven_ten = D1; o_seven_one = D2; end
		6'd13: begin o_seven_ten = D1; o_seven_one = D3; end
		6'd14: begin o_seven_ten = D1; o_seven_one = D4; end
		6'd15: begin o_seven_ten = D1; o_seven_one = D5; end
		6'd16: begin o_seven_ten = D1; o_seven_one = D6; end
		6'd17: begin o_seven_ten = D1; o_seven_one = D7; end
		6'd18: begin o_seven_ten = D1; o_seven_one = D8; end
		6'd19: begin o_seven_ten = D1; o_seven_one = D9; end
		6'd20: begin o_seven_ten = D2; o_seven_one = D0; end
		6'd21: begin o_seven_ten = D2; o_seven_one = D1; end
		6'd22: begin o_seven_ten = D2; o_seven_one = D2; end
		6'd23: begin o_seven_ten = D2; o_seven_one = D3; end
		6'd24: begin o_seven_ten = D2; o_seven_one = D4; end
		6'd25: begin o_seven_ten = D2; o_seven_one = D5; end
		6'd26: begin o_seven_ten = D2; o_seven_one = D6; end
		6'd27: begin o_seven_ten = D2; o_seven_one = D7; end
		6'd28: begin o_seven_ten = D2; o_seven_one = D8; end
		6'd29: begin o_seven_ten = D2; o_seven_one = D9; end
		6'd30: begin o_seven_ten = D3; o_seven_one = D0; end
		6'd31: begin o_seven_ten = D3; o_seven_one = D1; end
		6'd32: begin o_seven_ten = D3; o_seven_one = D2; end
		default: begin o_seven_ten = D3; o_seven_one = D2; end
	endcase
end

endmodule
