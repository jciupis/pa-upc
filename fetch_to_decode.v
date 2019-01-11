module fetch_to_decode
(
    input clock,               // Clock.
    input reset,               // Command to reset all decode stage variables.
    
    /* Fetch stage variables. */
    input [31:0] f_instr,      // Instruction.
    input [31:0] f_pc,         // Program counter.
    input        f_stall,      // Flag indicating that this stage is stalled.
    
    /* Decode stage variables. */
    input             d_stall, // Flag indicating that this stage is stalled.
    output reg [31:0] d_instr, // Instruction.
    output reg [31:0] d_pc     // Program counter.
);

    always @(posedge clock) begin
        d_instr <= (reset) ? 32'b0 : (d_stall ? d_instr : (f_stall ? 32'b0 : f_instr));
        d_pc    <= (reset) ? 32'b0 : (d_stall ? d_pc                       : f_pc);
    end

endmodule
