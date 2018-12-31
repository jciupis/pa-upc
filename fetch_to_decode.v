module fetch_to_decode
(
    input clock,               // Clock.
    input reset,               // Command to reset all decode stage variables.
    
    input [31:0] f_instr,      // Fetch stage instruction.
    input [31:0] f_pc,         // Fetch stage program counter.
    
    output reg [31:0] d_instr, // Decode stage instruction.
    output reg [31:0] d_pc     // Decode stage program counter.
);

    always @(posedge clock) begin
        d_instr <= (reset) ? 32'b0 : f_instr;
        d_pc    <= (reset) ? 32'b0 : f_pc;
    end

endmodule
