// Digital Circuit Lab Fall 2020
// Testbench for AudPlayer.sv

`timescale 1ns/10ps
`define CYCLE 10.0
`define HCYCLE 5.0
//`define INFILE "in.pattern"
//`define OUTFILE "out_golden.pattern"

module tb;
    //integer fp_i, fp_o;
    //logic [15:0] data_base1;
    //logic        data_base2;
    //logic clock, stop, check;
    //integer error, num, i;
    //parameter pattern_num = 4;
    //logic rst, daclrck, enable;
    //logic [15:0] dac_data;
    //logic o_aud_dacdat;
    logic error, stop;

    logic rst, clock;
    logic i2c_sclk, i2c_sdat;
    logic key0down, key1down, key2down;
    logic [5:0] display;
    //clock
    initial begin
        clock = 1'b1;
    end
    always begin #(`HCYCLE) clock = ~clock;
    end

    //DUT
    Top top0(
        .i_rst_n(rst),
        .i_clk(clock),
        .i_key_0(key0down),
        .i_key_1(key1down),
        .i_key_2(key2down),
        //.i_speed(SW[2:0]),
        //.i_fast(SW[3]),
        //.i_slow_0(SW[4]),
        //.i_slow_1(SW[5]),
        
        // AudDSP and SRAM
        //.o_SRAM_ADDR(SRAM_ADDR), // [19:0]
        //.io_SRAM_DQ(SRAM_DQ), // [15:0]
        //.o_SRAM_WE_N(SRAM_WE_N),
        //.o_SRAM_CE_N(SRAM_CE_N),
        //.o_SRAM_OE_N(SRAM_OE_N),
        //.o_SRAM_LB_N(SRAM_LB_N),
        //.o_SRAM_UB_N(SRAM_UB_N),
        
        // I2C
        .i_clk_100k(clock),
        //.o_I2C_SCLK(i2c_sclk)
        //.io_I2C_SDAT(i2c_sdat)
        
        // AudPlayer
        //.i_AUD_ADCDAT(AUD_ADCDAT),
        //.i_AUD_ADCLRCK(AUD_ADCLRCK),
        //.i_AUD_BCLK(AUD_BCLK),
        //.i_AUD_DACLRCK(AUD_DACLRCK),
        //.o_AUD_DACDAT(AUD_DACDAT)

        // SEVENDECODER (optional display)
        .o_display_time(display)
        // .o_record_time(recd_time),
        // .o_play_time(play_time),

        // LCD (optional display)
        // .i_clk_800k(CLK_800K),
        // .o_LCD_DATA(LCD_DATA), // [7:0]
        // .o_LCD_EN(LCD_EN),
        // .o_LCD_RS(LCD_RS),
        // .o_LCD_RW(LCD_RW),
        // .o_LCD_ON(LCD_ON),
        // .o_LCD_BLON(LCD_BLON),

        // LED
        // .o_ledg(LEDG), // [8:0]
        // .o_ledr(LEDR) // [17:0]
    );

    //Read file
    initial begin
        //$readmemh(`INFILE,  data_base1);
        //$readmemh(`OUTFILE, data_base2);
        //fp_i  = $fopen("in.pattern", "rb");
        //fp_o  = $fopen("out_golden.pattern", "rb"); 
        error = 0;
        stop  = 1'b0;
        #(`CYCLE * 2000) stop = 1'b1;
    end

    //Test
    initial begin
        rst = 1'b1; key0down = 1'b0; key1down = 1'b0; key2down = 1'b0;
        #(`CYCLE * 2.5) rst = 1'b0;
        #(`CYCLE * 3) rst = 1'b1;

        #(`CYCLE * 1500) key1down = 1'b1;
        #(`CYCLE * 1)    key1down = 1'b0;
        #(`CYCLE * 100)  key0down = 1'b1;
        #(`CYCLE * 1)    key0down = 1'b0;
        #(`CYCLE * 100)  key1down = 1'b1;
        #(`CYCLE * 1)    key1down = 1'b0;
        #(`CYCLE * 100)  key2down = 1'b1;
        #(`CYCLE * 1)    key2down = 1'b0;
    end

    /*always@(negedge clock) begin
        if(check) begin
            i <= i + 1;
            //$fread(data_base2, fp_o);
            if(o_aud_dacdat !== data_base2) begin
                error <= error + 1;
                $display("An ERROR occurs at no.%d pattern: player_out %b != answer %b.\n", i, o_aud_dacdat, data_base2);
            end
        end
    end*/

    initial begin
        @(posedge stop) begin
            if(error == 0) begin
                $display("==========================================\n");
				$display("======  Congratulation! You Pass!  =======\n");
				$display("==========================================\n");
            end
            else begin
                $display("===============================\n");
				$display("There are %d errors.", error);
				$display("===============================\n");
            end
            $finish;
        end
    end

    //Dumping waveform files
    initial begin
        $fsdbDumpfile("Top.fsdb");
        $fsdbDumpvars;
    end

endmodule
