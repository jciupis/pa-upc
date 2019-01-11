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
    wire [31:0] f_pc_in;      // Previous value of the PC.
    wire [31:0] f_pc_out;     // Current value of the PC.
    wire [31:0] f_pc_add4;    // Next value of the PC (no support for branches yet).
    wire [31:0] f_instr;      // Fetched instruction.
    wire        f_stall;
    wire        f_imem_stall; // Flag that indicates pipeline should stall while waiting for instruction cache to update.

    /* Decode stage variables. */
    wire [31:0] d_instr;
    wire [31:0] d_pc;
    wire [6:0]  d_opcode;
    wire [4:0]  d_dst_reg;
    wire [4:0]  d_src_reg_1;
    wire [4:0]  d_src_reg_2;
    wire [31:0] d_mem_offset;
    wire [31:0] d_brn_offset;
    wire [19:0] d_jmp_offset;
    wire [31:0] d_read_data_1;
    wire [31:0] d_read_data_2;
    wire        d_alu_imm_src;
    wire        d_mem_read;
    wire        d_mem_write;
    wire        d_mem_byte;
    wire        d_reg_write;
    wire        d_mem_to_reg;
    wire        d_stall;

    /* Execute stage variables. */
    wire [1:0]  x_pc_src;
    wire        x_srcs_equal;
    wire [31:0] x_brn_target_addr;
    wire [31:0] x_jmp_target_addr;
    wire [31:0] x_pc;
    wire [6:0]  x_opcode;
    wire [4:0]  x_dst_reg;
    wire [4:0]  x_src_reg_1;
    wire [4:0]  x_src_reg_2;
    wire [31:0] x_mem_offset;
    wire [31:0] x_brn_offset;
    wire [19:0] x_jmp_offset;
    wire [31:0] x_read_data_1;
    wire [31:0] x_read_data_2;
    wire [31:0] x_read_data_imm;
    wire [31:0] x_alu_result;
    wire        x_alu_imm_src;
    wire        x_mem_read;
    wire        x_mem_write;
    wire        x_mem_byte;
    wire        x_reg_write;
    wire        x_mem_to_reg;
    wire        x_stall;

    /* Memory stage variables. */
    wire  [4:0] m_dst_reg;
    wire        m_mem_read;
    wire        m_mem_write;
    wire        m_mem_byte;
    wire        m_reg_write;
    wire        m_mem_to_reg;
    wire [31:0] m_alu_result;
    wire [31:0] m_mem_read_data;
    wire [31:0] m_mem_write_data;
    wire        m_dmem_stall;
    wire        m_stall;

    /* Writeback stage variables. */
    wire  [4:0] w_dst_reg;
    wire        w_reg_write;
    wire        w_mem_to_reg;
    wire [31:0] w_alu_result;
    wire [31:0] w_mem_data;
    wire [31:0] w_write_data;
    wire        w_stall;

    /* Pipeline stall assignments. */
    assign w_stall = m_stall;
    assign m_stall = f_stall | m_dmem_stall;
    assign x_stall = m_stall;
    assign d_stall = m_stall;
    assign f_stall = f_imem_stall;

