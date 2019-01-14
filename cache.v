module cache
(
    input clock,               // Clock.
    input reset,               // Marks all the cache lines as invalid.

    /* Cache inputs. */
    input         write_word,  // Flag that indicates that a specific word should be written to.
    input         write_block, // Flag that indicates that a cache block should be updated with memory content.
    input         byte_access, // Flag that indicates byte-wise access.
    input   [1:0] index,       // Address bits used to index lines of the cache memory.
    input   [1:0] word,        // Address bits used to select the word to access in the cache line.
    input   [1:0] byte,        // Address bits used to select the byte in a word.
    input  [25:0] tag_in,      // Tag to compare against stored tags to determine if a hit occurred.
    input  [31:0] word_in,     // Data to write to the location specified by index and word.
    input [127:0] block_in,    // Block to update the cache with in location specified by index.

    /* Cache outputs. */
    output         hit,        // Flag that indicates that the specified tag matches tag_in.
    output         dirty,      // Flag that indicates whether a given cache line was written to.
    output [31:0]  word_out,   // Data selected by index and word.
    output         word_valid, // Flag that indicates the state of the valid bit.
    output [127:0] block_out,  // Block read to update external memory.
    output  [25:0] tag_out
);

    /* Since cache consists of 4 blocks of 4 words each, only 6 bits are necessary to index an entry
       in the cache. Therefore the tag length equals 26. TODO: support byte access. */

    wire tags_equal;         // Flag that indicates if tags are equal.
    wire should_write_word;  // Flag that indicates if a hit occurred and cache can be written to.
    wire [31:0] read_word;
    wire [31:0] word_to_return;

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
            /* Cache should be written to byte-wise. */
            if (byte_access) begin
                case ({word, byte})
                    4'b0000: cache_data[index]    [7:0] = word_in[7:0];
                    4'b0001: cache_data[index]   [15:8] = word_in[7:0];
                    4'b0010: cache_data[index]  [23:16] = word_in[7:0];
                    4'b0011: cache_data[index]  [31:24] = word_in[7:0];
                    4'b0100: cache_data[index]  [39:32] = word_in[7:0];
                    4'b0101: cache_data[index]  [47:40] = word_in[7:0];
                    4'b0110: cache_data[index]  [55:48] = word_in[7:0];
                    4'b0111: cache_data[index]  [63:56] = word_in[7:0];
                    4'b1000: cache_data[index]  [71:64] = word_in[7:0];
                    4'b1001: cache_data[index]  [79:72] = word_in[7:0];
                    4'b1010: cache_data[index]  [87:80] = word_in[7:0];
                    4'b1011: cache_data[index]  [95:88] = word_in[7:0];
                    4'b1100: cache_data[index] [103:96] = word_in[7:0];
                    4'b1101: cache_data[index][111:104] = word_in[7:0];
                    4'b1110: cache_data[index][119:112] = word_in[7:0];
                    4'b1111: cache_data[index][127:120] = word_in[7:0];
                endcase
            /* Cache should be written to word-wise. */
            end else begin
                case (word)
                    2'b00: cache_data[index]  [31:0] = word_in;
                    2'b01: cache_data[index] [63:32] = word_in;
                    2'b10: cache_data[index] [96:64] = word_in;
                    2'b11: cache_data[index][127:96] = word_in;
                endcase
            end
            cache_dirty[index] = 1'b1;
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
    assign read_word         = word == 2'b00 ? cache_data[index][31:0] :
                              (word == 2'b01 ? cache_data[index][63:32] :
                              (word == 2'b10 ? cache_data[index][95:64] : cache_data[index][127:96]));
    assign word_to_return    = byte_access ? (byte == 2'b00 ? {24'b0, read_word[7:0]}   :
                                             (byte == 2'b01 ? {24'b0, read_word[15:8]}  :
                                             (byte == 2'b10 ? {24'b0, read_word[23:16]} : {24'b0, read_word[31:24]}))) : read_word;

    /* Drive module's outputs. */
    assign hit        = reset ?   1'b0 : tags_equal && word_valid;
    assign dirty      = reset ?   1'b0 : cache_dirty[index];
    assign word_out   = reset ?  32'b0 : word_to_return;
    assign word_valid = reset ?   1'b0 : cache_valid[index];
    assign block_out  = reset ? 127'b0 : cache_data[index];
    assign tag_out    = reset ?  26'b0 : cache_tags[index];

endmodule
