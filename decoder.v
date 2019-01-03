module decoder
(
    input  [31:0] instruction,  // Fetched instruction.
    output [6:0]  opcode,       // Operation code.
    output [4:0]  dst_reg,      // Destination register index.
    output [4:0]  src_reg_1,    // First source register index.
    output [4:0]  src_reg_2,    // Second source register index.
    output [31:0] mem_offset,   // M-type operations sign-extended offset.
    output [31:0] brn_offset,   // B-type operations sign-extended offset.
    output [19:0] jmp_offset,   // Jump offset.
    
    output alu_imm_src,         // Flag indicating that an immediate should be used as ALU operand.
    output mem_read,            // Flag indicating that data memory should be read.
    output mem_write,           // Flag indicating that data memory should be written.
    output mem_byte,            // Flag indicating that memory should be accessed bite-wise.
    output reg_write,           // Flag indicating that register file should be written.
    output mem_to_reg           // Flag indicating if register file write data is ALU output (0) or data memory (1).
);

    `include "parameters.v"

    reg   [4:0] mem_access;       // Memory and register access flags.
    wire [14:0] short_mem_offset; // M-type operations offset without sign extension.
    wire [14:0] short_brn_offset; // B-type operations offset without sign extension.
    wire [29:0] long_brn_offset;  // B-type operations offset with sign extension without left-shift.

    /* A custom instruction set is used. */
    assign opcode     = instruction[31:25];
    assign dst_reg    = instruction[24:20];
    assign src_reg_1  = instruction[19:15];
    assign src_reg_2  = instruction[14:10];
    assign jmp_offset = {instruction[24:20], instruction[14:0]};
    
    /* M-type operations offsets. */
    assign short_mem_offset = instruction[14:0];
    assign mem_offset       = (short_mem_offset[14]) ? {17'h1FFFF, short_mem_offset} : {17'h0000, short_mem_offset};

    /* B-type operations offsets. */
    assign short_brn_offset = {instruction[24:20], instruction[9:0]};
    assign long_brn_offset  = (short_brn_offset[14]) ? {15'h7FFF, short_brn_offset} : {15'h0000, short_brn_offset};
    assign brn_offset       = {long_brn_offset, 2'b00};

    /* Memory and register access flags. */
    assign mem_read   = mem_access[4];
    assign mem_write  = mem_access[3];
    assign mem_byte   = mem_access[2];
    assign reg_write  = mem_access[1];
    assign mem_to_reg = mem_access[0];
    
    /* ALU operand source. */
    assign alu_imm_src = mem_read || mem_write;

    always @(*) begin
        case (opcode)
            `OP_ADD : mem_access <= 5'b00010;
            `OP_SUB : mem_access <= 5'b00010;
            `OP_MUL : mem_access <= 5'b00010;
            `OP_LDB : mem_access <= 5'b10100;
            `OP_LDW : mem_access <= 5'b10000;
            `OP_STB : mem_access <= 5'b01100;
            `OP_STW : mem_access <= 5'b01000;
            default : mem_access <= 5'b00000;
        endcase
    end

endmodule
