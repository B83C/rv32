`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/08 17:13:34
// Design Name: 
// Module Name: temporary
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

//temporary ¼Ä´æÆ÷£¬ÔÝÊ±´æ´¢Êä³öÊý¾Ý
module temporary #(
    parameter N = 32
) (
    input clk,
    input [N-1:0] data,
    output reg [N-1:0] data_d
);

  always @(negedge clk) data_d <= data;

endmodule
