module hazard_detection
(
    input clock,
    
    input [4:0] d_src_reg_1,     // Decode stage first source register index
    input [4:0] d_src_reg_2,     // Decode stage second source register index
    input [4:0] x_src_reg_1,     // Execute stage first source register index
    input [4:0] x_src_reg_2,     // Execute stage second source register index
    input [4:0] x_dst_reg,       // Execute stage destination register index
    input       x_alu_ready,     // Flag if that is set when the ALU has finished op
    input [4:0] m_dst_reg,       // Memory stage destination register index
    input [4:0] w_dst_reg,       // Writeback stage destination register index
    input       d_reg_write,     // Flag indicating Decode operation will write to a register
    input       x_reg_write,     // Flag indicating Execute operation will write to a register
    input       m_reg_write,     // Flag indicating Memory operation will write to a register
    input       w_reg_write,     // Flag indicating Writeback operation will write to a register
    input [1:0] pc_src,          // The PC source selector, useful to detect control hazards
    output      f_stall,         // Flag indicating if Fetch stage should stall
    output      f_flush,         // Flag indicating if Fetch stage should be flushed
    output      d_stall,         // Flag indicating if Decode stage should stall
    output      d_flush,         // Flag indicating if Decode stage should be flushed
    output      x_stall,         // Flag indicating if Execute stage should stall
    output      m_stall,         // Flag indicating if Memory stage should stall
    output      w_stall,         // Flag indicating if Writeback stage should stall
    output      jump_haz         // Flag to indicate jump/branch taken instruction so that pipeline flushes
    //output      fwd
);

    // Detect presence of zero register as destination, so no forwarding occurs
    wire x_dst_nzero = (x_dst_reg     != 5'b00000);
    wire m_dst_nzero = (m_dst_reg     != 5'b00000);
    wire w_dst_nzero = (w_dst_reg     != 5'b00000);

    // Detect potential hazards/forwards
    wire d_x_haz = ((d_src_reg_1 == x_dst_reg) | (d_src_reg_2 == x_dst_reg))  & x_dst_nzero & x_reg_write;
    wire d_m_haz = ((d_src_reg_1 == m_dst_reg) | (d_src_reg_2 == m_dst_reg))  & m_dst_nzero & m_reg_write;
    wire d_w_haz = ((d_src_reg_1 == w_dst_reg) | (d_src_reg_2 == w_dst_reg))  & w_dst_nzero & w_reg_write;

    wire x_m_haz = ((x_src_reg_1 == m_dst_reg) | (x_src_reg_2 == m_dst_reg)  
                   | (x_dst_reg == m_dst_reg)) & m_dst_nzero & m_reg_write;
    // Careful with these 2; include extra check of the operand being src/dst?
    wire x_w_haz = ((x_src_reg_1 == w_dst_reg) | (x_dst_reg == w_dst_reg))  & w_dst_nzero & m_reg_write;
    
    //No hazard in WB stage
    //wire m_w_haz =  (m_dst_reg   == w_dst_reg)                                  & w_dst_nzero & w_reg_write;

    // In case of d_x_haz or x_m_haz, forward from execute_to_memory pipeline reg
    

    // In case of d_m_haz or x_w_haz, forward from memory_to_writeback pipeline reg


    assign x_stall = (x_m_haz & (x_m_haz !== 1'bx)) | x_w_haz & (x_w_haz !== 1'bx)
                     | (~x_alu_ready & (x_reg_write & (x_reg_write !== 1'bx)));
    assign d_stall = (d_x_haz & (d_x_haz !== 1'bx)) | (d_m_haz & (d_m_haz !== 1'bx)) | x_stall;
    assign f_stall =  d_stall;

    assign jump_haz = pc_src[1] ^ pc_src[0];
    assign f_flush = jump_haz;
    assign d_flush = jump_haz;
//    always @(posedge clock) begin

endmodule
