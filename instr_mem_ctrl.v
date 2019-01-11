module instr_mem_ctrl
(
    input clock,
    input reset,
    input [31:0] address,
    output [31:0] data,
    output stall
);

    /* Cache inputs. */
    wire  [1:0] cache_line;
    wire  [1:0] cache_word;
    wire [25:0] cache_tag_in;

    /* Cache outputs. */
    wire         cache_hit;
    wire         cache_dirty;
    wire  [31:0] cache_data;
    wire         cache_valid;
    wire [127:0] cache_block;
    wire  [26:0] cache_tag_out;

    /* Memory signals. */
    wire         mem_enable;
    wire [127:0] mem_data;
    wire         mem_valid;

    /* Instruction cache is read-only and never accesses byte-wise. */
    cache i_cache
    (
        .clock        (clock),
        .reset        (reset),
        .write_word   (1'b0),         // Instruction memory is never written to word-wise.
        .write_block  (mem_valid),    // Write to cache only when memory content is ready.
        .byte_access  (1'b0),         // Instruction cache is never accesses byte-wise.
        .index        (cache_line),   // Select cache block.
        .word         (cache_word),   // Select cache word.
        .byte         (2'b0),         // Instruction cache is never accessed byte-wise.
        .tag_in       (cache_tag_in), // Tag to compare against.
        .word_in      (31'b0),        // Instruction memory is never written to word-wise.
        .block_in     (mem_data),     // Only update cache with instruction memory content.
        .hit          (cache_hit),    // Indicates a cache hit.
        .dirty        (cache_dirty),  // This output is unused.
        .word_out     (cache_data),   // Cache output data.
        .word_valid   (cache_valid),  // This flag should be checked to prevent accidental hit.
        .block_out    (cache_block),  // This output is unused.
        .tag_out      (cache_tag_out) // This output is unused.
    );

    instruction_mem i_mem
    (
        .clock    (clock),
        .enable   (mem_enable),
        .address  (address),
        .data     (mem_data),
        .valid    (mem_valid)
    );

    /* Drive cache helper variables. */
    assign cache_tag_in = address[31:6];
    assign cache_line   = address[5:4];
    assign cache_word   = address[3:2];

    /* Drive memory helper variables. */
    assign mem_enable = ~cache_hit || ~cache_valid;

    /* Drive module's outputs. */
    assign data  = cache_data;
    assign stall = mem_enable;

endmodule