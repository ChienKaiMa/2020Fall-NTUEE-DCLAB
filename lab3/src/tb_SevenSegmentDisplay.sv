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
    logic recorder_start, recorder_pause, recorder_stop;
    logic player_start, player_pause, player_stop;
    logic [5:0] display_time;
    //clock
    initial begin
        clock = 1'b1;
    end
    always begin #(`HCYCLE) clock = ~clock;
    end

    //DUT
    SevenSegmentDisplay seven0 (
        .rst_n(rst),
        .clk_100k(clock),
        .recorder_start(recorder_start),
        .recorder_pause(recorder_pause),
        .recorder_stop(recorder_stop),
        .player_start(player_start),
        .player_pause(player_pause),
        .player_stop(player_stop),
        .o_display(display_time)
    );

    //Read file
    initial begin
        //$readmemh(`INFILE,  data_base1);
        //$readmemh(`OUTFILE, data_base2);
        //fp_i  = $fopen("in.pattern", "rb");
        //fp_o  = $fopen("out_golden.pattern", "rb"); 
        error = 0;
        stop  = 1'b0;
        #(`CYCLE * 500) stop = 1'b1;
    end

    //Test
    initial begin
        rst = 1'b1; recorder_start = 1'b0; recorder_pause = 1'b0; recorder_stop = 1'b0;
        #(`CYCLE * 2.5) rst = 1'b0;
        #(`CYCLE * 3) rst = 1'b1;

        #(`CYCLE * 5)   recorder_start = 1'b1;
        #(`CYCLE * 1)   recorder_start = 1'b0;
        #(`CYCLE * 100) recorder_pause = 1'b1;
        #(`CYCLE * 1)   recorder_pause = 1'b0;
        #(`CYCLE * 100) recorder_start = 1'b1;
        #(`CYCLE * 1)   recorder_start = 1'b0;
        #(`CYCLE * 100) recorder_stop  = 1'b1;
        #(`CYCLE * 1)   recorder_stop  = 1'b0;
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
        $fsdbDumpfile("SevenSegmentDisplay.fsdb");
        $fsdbDumpvars;
    end

endmodule
