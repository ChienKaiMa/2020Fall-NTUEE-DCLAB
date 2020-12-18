module Wrapper (
    //RS232
    input         avm_rst,
    input         avm_clk,
    output  [4:0] avm_address,
    output        avm_read,
    input  [31:0] avm_readdata,
    output        avm_write,
    //output [31:0] avm_writedata,
    input         avm_waitrequest,

    //VGA
    output [7:0]  VGA_B,
	output        VGA_BLANK_N,
	output        VGA_CLK,
	output [7:0]  VGA_G,
	output        VGA_HS,
	output [7:0]  VGA_R,
	output        VGA_SYNC_N,
	output        VGA_VS
);

    logic [7:0] pixel_value;

    RS232 rs2320(
        .avm_rst(avm_rst),
        .avm_clk(avm_clk),
        .avm_address(avm_address),
        .avm_read(avm_read),
        .avm_readdata(avm_readdata),
        .avm_write(avm_write),
        .avm_waitrequest(avm_waitrequest),
        .pixel_value(pixel_value)
    );

    vga vga0(
        .i_rst_n(avm_rst),
        .i_clk_25M(avm_clk),
        .VGA_B(VGA_B),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_CLK(VGA_CLK),
        .VGA_G(VGA_G),
        .VGA_HS(VGA_HS),
        .VGA_R(VGA_R),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_VS(VGA_VS),
        .pixel_value(pixel_value)
    );

endmodule
