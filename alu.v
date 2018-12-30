module alu
(
    input clock,        // Clock.
    input opcode,       // Operation code.
    input [31:0] A, B,  // Operands.
    output reg result   // Result.
);

`include "parameters.v"

    wire [31:0] add_result = A + B;
    wire [31:0] sub_result = A - B;
    wire [63:0] mul_result = A * B;

    always @(*) begin
        case (opcode)
            `OP_ADD : result <= add_result;
            `OP_SUB : result <= sub_result;
            `OP_MUL : result <= mul_result[31:0];
            default : result <= 32'hxxxx_xxxx;
        endcase
    end

endmodule
