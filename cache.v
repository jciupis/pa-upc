module cache
(
    input clock,               // Clock.
    input reset,               // Marks all the cache lines as invalid.

    /* Cache inputs. */
    input         write_word,  // Flag that indicates that a specific word should be written to.
    input         write_block, // Flag that indicates that a cache block should be updated with memory content.
    input         comp,        // Compare signal. When high, the cache compares tags to indicate if a hit occurred.
    input         byte_access, // Flag that indicates byte-wise access.
    input   [1:0] index,       // Address bits used to index lines of the cache memory.
    input   [1:0] word,        // Address bits used to select the word to access in the cache line.
    input   [1:0] byte,        // Address bits used to select the byte in a word.
    input  [25:0] tag_in,      // Tag to compare against stored tags to determine if a hit occurred.
    input  [31:0] word_in,     // Data to write to the location specified by index and word.
    input [127:0] block_in,    // Block to update the cache with in location specified by index.

    /* Cache outputs. */
    output        hit,         // Flag that indicates that the specified tag matches tag_in.
    output        dirty,       // Flag that indicates whether a given cache line was written to.
    output [31:0] data_out,    // Data selected by index and word.
    output        valid        // Flag that indicates the state of the valid bit.
);

    /* Since cache consists of 4 blocks of 4 words each, only 6 bits are necessary to index an entry
       in the cache. Therefore the tag length equals 26. TODO: support byte access. */

    wire tags_equal;         // Flag that indicates if tags are equal.
    wire should_write_word;  // Flag that indicates if a hit occurred and cache can be written to.
    wire [31:0] word_out;

    reg [127:0] cache_data [3:0];
    reg  [25:0] cache_tags [3:0];
    reg   [3:0] cache_valid;
    reg   [3:0] cache_dirty;

    integer i;
    initial begin
        for (i = 0; i < 4; i = i + 1) begin
            cache_valid[i] =   1'b0;
            cache_dirty[i] =   1'b0;
            cache_tags[i]  =  26'b0;
            cache_data[i]  = 128'b0;
        end
    end

    /* Write a word to cache. */
    always @(posedge clock) begin
        if (should_write_word) begin
            cache_data[index][word] = word_in;
            cache_dirty[index]      = 1'b1;
        end
    end

    /* Update a block of cache. */
    always @(posedge clock) begin
        if (write_block) begin
            cache_data[index] = block_in;
            cache_tags[index] = tag_in;
            cache_valid[index] = 1'b1;
            cache_dirty[index] = 1'b0;
        end
    end

    /* Drive module's helper variables. */
    assign tags_equal        = (tag_in == cache_tags[index]);
    assign should_write_word = reset ? 1'b0 : (write_word && hit);
    assign word_out          = word == 2'b00 ? cache_data[index][31:0] :
                               (word == 2'b01 ? cache_data[index][63:32] :
                               (word == 2'b10 ? cache_data[index][95:64] : cache_data[index][127:96]));

    /* Drive module's outputs. */
    assign hit      = reset ?  1'b0 : comp && tags_equal && valid;
    assign dirty    = reset ?  1'b0 : cache_dirty[index];
    assign valid    = reset ?  1'b0 : cache_valid[index];
    assign data_out = reset ? 32'b0 : word_out;

endmodule