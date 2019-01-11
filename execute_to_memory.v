module execute_to_memory
(
    input clock,                        // Clock.
    input reset,                        // Command to reset all memory stage variables.

    /* Execute stage variables. */
    input  [4:0] x_dst_reg,             // Destination register index.
    input        x_mem_read,            // Flag indicating that data memory should be read.
    input        x_mem_write,           // Flag indicating that data memory should be written.
    input        x_mem_byte,            // Flag indicating that memory should be accessed bite-wise.
    input        x_reg_write,           // Flag indicating that register file should be written.
    input        x_mem_to_reg,          // Flag indicating if register file write data is ALU output (0) or data memory (1).
    input        x_mem_write_data,      // Data to write to memory.
    input [31:0] x_alu_result,          // Result of the ALU operation.
    input        x_stall,               // Flag indicating that this stage is stalled.

    /* Memory stage variables. */
    input             m_stall,          // Flag indicating that this stage is stalled.
    output reg  [4:0] m_dst_reg,        // Destination register index.
    output reg        m_mem_read,       // Flag indicating that data memory should be read.
    output reg        m_mem_write,      // Flag indicating that data memory should be written.
    output reg        m_mem_byte,       // Flag indicating that memory should be accessed bite-wise.
    output reg        m_reg_write,      // Flag indicating that register file should be written.
    output reg        m_mem_to_reg,     // Flag indicating if register file write data is ALU output (0) or data memory (1).
    output reg        m_mem_write_data, // Data to write to memory.
    output reg [31:0] m_alu_result      // Result of the ALU operation.
);

    always @(posedge clock) begin
        m_dst_reg    <= (reset) ?  5'b0 : (m_stall ? m_dst_reg                      : x_dst_reg);
        m_mem_read   <= (reset) ?  1'b0 : (m_stall ? m_mem_read   : (x_stall ? 1'b0 : x_mem_read));
        m_mem_write  <= (reset) ?  1'b0 : (m_stall ? m_mem_write  : (x_stall ? 1'b0 : x_mem_write));
        m_mem_byte   <= (reset) ?  1'b0 : (m_stall ? m_mem_byte                     : x_mem_byte);
        m_reg_write  <= (reset) ?  1'b0 : (m_stall ? m_reg_write  : (x_stall ? 1'b0 : x_reg_write));
        m_mem_to_reg <= (reset) ?  1'b0 : (m_stall ? m_mem_to_reg                   : x_mem_to_reg);
        m_alu_result <= (reset) ? 32'b0 : (m_stall ? m_alu_result                   : x_alu_result);
    end

endmodule
