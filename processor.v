module processor
(
    input clock,
    input reset
);

////////////////////////////////////////////////////////////////////////////////////////////////////

    /* There is no support for branch & jump instructions yet. */
    /* There is also no support for exceptions and other more complex stuff. */

    wire [31:0] f_pc_in;     // Previous value of the PC.
    wire [31:0] f_pc_out;    // Current value of the PC.
    wire [31:0] f_pc_add4;   // Next value of the PC (no support for branches yet).
    wire [31:0] f_instr;     // Fetched instruction.
    wire [31:0] mock_jmp_pc; // TODO: a mocked signal to fill an empty input. Change it to sth meaningful

    /* Instruction memory interface. */
    instruction_mem imem
    (
        .address  (f_pc_out[9:2]),
        .data     (f_instr)
    );

    /* Program Counter. */
    register PC
    (
        .clock   (clock),
        .reset   (reset),
        .enable  (1'b1),
        .D       (f_pc_in),
        .Q       (f_pc_out)
    );

    /* PC := PC + 4 adder. */
    add pc_add4
    (
        .A  (f_pc_out),
        .B  (32'h00000004),
        .C  (f_pc_add4)
    );

    /* PC source multiplexer for branch & jump support. TODO: mocked for now. fix it */
    mux2 pc_src
    (
        .sel  (1'b0),
        .in0  (f_pc_add4),
        .in1  (mock_jmp_pc),
        .out  (f_pc_in)
    );

////////////////////////////////////////////////////////////////////////////////////////////////////

    /* A custom instruction set is used. */

    wire [31:0] d_instr;
    wire [31:0] d_pc;
    wire [6:0]  d_opcode     = d_instr[31:25];
    wire [5:0]  d_dst_reg    = d_instr[24:20];
    wire [5:0]  d_src_reg_1  = d_instr[19:15];
    wire [5:0]  d_src_reg_2  = d_instr[14:10];
    wire [14:0] d_mem_offset = d_instr[14:0];
    wire [14:0] d_brn_offset = {d_instr[24:20], d_instr[9:0]};
    wire [19:0] d_jmp_offset = {d_instr[24:20], d_instr[14:0]};

    f2d_flop f2d
    (
        .clock    (clock),
        .reset    (reset),
        .f_instr  (f_instr),
        .f_pc     (f_pc_out),
        .d_instr  (d_instr),
        .d_pc     (d_pc)
    );

////////////////////////////////////////////////////////////////////////////////////////////////////

endmodule
