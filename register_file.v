module register_file
(
    input  clock,                                // Clock.
    input  reset,                                // Command to reset all registers.
    input  reg_write,                            // Command to write to register.
    input  [4:0] reg_to_write,                   // Index of register to write.
    input  [31:0] write_data,                    // Data to write.
    input  [4:0]  reg_to_read_1, reg_to_read_2,  // Indices of registers to read.
    output [31:0] read_data_1, read_data_2       // Read register data.
);

    // Register file of 32 32-bit registers. Register 0 is hardwired to 0.
    reg [31:0] registers [1:31];

    // Initialize all registers to zero.
    integer i;
    initial begin
        for (i = 1; i < 32; i = i + 1) begin
            registers[i] <= 0;
        end
    end

    // Sequential write.
    always @(posedge clock) begin
        if (reset) begin
            for (i = 1; i < 32; i = i + 1) begin
                registers[i] <= 0;
            end
        end
        else begin
            if (reg_to_write != 0)
                registers[reg_to_write] <= (reg_write) ? write_data : registers[reg_to_write];
        end
    end

    // Combinatorial Read.
    assign read_data_1 = (reg_to_read_1 == 0) ? 32'h00000000 : registers[reg_to_read_1];
    assign read_data_2 = (reg_to_read_2 == 0) ? 32'h00000000 : registers[reg_to_read_2];

endmodule
