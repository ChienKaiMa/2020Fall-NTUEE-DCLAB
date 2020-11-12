module I2cInitializer(
    input  i_rst_n,
    input  i_clk,
    input  i_start,
    output o_finished,
    output o_sclk,
    inout  o_sdat,
    output o_oen
);

    // 24-bit Audio CODEC p.29
    // data[23:17]: ADDR[6:0]
    // data[16]: R/W 0->Write
    // data[15:9]: B[15:9] Register Address Bits
    // data[8:0]: B[8:0] Register Data Bits
    localparam setup_byte = 30; // Count of data bytes
    logic [setup_byte * 8:0] setup_data = {
        24'b00110100_000_1001_0_0000_0001, // Active Control
        24'b00110100_000_1000_0_0001_1001, // Sampling Control
        24'b00110100_000_0111_0_0100_0010, // Digital Audio Interface Format
        24'b00110100_000_0110_0_0000_0000, // Power Down Control
        24'b00110100_000_0101_0_0000_0000, // Digital Audio Path Control
        24'b00110100_000_0100_0_0001_0101, // Analogue Audio Path Control
        24'b00110100_000_0011_0_0111_1001, // Right Headphone Out
        24'b00110100_000_0010_0_0111_1001, // Left Headphone Out
        24'b00110100_000_0001_0_1001_0111, // Right Line In
        24'b00110100_000_0000_0_1001_0111  // Left Line In
    };
    // logic [3*8:0] reset_data = 24'b00110100_000_1111_0_0000_0000;
    // 4 modes of WM8731/L
    // Right justified
    // Left justified
    // I2S
    // DSP mode

    logic finished, sclk, sdat, oen, state;
    logic [1:0] sclk_state;
    assign o_finished = finished;
    assign o_sclk = sclk;
    assign o_sdat = oen? sdat: 1'bz;
    assign o_oen = oen;

    localparam S_IDLE = 0;
    localparam S_START = 1; // Start initialization process


    localparam SCLK_MOD = 0; // Modifying data
    localparam SCLK_READ = 1; // Data read
    localparam SCLK_ACK = 2; // Acknowledgement


    logic [3:0] bit_count; // Ack for every 8 bits sent
    logic [4:0] byte_count; // Check if all data sent
    logic [2:0] cycle_count; // 3 cycles = 24 bytes sent
    logic [setup_byte * 8:0] data; // Memory in FF?

    // i_start should be a pulse (button click)
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (~i_rst_n) begin
            finished <= 0;
            state <= S_IDLE;
        end 
        else if (i_start) begin
            // Prepare to start
            sclk <= 1;
            sdat <= 1;
            oen <= 1;
            state <= S_START;
            sclk_state <= SCLK_MOD;
            bit_count <= 0;
            byte_count <= 0;
            cycle_count <= 3;
            data <= setup_data;
        end 
        else if (state == S_START) begin
            // Sending initialization data
            if (cycle_count == 3) begin
                oen <= 1;
                sdat <= 0;
                sclk <= 1;
            end 
            else if (byte_count == setup_byte) begin
                // Finish initialization after cycle_count resets to 0?
                sdat <= 1;
                finished <= 1;
                state <= S_IDLE;
            end 
            else if (bit_count != 8) begin
                oen <= 1;
                case (sclk_state)
                    SCLK_MOD: begin
                        sclk <= 0;
                        sdat <= data[setup_byte * 8 - 1];
                        data <= data << 1;
                        sclk_state <= SCLK_READ;
                    end
                    SCLK_READ: begin
                        sclk <= 1;
                        sclk_state <= SCLK_MOD;
                        bit_count <= bit_count + 1;
                    end
                endcase
            end 
            else begin
                case (sclk_state)
                    SCLK_MOD: begin
                        oen <= 0;
                        sclk <= 1;
                        sclk_state <= SCLK_ACK;
                    end
                    SCLK_ACK: begin
                        sclk <= 1;
                        sclk_state <= SCLK_MOD;
                        bit_count <= 0;
                        byte_count <= byte_count + 1;
                        cycle_count <= cycle_count + 1;
                    end
                endcase
            end
        end
    end
endmodule
