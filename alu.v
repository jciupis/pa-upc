module alu
(
    input [6:0] opcode,       // Operation code.
    input [31:0] A, B,        // Operands.
    output equal,             // Flag that indicates if A is equal to B.
    output reg [31:0] result  // Result.
);

`include "parameters.v"

    wire [31:0] add_result = A + B;
    wire [31:0] sub_result = A - B;
    wire [63:0] mul_result = A * B;

    assign equal = (A == B);

    always @(*) begin
        case (opcode)
            `OP_SUB : result <= sub_result;
            `OP_MUL : result <= mul_result[31:0];
            default : result <= add_result;
        endcase
    end

endmodule
