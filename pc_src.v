module pc_src
(
    input clock,

    input [6:0] opcode,
    input operands_equal,

    output [1:0] pc_src
);

    `include "parameters.v"

    wire uninitialized = (opcode === 7'bx);
    wire should_brn    = ((opcode == `OP_BEQ) && operands_equal);
    wire should_jmp    = (opcode == `OP_JMP);

    assign pc_src = uninitialized ? 2'b00 : (should_brn ? 2'b01 : (should_jmp ? 2'b10 : 2'b00));

endmodule