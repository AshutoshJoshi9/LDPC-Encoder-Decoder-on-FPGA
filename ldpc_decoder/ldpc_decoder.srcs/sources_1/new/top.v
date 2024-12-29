`timescale 1ns / 1ps


module top(
input clk,
input reset,
input [6:0] received, // received codeword
output reg [3:0] decoded, // decoded message from codeword
output reg valid          // flag for successful decoding
    );
    
    // H matrix for (7, 4) code
    reg [6:0] H [0:2]; // 3x7 matrix
    
    // syndrome
    reg [2:0] syndrome;
    reg [6:0] corrected;
    
    // error pattern for correction by xor
    reg [6:0] error_pattern [0:7];
    
    integer i;
    integer j;
    integer a [2:0]; // for getting the index in H matrix of the error bit
    integer error_index;
    
    initial begin
    
        // initializing the H matrix
        H[0] = 7'b1110100;
        H[1] = 7'b1101010;
        H[2] = 7'b1011001;
        
        // initializing error patterns 
        error_pattern[0] = 7'b0000000; // no error
        error_pattern[1] = 7'b0000001; // error in bit 0
        error_pattern[2] = 7'b0000010; // error in bit 1
        error_pattern[3] = 7'b0000100; // error in bit 2
        error_pattern[4] = 7'b0001000; // error in bit 3
        error_pattern[5] = 7'b0010000; // error in bit 4
        error_pattern[6] = 7'b0100000; // error in bit 5
        error_pattern[7] = 7'b1000000; // error in bit 6
        
    end
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            decoded <= 4'b0;
            valid <= 0;
            corrected <= 7'b0;
            syndrome <= 3'b0;
            a[0] <= 0;
            a[1] <= 0;
            a[2] <= 0;
        end else begin
            syndrome = 3'b000;
            for (i=0; i<3; i=i+1) begin
                syndrome[i] = ^(received & H[i]);
            end
            
            // error correction
            if (syndrome != 3'b000) begin
                for (j=0; j<7; j=j+1) begin
                    for (i=0; i<3; i=i+1) begin
                        a[i] = H[i][j] ^ syndrome[i];
                    end
                    if ((a[0] ^ a[1] ^ a[2]) == 0 ) begin
                        error_index <= j;
                    end
                end
                corrected = received ^ error_pattern[7 - error_index + 1];
            end else begin
                corrected = received;
            end
            decoded = corrected[6:0];      // to extract the original message
            valid = ~(syndrome == 3'b000); // flag to check if the received code had any error
        end
    end 
    
endmodule

//module top(
//    input clk,
//    input reset,
//    input [6:0] received, // received codeword
//    output reg [2:0] syndro,
//    output reg [3:0] decoded, // decoded message from codeword
//    output reg valid          // flag for successful decoding
//);

//    // H matrix for (7, 4) code
//    reg [6:0] H [0:2]; // 3x7 matrix
    
//    // syndrome
//    reg [2:0] syndrome;
//    reg [6:0] corrected;
    
//    // error pattern for correction by xor
//    reg [6:0] error_pattern [0:7];
    
//    integer i;
//    integer j;
//    integer error_index;

//    initial begin
//        // initializing the H matrix
//        H[0] = 7'b1110100;
//        H[1] = 7'b1101010;
//        H[2] = 7'b1011001;
        
//        // initializing error patterns 
//        error_pattern[0] = 7'b0000000; // no error
//        error_pattern[1] = 7'b0000001; // error in bit 0
//        error_pattern[2] = 7'b0000010; // error in bit 1
//        error_pattern[3] = 7'b0000100; // error in bit 2
//        error_pattern[4] = 7'b0001000; // error in bit 3
//        error_pattern[5] = 7'b0010000; // error in bit 4
//        error_pattern[6] = 7'b0100000; // error in bit 5
//        error_pattern[7] = 7'b1000000; // error in bit 6
//    end

//    always @(posedge clk or posedge reset) begin
//        if (reset) begin
//            decoded <= 4'b0;
//            valid <= 0;
//            corrected <= 7'b0;
//            syndrome <= 3'b0;
//            syndro <= 3'b0;
//            error_index <= 0;
//        end else begin
//            // Calculate syndrome
//            syndrome = 3'b000;
//            for (i = 0; i < 3; i = i + 1) begin
//                syndrome[i] = ^(received & H[i]);
//                syndro[i] = ^(received & H[i]);
//            end
            
//            // Check for errors
//            if (syndrome != 3'b000) begin
//                // Determine error index
//                error_index = 0;
//                for (j = 0; j < 7; j = j + 1) begin
//                    if (syndrome == {H[0][j], H[1][j], H[2][j]}) begin
//                        error_index = j;
//                    end
//                end
//                corrected = received ^ error_pattern[error_index + 1];
//            end else begin
//                corrected = received;
//            end

//            // Extract the original message (assuming data bits are in the higher 4 bits)
//            decoded <= corrected[6:3];
//            valid <= (syndrome == 3'b000);
//        end
//    end
//endmodule

