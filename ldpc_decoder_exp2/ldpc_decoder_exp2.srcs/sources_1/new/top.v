`timescale 1ns / 1ps


module top(
input clk,
input reset,
input [6:0] received, // received code word
output reg valid,     // flag to tell if received codeword is valid
output reg [3:0] decoded  // decoded message form given codeword
    );
    
    // H matrix for (7,4) code, it is a 3x7 matrix
    reg [6:0] H [0:2];
    reg [6:0] corrected; //variable used to correct codeword if its invalid
    reg [2:0] syndrome;  // Syndrome for error detection and correction
    
    reg [6:0] error_pattern [0:7]; // error pattern for error correction
    
    integer i, j;
    integer a [2:0]; // for index calculation of error bit
    integer error_index; // index of error bit
    
    
    initial begin
        
        // initializing H matrix
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
        
        if(reset) begin
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
                syndrome[i] = ^(H[i] & received);
            end
            
            // error correction
            if (syndrome != 3'b000) begin
                for (j=6; j>=0; j=j-1) begin
                    for (i=0; i<3; i=i+1) begin
                        a[i] = syndrome[i] ^ H[i][j];
                    end
                    if (((a[0]==0)&(a[1]==0)&(a[2]==0)) == 1) begin
                        error_index <= j;
                    end
                end
                corrected = received ^ error_pattern[j+1];
            end else begin
                corrected = received;
            end
            decoded <= corrected[6:3];
            valid <= (syndrome == 3'b000);
        end 
    end 
endmodule