///////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////  FETCH  //////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

    /* Instruction memory interface. */
    instr_mem_ctrl imem
    (
        .clock  (clock),
        .reset  (reset),
        .address(f_pc_out),
        .data   (f_instr),
        .stall  (f_imem_stall)
    );

    /* Program Counter. */
    register PC
    (
        .clock   (clock),
        .reset   (reset),
        .enable  (~f_stall),
        .D       (f_pc_in),
        .Q       (f_pc_out)
    );

    /* Register file. */
    register_file registers
    (
        .clock          (clock),
        .reset          (reset),
        .reg_write      (w_reg_write),
        .reg_to_write   (w_dst_reg),
        .write_data     (w_write_data),
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

    /* PC source multiplexer for branch & jump support. */
    mux4 next_pc
    (
        .sel  (x_pc_src),
        .in0  (f_pc_add4),
        .in1  (x_brn_target_addr),
        .in2  (x_jmp_target_addr),
        .in3  (32'hxxxx_xxxx),
        .out  (f_pc_in)
    );

    /* Fetch to decode pipeline register. */
    fetch_to_decode f2d
    (
        .clock    (clock),
        .reset    (reset),
        .f_instr  (f_instr),
        .f_pc     (f_pc_out),
        .f_stall  (f_stall),
        .d_stall  (d_stall),
        .d_instr  (d_instr),
        .d_pc     (d_pc)
    );

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////  DECODE  //////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

    /* Decoding module. */
    decoder decoder
    (
        .instruction  (d_instr),
        .opcode       (d_opcode),
        .dst_reg      (d_dst_reg),
        .src_reg_1    (d_src_reg_1),
        .src_reg_2    (d_src_reg_2),
        .mem_offset   (d_mem_offset),
        .brn_offset   (d_brn_offset),
        .jmp_offset   (d_jmp_offset),
        .alu_imm_src  (d_alu_imm_src),
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
        .d_pc          (d_pc),
        .d_opcode      (d_opcode),
        .d_dst_reg     (d_dst_reg),
        .d_src_reg_1   (d_src_reg_1),
        .d_src_reg_2   (d_src_reg_2),
        .d_mem_offset  (d_mem_offset),
        .d_brn_offset  (d_brn_offset),
        .d_jmp_offset  (d_jmp_offset),
        .d_read_data_1 (d_read_data_1),
        .d_read_data_2 (d_read_data_2),
        .d_alu_imm_src (d_alu_imm_src),
        .d_mem_read    (d_mem_read),
        .d_mem_write   (d_mem_write),
        .d_mem_byte    (d_mem_byte),
        .d_reg_write   (d_reg_write),
        .d_mem_to_reg  (d_mem_to_reg),
        .d_stall       (d_stall),
        .x_stall       (x_stall),
        .x_pc          (x_pc),
        .x_opcode      (x_opcode),
        .x_dst_reg     (x_dst_reg),
        .x_src_reg_1   (x_src_reg_1),
        .x_src_reg_2   (x_src_reg_2),
        .x_mem_offset  (x_mem_offset),
        .x_brn_offset  (x_brn_offset),
        .x_jmp_offset  (x_jmp_offset),
        .x_read_data_1 (x_read_data_1),
        .x_read_data_2 (x_read_data_2),
        .x_alu_imm_src (x_alu_imm_src),
        .x_mem_read    (x_mem_read),
        .x_mem_write   (x_mem_write),
        .x_mem_byte    (x_mem_byte),
        .x_reg_write   (x_reg_write),
        .x_mem_to_reg  (x_mem_to_reg)
    );

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////  EXECUTE  /////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

    /* Compute ALU operand. */
    mux2 alu_operand_src
    (
        .sel(x_alu_imm_src),
        .in0(x_read_data_2),
        .in1(x_mem_offset),
        .out(x_read_data_imm)
    );

    /* Arithmetic logic unit. */
    alu alu
    (
        .opcode  (x_opcode),
        .A       (x_read_data_1),
        .B       (x_read_data_imm),
        .equal   (x_srcs_equal),
        .result  (x_alu_result)
    );

    /* Compute branch target address. TODO: Should A be equal to PC or PC + 4?*/
    add brn_addr
    (
        .A  (x_pc),
        .B  (x_brn_offset),
        .C  (x_brn_target_addr)
    );

    /* Compute jump target address. */
    assign x_jmp_target_addr = {x_pc[31:22], x_jmp_offset, 2'b00};

    /* Compute next PC source. */
    pc_src pc_src
    (
        .clock          (clock),
        .opcode         (x_opcode),
        .operands_equal (x_srcs_equal),
        .pc_src         (x_pc_src)
    );

    /* Execute to memory pipeline register. */
    execute_to_memory x2m
    (
        .clock             (clock),
        .reset             (reset),
        .x_dst_reg         (x_dst_reg),
        .x_mem_read        (x_mem_read),
        .x_mem_write       (x_mem_write),
        .x_mem_byte        (x_mem_byte),
        .x_reg_write       (x_reg_write),
        .x_mem_to_reg      (x_mem_to_reg),
        .x_mem_write_data  (x_read_data_2),
        .x_alu_result      (x_alu_result),
        .x_stall           (x_stall),
        .m_stall           (m_stall),
        .m_dst_reg         (m_dst_reg),
        .m_mem_read        (m_mem_read),
        .m_mem_write       (m_mem_write),
        .m_mem_byte        (m_mem_byte),
        .m_reg_write       (m_reg_write),
        .m_mem_to_reg      (m_mem_to_reg),
        .m_mem_write_data  (m_mem_write_data),
        .m_alu_result      (m_alu_result)
    );

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////  MEMORY  //////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

    /* Data memory controller. */
    data_mem_ctrl
    (
        .clock       (clock),
        .reset       (reset),
        .read        (m_mem_read),
        .write       (m_mem_write),
        .address     (m_alu_result),
        .write_data  (m_mem_write_data),
        .read_data   (m_mem_read_data),
        .stall       (m_dmem_stall)
    );

    /* Memory to writeback pipeline register. */
    memory_to_writeback m2w
    (
        .clock         (clock),
        .reset         (reset),
        .m_dst_reg     (m_dst_reg),
        .m_reg_write   (m_reg_write),
        .m_mem_to_reg  (m_mem_to_reg),
        .m_alu_result  (m_alu_result),
        .m_mem_data    (m_mem_read_data),
        .m_stall       (m_stall),
        .w_stall       (w_stall),
        .w_dst_reg     (w_dst_reg),
        .w_reg_write   (w_reg_write),
        .w_mem_to_reg  (w_mem_to_reg),
        .w_alu_result  (w_alu_result),
        .w_mem_data    (w_mem_data)
    );

////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////  WRITEBACK  /////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

    /* Compute data to be written back to register. */
    mux2 write_data_src
    (
        .sel  (w_mem_to_reg),
        .in0  (w_alu_result),
        .in1  (w_mem_data),
        .out  (w_write_data)
    );

////////////////////////////////////////////////////////////////////////////////////////////////////

endmodule
