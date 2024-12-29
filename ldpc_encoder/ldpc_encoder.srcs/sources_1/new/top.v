`timescale 1ns / 1ps



module top(
input clk,
input reset,
input [3:0] message,
output reg [6:0] encoded
    );
    
    // Generator matrix G
    reg [6:0] G [0:3];
    reg [6:0] codeword;
    reg [6:0] a;
    integer i, j;
    
    initial begin
        
        //initialize G, it is 4x7 matrix
        G[0] = 7'b1000111;
        G[1] = 7'b0100110;
        G[2] = 7'b0010101;
        G[3] = 7'b0001011;
        
    end
    
    always @(posedge clk or posedge reset) begin
    
        if (reset) begin
            encoded <= 7'b0;
            a <= 7'b0;
        end else begin
            a = 7'b0;
            for (i=6; i>=0; i=i-1) begin
                for (j=0; j<4; j=j+1) begin
                    a[i] = a[i] + (message[4-j-1] * G[j][i]);
                end
                if ((a[i] % 2) == 0) begin
                    a[i] = 0;
                end else begin
                    a[i] = 1;
                end
                codeword[i] = a[i];
            end
            encoded <= codeword;
        end
        
    end
endmodule
