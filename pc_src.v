module pc_src
(
    input clock,

    input [6:0] opcode,
    input operands_equal,

    output reg [1:0] pc_src
);

    `include "parameters.v"

    initial
        pc_src = 2'b00;

    always @(posedge clock) begin
        if ((opcode == `OP_BEQ) && operands_equal)
            pc_src <= 2'b01;
        else if (opcode == `OP_JMP)
            pc_src <= 2'b10;
        else
            pc_src <= 2'b00;
    end

endmodule