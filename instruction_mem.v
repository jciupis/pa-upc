module instruction_mem
(
    input  [7:0]  address,  // Address to read next instruction from.
    output [31:0] data      // Returned instruction.
);

    reg [31:0] instruction_mem [255:0];
    
    initial begin
        $readmemh("instructions.txt", instruction_mem);
    end
    
    assign data = instruction_mem[address];

endmodule
