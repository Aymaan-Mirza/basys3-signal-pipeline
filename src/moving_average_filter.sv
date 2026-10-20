`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2026 07:22:11 PM
// Design Name: 
// Module Name: moving_average_filter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module moving_average_filter(

    input logic clk, //clock
    input logic reset,//resets circuit
    input logic [7:0] inp_sample,//8-bit input number
    input logic valid,//tells us if the input is real or valid
    output logic [7:0] sample_out,//outputs filtered 8-bit number
    output logic outp_valid//tells next block that output is real
);
    
    logic [7:0] sample0;
    logic [7:0] sample1;
    logic [7:0] sample2;
    //The above are internal signals, remembering old samples
    
    logic [9:0] nextsum; //stores sum of 4 8 bit numbers, 10 bits are needed as 8 bits being added would overflow
    
    //Combination logic calculates this immediately
    always_comb begin
        nextsum = inp_sample + sample0 + sample1 + sample2;
    end
    
    always_ff@(posedge clk) begin //only update these on rising edge of clock
        if (reset) begin
            sample0 <= 8'd0;
            sample1 <= 8'd0;
            sample2 <= 8'd0;
            sample_out <= 8'd0;
            outp_valid <= 1'b0;
        end else begin
            if (valid) begin
                sample2 <= sample1;
                sample1 <= sample0;
                sample0 <= inp_sample;
                
                sample_out <= nextsum[9:2];
                outp_valid <=1'b1;
            end else begin
                outp_valid <= 1'b0;
            end
        end
    end
    
    
    
endmodule
