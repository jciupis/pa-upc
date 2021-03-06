module instruction_mem
(
    input          clock,    // Clock.
    input          enable,   // When low, no reads are performed.
    input   [31:0] address,  // Address to read next instruction from.
    output [127:0] data,     // Returned block of instruction memory.
    output         valid     // Flag that indicates that the output data is valid.
);

    reg         seq_valid;
    reg [127:0] seq_data;
    reg         previous_enable;
    reg         should_read;
    reg   [3:0] counter;
    reg  [31:0] instruction_mem [255:0];
    wire        read_request;
    wire  [7:0] block_aligned_addr;

    initial begin
        $readmemh("C:/Users/JC/repo/pa-upc/tests/instructions.txt", instruction_mem);
        counter = 4'b0;
        should_read = 1'b1;
    end

    /* Detect enable signal's rising edge. */
    always @(posedge clock) begin
        previous_enable = enable;
    end

    /* Latch the read request to count cycles. */
    always @(posedge clock) begin
        if (read_request)
            should_read = 1'b1;
    end

    /* Access the instruction memory after given number of cycles. */
    always @(posedge clock) begin
        // Processor requests memory read.
        if (should_read) begin
            // Start counting cycles to artificially make memory access long.
            counter = counter + 1;
            // Reset the counter, access the memory, set the valid wire and reset the read request flag.
            if (counter == 4'd10) begin
                counter          <= 4'b0;
                should_read      <= 1'b0;
                seq_data [31: 0] <= instruction_mem[block_aligned_addr];
                seq_data [63:32] <= instruction_mem[block_aligned_addr + 1];
                seq_data [95:64] <= instruction_mem[block_aligned_addr + 2];
                seq_data[127:96] <= instruction_mem[block_aligned_addr + 3];
                seq_valid        <= 1'b1;
            end
        end else
            seq_valid = 1'b0;
    end
    
    /* Drive module's helper variable. */
    assign read_request       = ~previous_enable & enable;
    assign block_aligned_addr = address[9:2] & 8'b11111100;

    /* Drive module's outputs. */
    assign valid = seq_valid;
    assign data  = seq_data;

endmodule
