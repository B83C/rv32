`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/08 17:10:13
// Design Name: 
// Module Name: wr_addr
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

//µÿ÷∑º∆À„
module wr_addr (
    input clk,
    input [31:0] imme,
    input [31:0] data1,
    output reg [31:0] wr_addr
);
  always @(negedge clk) begin
    wr_addr <= imme + data1;
  end
endmodule
