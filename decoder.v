module decoder
(
    input  [31:0] instruction,  // Fetched instruction.
    output [6:0]  opcode,       // Operation code.
    output [4:0]  dst_reg,      // Destination register index.
    output [4:0]  src_reg_1,    // First source register index.
    output [4:0]  src_reg_2,    // Second source register index.
    output [14:0] mem_offset,   // M-type operations offset.
    output [14:0] brn_offset,   // B-type operations offset.
    output [19:0] jmp_offset,   // Jump offset.
    
    output mem_read,            // Flag indicating that data memory should be read.
    output mem_write,           // Flag indicating that data memory should be written.
    output mem_byte,            // Flag indicating that memory should be accessed bite-wise.
    output reg_write,           // Flag indicating that register file should be written.
    output mem_to_reg           // Flag indicating if register file write data is ALU output (0) or data memory (1).
);

    `include "parameters.v"

    /* Memory and register access flags. */
    reg [4:0] mem_access;

    /* A custom instruction set is used. */
    assign opcode     = instruction[31:25];
    assign dst_reg    = instruction[24:20];
    assign src_reg_1  = instruction[19:15];
    assign src_reg_2  = instruction[14:10];
    assign mem_offset = instruction[14:0];
    assign brn_offset = {instruction[24:20], instruction[9:0]};
    assign jmp_offset = {instruction[24:20], instruction[14:0]};
    
    assign mem_read   = mem_access[0];
    assign mem_write  = mem_access[1];
    assign mem_byte   = mem_access[2];
    assign reg_write  = mem_access[3];
    assign mem_to_reg = mem_access[4];
    
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
