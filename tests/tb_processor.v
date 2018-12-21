module tb_processor();

    reg clock = 1'b0;
    
    initial begin
        while(1) begin
            #1; clock = 1'b1;
            #1; clock = 1'b0;
        end
    end
    
    processor DUT
    (
        .clock  (clock),
        .reset  (1'b0)
    );

endmodule