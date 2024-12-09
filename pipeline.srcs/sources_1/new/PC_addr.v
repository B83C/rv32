`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/04 23:21:21
// Design Name: 
// Module Name: PC_addr
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

//PCµÿ÷∑
module PC_addr (
    input clk,
    input rst_n,
    input cancel,
    input [31:0] offset,
    output reg [31:0] pc_out
);
  initial pc_out = 32'b0;
  always @(negedge clk or negedge rst_n) begin
    if (~rst_n) pc_out <= 32'b0;
    else if (cancel) pc_out <= offset;
    else pc_out <= pc_out + 32'd4;
  end
endmodule
