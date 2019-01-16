module decode_to_execute
(
    input clock,                      // Clock.
    input reset,                      // Command to reset all execute stage variables.

    /* Decode stage variables */
    input [31:0] d_pc,                // Program counter.
    input [6:0]  d_opcode,            // Operation code.
    input [4:0]  d_dst_reg,           // Destination register index.
    input [4:0]  d_src_reg_1,         // First source register index.
    input [4:0]  d_src_reg_2,         // Second source register index.
    input [31:0] d_mem_offset,        // M-type operations offset.
    input [31:0] d_brn_offset,        // B-type operations offset.
    input [19:0] d_jmp_offset,        // Jump offset.
    input [31:0] d_read_data_1,       // First source register content.
    input [31:0] d_read_data_2,       // Second source register content.
    input        d_alu_imm_src,       // Flag indicating that an immediate should be used as ALU operand.
    input        d_mem_read,          // Flag indicating that data memory should be read.
    input        d_mem_write,         // Flag indicating that data memory should be written.
    input        d_mem_byte,          // Flag indicating that memory should be accessed bite-wise.
    input        d_reg_write,         // Flag indicating that register file should be written.
    input        d_mem_to_reg,        // Flag indicating if register file write data is ALU output (0) or data memory (1).
    input        d_stall,             // Flag indicating that this stage is stalled.
    input        d_flush,             // Flag indicating that this stage shoud be flushed.

    /* Execute stage variables */
    input             x_stall,        // Flag indicating that this stage is stalled.
    output reg [31:0] x_pc,           // Program counter.
    output reg [6:0]  x_opcode,       // Operation code.
    output reg [4:0]  x_dst_reg,      // Destination register index.
    output reg [4:0]  x_src_reg_1,    // First source register index.
    output reg [4:0]  x_src_reg_2,    // Second source register index.
    output reg [31:0] x_mem_offset,   // M-type operations offset.
    output reg [31:0] x_brn_offset,   // B-type operations offset.
    output reg [19:0] x_jmp_offset,   // Jump offset.
    output reg [31:0] x_read_data_1,  // First source register content.
    output reg [31:0] x_read_data_2,  // Second source register content.
    output reg        x_alu_imm_src,  // Flag indicating that an immediate should be used as ALU operand.
    output reg        x_mem_read,     // Flag indicating that data memory should be read.
    output reg        x_mem_write,    // Flag indicating that data memory should be written.
    output reg        x_mem_byte,     // Flag indicating that memory should be accessed bite-wise.
    output reg        x_reg_write,    // Flag indicating that register file should be written.
    output reg        x_mem_to_reg    // Flag indicating if register file write data is ALU output (0) or data memory (1).
);

    always @(posedge clock) begin
        x_pc          <= (reset) ? 31'b0 : (x_stall ? x_pc                            : d_pc);
        x_opcode      <= (reset | d_flush) ?  7'b0 : (x_stall ? x_opcode      : (d_stall ? 7'b0 : d_opcode));
        x_dst_reg     <= (reset | d_flush) ?  6'b0 : (x_stall ? x_dst_reg                       : d_dst_reg);
        x_src_reg_1   <= (reset) ?  6'b0 : (x_stall ? x_src_reg_1                     : d_src_reg_1);
        x_src_reg_2   <= (reset) ?  6'b0 : (x_stall ? x_src_reg_2                     : d_src_reg_2);
        x_mem_offset  <= (reset) ? 32'b0 : (x_stall ? x_mem_offset                    : d_mem_offset);
        x_brn_offset  <= (reset) ? 32'b0 : (x_stall ? x_brn_offset                    : d_brn_offset);
        x_jmp_offset  <= (reset) ? 20'b0 : (x_stall ? x_jmp_offset                    : d_jmp_offset);
        x_read_data_1 <= (reset) ? 32'b0 : (x_stall ? x_read_data_1                   : d_read_data_1);
        x_read_data_2 <= (reset) ? 32'b0 : (x_stall ? x_read_data_2                   : d_read_data_2);
        x_alu_imm_src <= (reset) ?  1'b0 : (x_stall ? x_alu_imm_src                   : d_alu_imm_src);
        x_mem_read    <= (reset | d_flush) ?  1'b0 : (x_stall ? x_mem_read    : (d_stall ? 1'b0 : d_mem_read));
        x_mem_write   <= (reset | d_flush) ?  1'b0 : (x_stall ? x_mem_write   : (d_stall ? 1'b0 : d_mem_write));
        x_mem_byte    <= (reset | d_flush) ?  1'b0 : (x_stall ? x_mem_byte                      : d_mem_byte);
        x_reg_write   <= (reset | d_flush) ?  1'b0 : (x_stall ? x_reg_write   : (d_stall ? 1'b0 : d_reg_write));
        x_mem_to_reg  <= (reset | d_flush) ?  1'b0 : (x_stall ? x_mem_to_reg                    : d_mem_to_reg);
    end

endmodule
