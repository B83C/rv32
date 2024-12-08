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


module wr_addr(
     input clk,
     input ext_imme,
     input [31:0] data1,
     output reg [31:0] wr_addr
    );
    always @(negedge clk) 
    begin
    wr_addr <= ext_imme + data1;
    end
endmodule
