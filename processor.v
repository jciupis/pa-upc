module processor
(
    input clock,
    input reset
);

`include "parameters.v"

    /* Declarations */
    wire [31:0] f_pc_in;     // Previous value of the PC.
    wire [31:0] f_pc_out;    // Current value of the PC.
    wire [31:0] f_pc_add4;   // Next value of the PC (no support for branches yet).
    wire [31:0] f_instr;     // Fetched instruction.
    wire [31:0] mock_jmp_pc; // TODO: a mocked signal to fill an empty input. Change it to sth meaningful

    wire [31:0] d_instr;
    wire [31:0] d_pc;
    wire [6:0]  d_opcode;
    wire [5:0]  d_dst_reg;
    wire [5:0]  d_src_reg_1;
    wire [5:0]  d_src_reg_2;
    wire [14:0] d_mem_offset;
    wire [14:0] d_brn_offset;
    wire [19:0] d_jmp_offset;
    wire [31:0] d_read_data_1;
    wire [31:0] d_read_data_2;

    wire [6:0]  x_opcode;
    wire [5:0]  x_dst_reg;
    wire [5:0]  x_src_reg_1;
    wire [5:0]  x_src_reg_2;
    wire [14:0] x_mem_offset;
    wire [14:0] x_brn_offset;
    wire [19:0] x_jmp_offset;
    wire [31:0] x_read_data_1;
    wire [31:0] x_read_data_2;
    wire [31:0] x_alu_result;

///////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////  FETCH  //////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

    /* There is no support for branch & jump instructions yet. */
    /* There is also no support for exceptions and other more complex stuff. */

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

    /* Register file. */
    register_file registers
    (
        .clock          (clock),
        .reset          (reset),
        .reg_write      (),
        .reg_to_write   (),
        .write_data     (),
        .reg_to_read_1  (d_src_reg_1),
        .reg_to_read_2  (d_src_reg_2),
        .read_data_1    (d_read_data_1),
        .read_data_2    (d_read_data_2)
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

    /* Fetch to decode pipeline register. */
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
////////////////////////////////////////////  DECODE  //////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

    /* A custom instruction set is used. */
    assign d_opcode     = d_instr[31:25];
    assign d_dst_reg    = d_instr[24:20];
    assign d_src_reg_1  = d_instr[19:15];
    assign d_src_reg_2  = d_instr[14:10];
    assign d_mem_offset = d_instr[14:0];
    assign d_brn_offset = {d_instr[24:20], d_instr[9:0]};
    assign d_jmp_offset = {d_instr[24:20], d_instr[14:0]};

    /* Decode to execute pipeline register. */
    d2x_flop d2x
    (
        .clock         (clock),
        .reset         (reset),
        .d_opcode      (d_opcode),
        .d_dst_reg     (d_dst_reg),
        .d_src_reg_1   (d_src_reg_1),
        .d_src_reg_2   (d_src_reg_2),
        .d_mem_offset  (d_mem_offset),
        .d_brn_offset  (d_brn_offset),
        .d_jmp_offset  (d_jmp_offset),
        .d_read_data_1 (d_read_data_1),
        .d_read_data_2 (d_read_data_1),
        .x_opcode      (x_opcode),
        .x_dst_reg     (x_dst_reg),
        .x_src_reg_1   (x_src_reg_1),
        .x_src_reg_2   (x_src_reg_2),
        .x_mem_offset  (x_mem_offset),
        .x_brn_offset  (x_brn_offset),
        .x_jmp_offset  (x_jmp_offset),
        .x_read_data_1 (x_read_data_1),
        .x_read_data_2 (x_read_data_2)
    );

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////  EXECUTE  /////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

    /* Arithmetic logic unit */
    alu alu
    (
        .clock(clock),
        .opcode(x_opcode),
        .A(x_read_data_1),
        .B(x_read_data_2),
        .result(x_alu_result)
    );

////////////////////////////////////////////////////////////////////////////////////////////////////

endmodule
