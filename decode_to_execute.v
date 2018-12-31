module decode_to_execute
(
    input clock,                      // Clock.
    input reset,                      // Command to reset all execute stage variables.

    /* Decode stage variables */
    input [6:0]  d_opcode,            // Operation code.
    input [5:0]  d_dst_reg,           // Destination register index.
    input [5:0]  d_src_reg_1,         // First source register index.
    input [5:0]  d_src_reg_2,         // Second source register index.
    input [14:0] d_mem_offset,        // M-type operations offset.
    input [14:0] d_brn_offset,        // B-type operations offset.
    input [19:0] d_jmp_offset,        // Jump offset.
    input [31:0] d_read_data_1,       // First source register content.
    input [31:0] d_read_data_2,       // Second source register content.
    input        d_mem_read,          // Flag indicating that data memory should be read.
    input        d_mem_write,         // Flag indicating that data memory should be written.
    input        d_mem_byte,          // Flag indicating that memory should be accessed bite-wise.
    input        d_reg_write,         // Flag indicating that register file should be written.
    input        d_mem_to_reg,        // Flag indicating if register file write data is ALU output (0) or data memory (1).

    /* Execute stage variables */
    output reg [6:0]  x_opcode,       // Operation code.
    output reg [5:0]  x_dst_reg,      // Destination register index.
    output reg [5:0]  x_src_reg_1,    // First source register index.
    output reg [5:0]  x_src_reg_2,    // Second source register index.
    output reg [14:0] x_mem_offset,   // M-type operations offset.
    output reg [14:0] x_brn_offset,   // B-type operations offset.
    output reg [19:0] x_jmp_offset,   // Jump offset.
    output reg [31:0] x_read_data_1,  // First source register content.
    output reg [31:0] x_read_data_2,  // Second source register content.
    output reg        x_mem_read,     // Flag indicating that data memory should be read.
    output reg        x_mem_write,    // Flag indicating that data memory should be written.
    output reg        x_mem_byte,     // Flag indicating that memory should be accessed bite-wise.
    output reg        x_reg_write,    // Flag indicating that register file should be written.
    output reg        x_mem_to_reg    // Flag indicating if register file write data is ALU output (0) or data memory (1).
);

    always @(posedge clock) begin
        x_opcode      <= (reset) ?  7'b0 : d_opcode;
        x_dst_reg     <= (reset) ?  6'b0 : d_dst_reg;
        x_src_reg_1   <= (reset) ?  6'b0 : d_src_reg_1;
        x_src_reg_2   <= (reset) ?  6'b0 : d_src_reg_2;
        x_mem_offset  <= (reset) ? 15'b0 : d_mem_offset;
        x_brn_offset  <= (reset) ? 15'b0 : d_brn_offset;
        x_jmp_offset  <= (reset) ? 20'b0 : d_jmp_offset;
        x_read_data_1 <= (reset) ? 32'b0 : d_read_data_1;
        x_read_data_2 <= (reset) ? 32'b0 : d_read_data_2;
        x_mem_read    <= (reset) ?  1'b0 : d_mem_read;
        x_mem_write   <= (reset) ?  1'b0 : d_mem_write;
        x_mem_byte    <= (reset) ?  1'b0 : d_mem_byte;
        x_reg_write   <= (reset) ?  1'b0 : d_reg_write;
        x_mem_to_reg  <= (reset) ?  1'b0 : d_mem_to_reg;
    end

endmodule