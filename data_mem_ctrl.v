module data_mem_ctrl
(
    input         clock,
    input         reset,
    input         read,
    input         write,
    input         byte_access,
    input  [31:0] address,
    input  [31:0] write_data,
    output [31:0] read_data,
    output        stall
);

    /* Cache inputs. */
    wire  [1:0] cache_line;
    wire  [1:0] cache_word;
    wire  [1:0] cache_byte;
    wire [25:0] cache_tag_in;

    /* Cache outputs. */
    wire         cache_hit;
    wire         cache_dirty;
    wire         cache_valid;
    wire [127:0] cache_block;
    wire  [25:0] cache_tag_out;

    /* Memory signals. */
    wire         mem_read;
    wire [127:0] mem_read_data;
    wire         mem_read_valid;
    wire         mem_write;
    wire [31:0]  mem_write_addr;
    wire         mem_write_done;

    /* TODO: Byte access is not supported. */
    cache d_cache
    (
        .clock        (clock),
        .reset        (reset),
        .write_word   (write),          // Pass the write word command to cache. 
        .write_block  (mem_read_valid), // Update cache's block only once it was retrieved from data memory.
        .byte_access  (byte_access),    // Indicates if a single byte should be accessed.
        .index        (cache_line),     // Select cache block.
        .word         (cache_word),     // Select cache word.
        .byte         (cache_byte),     // Select cache byte.
        .tag_in       (cache_tag_in),   // Tag to compare against.
        .word_in      (write_data),     // Pass the word to write.
        .block_in     (mem_read_data),  // Only update cache blocks with data memory content.
        .hit          (cache_hit),      // Indicates a cache hit.
        .dirty        (cache_dirty),    // Indicates that returned data has been written to.
        .word_out     (read_data),      // Cache output data word.
        .word_valid   (cache_valid),    // This flag should be checked to prevent accidental hit.
        .block_out    (cache_block),    // Cache output data block.
        .tag_out      (cache_tag_out)   // Tag of the block accessed in cache.
    );

    data_mem d_mem
    (
        .clock          (clock),
        .read           (mem_read),
        .write          (mem_write),
        .write_address  (mem_write_addr),
        .read_address   (address),
        .write_data     (cache_block),
        .read_data      (mem_read_data),
        .write_done     (mem_write_done),
        .read_valid     (mem_read_valid)
    );

    /* Drive cache helper variables. */
    assign cache_tag_in = address[31:6];
    assign cache_line   = address[5:4];
    assign cache_word   = address[3:2];
    assign cache_byte   = address[1:0];

    /* Drive memory helper variables. */
    assign mem_read  = (read | write) & (~cache_hit | ~cache_valid);
    assign mem_write = (read | write) & (~cache_hit && cache_dirty);
    assign mem_write_addr = {cache_tag_out, 6'b0};

    /* Drive module's outputs. */
    assign stall = mem_read || mem_write;

endmodule
