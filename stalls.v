module stall_ctrl
(
    input clock,
    input f_imem_stall,
    input hz_f_stall,
    input hz_d_stall,
    input hz_x_stall,
    input [1:0] x_pc_src,
    input m_dmem_stall,
    output f_flush,
    output f_stall,
    output d_flush,
    output d_stall,
    output x_stall,
    output m_stall,
    output w_stall
);

    // Deal with branch control.
    wire branch_taken = x_pc_src[1] ^ x_pc_src[0];

    assign f_flush = branch_taken && ~f_stall;
    assign d_flush = branch_taken && ~d_stall;

    assign w_stall = m_stall;
    assign m_stall = (f_stall & ~hz_f_stall) | (m_dmem_stall & (m_dmem_stall !== 1'bx));
    assign x_stall = m_stall | hz_x_stall | (f_stall & (x_pc_src != 2'b00));
    assign d_stall = x_stall | hz_d_stall;
    assign f_stall = f_imem_stall | (m_dmem_stall & (m_dmem_stall !== 1'bx)) | hz_f_stall;

endmodule