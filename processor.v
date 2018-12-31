module processor
(
    input clock,
    input reset
);

`include "parameters.v"

///////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////  DECLARATIONS  ///////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

    /* Fetch stage variables. */
    wire [31:0] f_pc_in;     // Previous value of the PC.
    wire [31:0] f_pc_out;    // Current value of the PC.
    wire [31:0] f_pc_add4;   // Next value of the PC (no support for branches yet).
    wire [31:0] f_instr;     // Fetched instruction.
    wire [31:0] mock_jmp_pc; // TODO: a mocked signal to fill an empty input. Change it to sth meaningful

    /* Decode stage variables. */
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
    wire        d_mem_read;
    wire        d_mem_write;
    wire        d_mem_byte;
    wire        d_reg_write;
    wire        d_mem_to_reg;

    /* Execute stage variables. */
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
    wire        x_mem_read;
    wire        x_mem_write;
    wire        x_mem_byte;
    wire        x_reg_write;
    wire        x_mem_to_reg;

    /* Memory stage variables. */
    wire        m_mem_read;
    wire        m_mem_write;
    wire        m_mem_byte;
    wire        m_reg_write;
    wire        m_mem_to_reg;
    wire [31:0] m_alu_result;

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

    /* Register file. TODO: fill the write signals. */
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
    fetch_to_decode f2d
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

    /* Decoding module. */
    decoder decoder
    (
        .clock        (clock),
        .instruction  (d_instr),
        .opcode       (d_opcode),
        .dst_reg      (d_dst_reg),
        .src_reg_1    (d_src_reg_1),
        .src_reg_2    (d_src_reg_2),
        .mem_offset   (d_mem_offset),
        .brn_offset   (d_brn_offset),
        .jmp_offset   (d_jmp_offset),
        .mem_read     (d_mem_read),
        .mem_write    (d_mem_write),
        .mem_byte     (d_mem_byte),
        .reg_write    (d_reg_write),
        .mem_to_reg   (d_mem_to_reg)
    );

    /* Decode to execute pipeline register. */
    decode_to_execute d2x
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
        .d_mem_read    (d_mem_read),
        .d_mem_write   (d_mem_write),
        .d_mem_byte    (d_mem_byte),
        .d_reg_write   (d_reg_write),
        .d_mem_to_reg  (d_mem_to_reg),
        .x_opcode      (x_opcode),
        .x_dst_reg     (x_dst_reg),
        .x_src_reg_1   (x_src_reg_1),
        .x_src_reg_2   (x_src_reg_2),
        .x_mem_offset  (x_mem_offset),
        .x_brn_offset  (x_brn_offset),
        .x_jmp_offset  (x_jmp_offset),
        .x_read_data_1 (x_read_data_1),
        .x_read_data_2 (x_read_data_2),
        .x_mem_read    (x_mem_read),
        .x_mem_write   (x_mem_write),
        .x_mem_byte    (x_mem_byte),
        .x_reg_write   (x_reg_write),
        .x_mem_to_reg  (x_mem_to_reg)
    );

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////  EXECUTE  /////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

    /* Arithmetic logic unit. */
    alu alu
    (
        .clock   (clock),
        .opcode  (x_opcode),
        .A       (x_read_data_1),
        .B       (x_read_data_2),
        .result  (x_alu_result)
    );

    /* Execute to memory pipeline register. */
    execute_to_memory x2m
    (
        .clock         (clock),
        .reset         (reset),
        .x_mem_read    (x_mem_read),
        .x_mem_write   (x_mem_write),
        .x_mem_byte    (x_mem_byte),
        .x_reg_write   (x_reg_write),
        .x_mem_to_reg  (x_mem_to_reg),
        .x_alu_result  (x_alu_result),
        .m_mem_read    (m_mem_read),
        .m_mem_write   (m_mem_write),
        .m_mem_byte    (m_mem_byte),
        .m_reg_write   (m_reg_write),
        .m_mem_to_reg  (m_mem_to_reg),
        .m_alu_result  (m_alu_result)
    );

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////  MEMORY  //////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

    /* Data memory interface. */
    data_mem dmem
    (
        .clock  (clock)
    );

////////////////////////////////////////////////////////////////////////////////////////////////////

endmodule
