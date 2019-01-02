module memory_to_writeback
(
    input clock,
    input reset,

    /* Memory stage variables. */
    input  [4:0] m_dst_reg,     // Destination register index.
    input        m_reg_write,   // Flag indicating that register file should be written.
    input        m_mem_to_reg,  // Flag indicating if register file write data is ALU output (0) or data memory (1).
    input [31:0] m_alu_result,  // Result of the ALU operation.
    input [31:0] m_mem_data,    // Data read from memory.
    
    /* Writeback stage variables. */
    output reg  [4:0] w_dst_reg,     // Destination register index.
    output reg        w_reg_write,   // Flag indicating that register file should be written.
    output reg        w_mem_to_reg,  // Flag indicating if register file write data is ALU output (0) or data memory (1).
    output reg [31:0] w_alu_result,  // Result of the ALU operation.
    output reg [31:0] w_mem_data     // Data read from memory.
);

    always @(posedge clock) begin
        w_dst_reg    <= (reset) ?  5'b0 : m_dst_reg;
        w_reg_write  <= (reset) ?  1'b0 : m_reg_write;
        w_mem_to_reg <= (reset) ?  1'b0 : m_mem_to_reg;
        w_alu_result <= (reset) ? 32'b0 : m_alu_result;
        w_mem_data   <= (reset) ? 32'b0 : m_mem_data;
    end

endmodule