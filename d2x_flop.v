module d2x_flop
(
    input clock,                      // Clock.
    input reset,                      // Command to reset all execute stage variables.

    input [6:0]  d_opcode,            // Decode stage operation code.
    input [5:0]  d_dst_reg,           // Decode stage destination register index.
    input [5:0]  d_src_reg_1,         // Decode stage first source register index.
    input [5:0]  d_src_reg_2,         // Decode stage second source register index.
    input [14:0] d_mem_offset,        // Decode stage M-type operations offset.
    input [14:0] d_brn_offset,        // Decode stage B-type operations offset.
    input [19:0] d_jmp_offset,        // Decode stage jump offset.
    input [31:0] d_read_data_1,       // Decode stage first source register content.
    input [31:0] d_read_data_2,       // Decode stage second source register content.

    output reg [6:0]  x_opcode,       // Execute stage operation code.
    output reg [5:0]  x_dst_reg,      // Execute stage destination register index.
    output reg [5:0]  x_src_reg_1,    // Execute stage first source register index.
    output reg [5:0]  x_src_reg_2,    // Execute stage second source register index.
    output reg [14:0] x_mem_offset,   // Execute stage M-type operations offset.
    output reg [14:0] x_brn_offset,   // Execute stage B-type operations offset.
    output reg [19:0] x_jmp_offset,   // Execute stage jump offset.
    output reg [31:0] x_read_data_1,  // Execute stage first source register content.
    output reg [31:0] x_read_data_2   // Execute stage second source register content.
);

    always @(posedge clock) begin
        x_opcode      <= (reset) ? 32'b0 : d_opcode;
        x_dst_reg     <= (reset) ? 32'b0 : d_dst_reg;
        x_src_reg_1   <= (reset) ? 32'b0 : d_src_reg_1;
        x_src_reg_2   <= (reset) ? 32'b0 : d_src_reg_2;
        x_mem_offset  <= (reset) ? 32'b0 : d_mem_offset;
        x_brn_offset  <= (reset) ? 32'b0 : d_brn_offset;
        x_jmp_offset  <= (reset) ? 32'b0 : d_jmp_offset;
        x_read_data_1 <= (reset) ? 32'b0 : d_read_data_1;
        x_read_data_2 <= (reset) ? 32'b0 : d_read_data_2;
    end

endmodule
