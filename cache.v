module cache
(
    input clock,              // Clock.
    input reset,              // Marks all the cache lines as invalid.
    
    /* Cache inputs. */
    input        write,       // Write signal. When high, a write is performed to the data selected by index and word.
    input        comp,        // Compare signal. When high, the cache compares tags to indicate if a hit occurred.
    input        byte_access, // Flag that indicates byte-wise access.
    input  [1:0] index,       // Address bits used to index lines of the cache memory.
    input  [1:0] word,        // Address bits used to select the word to access in the cache line.
    input  [1:0] byte,        // Address bits used to select the byte in a word.
    input [25:0] tag_in,      // Tag to compare against stored tags to determine if a hit occurred.
    input [31:0] data_in,     // Data to write to the location specified by index and word.
    
    /* Cache outputs. */
    output        hit,        // Flag that indicates that the specified tag matches tag_in.
    output        dirty,      // Flag that indicates whether a given cache line was written to.
    output [31:0] data_out,   // Data selected by index and word.
    output        valid       // Flag that indicates the state of the valid bit.
);

    /* Since cache consists of 4 blocks of 4 words each, only 6 bits are necessary to index an entry
       in the cache. Therefore the tag length equals 26. TODO: support byte access. */

    wire tags_equal;   // Flag that indicates if tags are equal.
    wire should_write; // Flag that indicates if write should be performed. That happens in two cases:
                       // (1) a hit occurred and cache can be written to;
                       // (2) a miss occurred earlier and now cache is updated.
    
    reg [127:0] cache_data [3:0];
    reg  [25:0] cache_tags [3:0];
    reg   [3:0] cache_valid;
    
    /* Write to cache. */
    always @(posedge clock) begin
        if (should_write) begin
            cache_data[index][word] = data_in;
            cache_tags[index]       = tag_in;
            cache_valid[index]      = 1'b1;
        end
    end
    
    /* Drive module's helper variables. */
    assign tags_equal   = tag_in == cache_tags[index];
    assign should_write = reset ? 1'b0 : ((write && hit) || (write && ~comp));
    
    /* Drive module's outputs. */
    assign hit      = reset ?  1'b0 : comp && tags_equal && valid;
    assign dirty    = reset ?  1'b0 : write && hit;
    assign valid    = reset ?  1'b0 : cache_valid[index];
    assign data_out = reset ? 32'b0 : cache_data[index][word];

endmodule