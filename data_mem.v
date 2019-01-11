module data_mem
(
    input          clock,          // Clock.
    input          read,           // When high, read operation is requested.
    input          write,          // When high, write operation is requested.
    input   [31:0] write_address,  // Address to write data to.
    input   [31:0] read_address,   // Address to read data from.
    input  [127:0] write_data,     // Block of memory to write.
    output [127:0] read_data,      // Returned block of data memory.
    output         write_done,     // Flag that indicates that write operation has finished.
    output         read_valid      // Flag that indicates that the output data is valid.
);

    reg         seq_write_done;
    reg         seq_read_valid;
    reg [127:0] seq_data;
    reg         previous_write;
    reg         should_write;
    reg         previous_read;
    reg         should_read;
    reg   [3:0] counter;
    reg  [31:0] data_mem [255:0];
    wire        write_request;
    wire        read_request;
    wire  [7:0] block_aligned_write;
    wire  [7:0] block_aligned_read;

    initial begin
        counter      = 4'b0;
        should_read  = 1'b0;
        should_write = 1'b0;
    end

    /* Detect write and read signals' rising edge. */
    always @(posedge clock) begin
        previous_write = write;
        previous_read = read;
    end

    /* Latch the read and write requests to count cycles. */
    always @(posedge clock) begin
        if (read_request)
            should_read = 1'b1;
        if (write_request)
            should_write = 1'b1;
    end

    /* Read data memory after given number of cycles. */
    always @(posedge clock) begin
        // Processor requests memory read.
        if (should_read) begin
            // Start counting cycles to artificially make memory access long.
            counter = counter + 1;
            // Reset the counter, access the memory, set the valid wire and reset the read request flag.
            if (counter == 4'd10) begin
                counter          <= 4'b0;
                should_read      <= 1'b0;
                seq_data [31: 0] <= data_mem[block_aligned_read];
                seq_data [63:32] <= data_mem[block_aligned_read + 1];
                seq_data [95:64] <= data_mem[block_aligned_read + 2];
                seq_data[127:96] <= data_mem[block_aligned_read + 3];
                seq_read_valid   <= 1'b1;
            end
        end else
            seq_read_valid = 1'b0;
    end

    /* Write data memory after given number of cycles. */
    always @(posedge clock) begin
        // Processor requests memory write.
        if (should_write) begin
            // Start counting cycles to artificially make memory access long.
            counter = counter + 1;
            // Reset the counter, access the memory, set the done wire and reset the write request flag.
            if (counter == 4'd10) begin
                counter                           <= 4'b0;
                should_write                      <= 1'b0;
                data_mem[block_aligned_write]     <= write_data [31: 0];
                data_mem[block_aligned_write + 1] <= write_data [63:32];
                data_mem[block_aligned_write + 2] <= write_data [95:64];
                data_mem[block_aligned_write + 3] <= write_data[127:96];
                seq_write_done                    <= 1'b1;
            end
        end
    end

    /* Drive module's helper variable. */
    assign read_request        = ~previous_read & read;
    assign write_request       = ~previous_write & write;
    assign block_aligned_read  = read_address[9:2] & 8'b11111100;
    assign block_aligned_write = write_address[9:2] & 8'b11111100;

    /* Drive module's outputs. */
    assign read_valid = seq_read_valid;
    assign read_data  = seq_data;
    assign write_done = seq_write_done;

endmodule