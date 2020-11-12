// Digital Circuit Lab Fall 2020
// Testbench for AudDSP.sv

`timescale 1ns/10ps
`define CYCLE 10.0
`define HCYCLE 5.0
//`define INFILE "in.pattern"
//`define OUTFILE "out_golden.pattern"

module tb;
    //integer fp_i, fp_o;
    //logic [15:0] data_base1;
    //logic        data_base2;
    logic clock, finish, check;
    integer error, num, i;
    parameter pattern_num = 4;

    logic rst, daclrck/*, enable*/;
    logic start, pause, stop, fast, slow_0, slow_1;
    logic [2:0] speed;
    logic [15:0] sram_data;
    logic [15:0] sram_addr;
    logic [15:0] dac_data;
    //logic o_aud_dacdat;

    //clock
    initial begin
        clock = 1'b1;
    end
    always begin #(`HCYCLE) clock = ~clock;
    end

    //DUT
    AudDSP dsp(
        .i_rst_n    (rst),
        .i_clk      (clock),
        .i_start    (start),
        .i_pause    (pause),
        .i_stop     (stop),
        .i_speed    (speed),
        .i_fast     (fast),
        .i_slow_0   (slow_0), 
        .i_slow_1   (slow_1),
        .i_daclrck  (daclrck),
        .i_sram_data(sram_data),
        .o_dac_data (dac_data),
        .o_sram_addr(sram_addr)
    );
    /*AudPlayer player(
        .i_rst_n      (rst),
        .i_bclk       (clock),
        .i_daclrck    (daclrck),
        .i_en         (enable),
        .i_dac_data   (dac_data),
        .o_aud_dacdat (o_aud_dacdat)
    );*/

    //SRAM
    assign sram_data = (sram_addr == 20'd0 ) ? 16'b1011_0100_0000_1111:
                       (sram_addr == 20'd1 ) ? 16'b1001_0100_0000_1111:
                       (sram_addr == 20'd2 ) ? 16'b0011_0101_1000_1110:
                       (sram_addr == 20'd3 ) ? 16'b1011_0110_0000_1100:
                       (sram_addr == 20'd4 ) ? 16'b0010_0100_0011_1101:
                       (sram_addr == 20'd5 ) ? 16'b1011_0100_0010_1111:
                       (sram_addr == 20'd6 ) ? 16'b0011_0100_1000_1111:
                       (sram_addr == 20'd7 ) ? 16'b0100_0100_0101_0000:
                       (sram_addr == 20'd8 ) ? 16'b1011_0100_0010_1100:
                       (sram_addr == 20'd9 ) ? 16'b1010_0100_1111_1010:
                       (sram_addr == 20'd10) ? 16'b0011_0101_0000_1111:
                       (sram_addr == 20'd11) ? 16'b1000_0100_0000_1111:
                       (sram_addr == 20'd12) ? 16'b0011_0110_1000_1001:
                       (sram_addr == 20'd13) ? 16'b1001_0100_0100_1101:
                       (sram_addr == 20'd14) ? 16'b1110_0100_1000_1001:
                       (sram_addr == 20'd15) ? 16'b1011_0100_0010_0100:
                                               16'b0000_0000_0000_0000;
    /*task SRAM;
        input[19:0] addr;
        output[15:0] data;

        case(addr)
            20'd0 : data = 16'b1011_0100_0000_1111;
            20'd1 : data = 16'b1001_0100_0000_1111;
            20'd2 : data = 16'b0011_0101_1000_1110;
            20'd3 : data = 16'b1011_0110_0000_1100;
            20'd4 : data = 16'b0010_0100_0011_1101;
            20'd5 : data = 16'b1011_0100_0010_1111;
            20'd6 : data = 16'b0011_0100_1000_1111;
            20'd7 : data = 16'b0100_0100_0101_0000;
            20'd8 : data = 16'b1011_0100_0010_1100;
            20'd9 : data = 16'b1010_0100_1111_1010;
            20'd10: data = 16'b0011_0101_0000_1111;
            20'd11: data = 16'b1011_0100_0000_1111;
            20'd12: data = 16'b0011_0110_1000_1001;
            20'd13: data = 16'b1001_0100_0100_1101;
            20'd14: data = 16'b1110_0100_1000_1001;
            20'd15: data = 16'b1011_0100_0010_0100;
            default: data = 16'b0000_0000_0000_0000;
        endcase
    endtask*/

    //Read file
    initial begin
        //$readmemh(`INFILE,  data_base1);
        //$readmemh(`OUTFILE, data_base2);
        //fp_i  = $fopen("in.pattern", "rb");
        //fp_o  = $fopen("out_golden.pattern", "rb"); 
        error = 0;
        finish = 1'b0;
        i = 1;
        #(`CYCLE * 300) finish = 1'b1;
    end

    //Test
    initial begin
        rst = 1'b1; check = 1'b0; start = 1'b0; daclrck = 1'b1; 
        stop = 1'b0; pause = 1'b0; speed = 3'b0; fast = 1'b0;
        slow_0 = 1'b0; slow_1 = 1'b0;
        #(`CYCLE * 2.5) rst = 1'b0;
        #(`CYCLE * 3) rst = 1'b1;

        #(`CYCLE * 2) start = 1'b1; daclrck = 1'b0;
        #(`CYCLE * 1) start = 1'b0;
        #(`CYCLE * 20)

        #(`CYCLE * 2) start = 1'b1; fast = 1'b1; speed = 3'd3;
        #(`CYCLE * 1) start = 1'b0;
        #(`CYCLE * 3) pause = 1'b1;
        #(`CYCLE * 1) pause = 1'b0;
        #(`CYCLE * 3) start = 1'b1;
        #(`CYCLE * 1) start = 1'b0;
        #(`CYCLE * 10)

        #(`CYCLE * 1) start = 1'b1; fast = 1'b0; slow_0 = 1'b1; speed = 3'd3;
        #(`CYCLE * 1) start = 1'b0;
        #(`CYCLE * 22) pause = 1'b1;
        #(`CYCLE * 1) pause = 1'b0;
        #(`CYCLE * 3) start = 1'b1;
        #(`CYCLE * 1) start = 1'b0;
        #(`CYCLE * 60)

        #(`CYCLE * 1) start = 1'b1; slow_0 = 1'b0; slow_1 = 1'b1; speed = 3'd3;
        #(`CYCLE * 1) start = 1'b0;
        #(`CYCLE * 22) pause = 1'b1;
        #(`CYCLE * 1) pause = 1'b0;
        #(`CYCLE * 3) start = 1'b1;
        #(`CYCLE * 1) start = 1'b0;
    end

    //Check
    /*initial begin
        #(`CYCLE * 6)

        
    end*/

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
        @(posedge finish) begin
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
        $fsdbDumpfile("AudDSP.fsdb");
        $fsdbDumpvars;
    end

endmodule
