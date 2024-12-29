`timescale 1ns / 1ps


module tb_ldpc_decoder;

    // Inputs
    reg clk;
    reg reset;
    reg [6:0] received;

    // Outputs
    wire [3:0] decoded;
    wire valid;

    // Instantiate the Unit Under Test (UUT)
    top uut (
        .clk(clk), 
        .reset(reset), 
        .received(received), 
        .decoded(decoded), 
        .valid(valid)
    );

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 0;
        received = 7'b0000000;

        // Apply reset
        reset = 1;
        #10;
        reset = 0;
        #10;
        
        // Test case 1: No error
        received = 7'b1011001; // Assume this is a valid codeword without error
        #30;
        
        // Check results
        if (valid == 1 && decoded == 4'b0101) // Assuming 0101 is the correct decoded message for 1011001
            $display("Test case 1 passed.");
        else
            $display("Test case 1 failed.");

        // Test case 2: Single bit error in bit 0
        received = 7'b1011000; // Assume single bit error in LSB
        #30;

        // Check results
        if (valid == 0 && decoded == 4'b0101) // Assuming 0101 is the correct decoded message for corrected codeword
            $display("Test case 2 passed.");
        else
            $display("Test case 2 failed.");

        // Test case 3: Single bit error in bit 4
        received = 7'b1010001; // Assume single bit error in bit 4
        #30;

        // Check results
        if (valid == 0 && decoded == 4'b0101) // Assuming 0101 is the correct decoded message for corrected codeword
            $display("Test case 3 passed.");
        else
            $display("Test case 3 failed.");

        // Test case 4: Multiple errors (uncorrectable)
        received = 7'b1111000; // Multiple errors
        #30;

        // Check results
        if (valid == 1) // It should indicate an error
            $display("Test case 4 passed.");
        else
            $display("Test case 4 failed.");

        $stop;
    end

    // Clock generation
    always #5 clk = ~clk;

endmodule
