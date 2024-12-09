`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/08 15:24:27
// Design Name: 
// Module Name: offset_sel
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

//跳转地址的计算
module offset_sel (
    input clk,
    input [31:0] jmp,
    input [31:0] addr,
    input [31:0] imme,
    input [31:0] data1,
    input [1:0] sel,  //op[3:2]
    output reg [31:0] offset
);

  always @(negedge clk)
    case (sel)
      2'b11:   offset <= addr + (jmp << 1);  //jal指令
      2'b01:   offset <= imme + data1;  //jalr指令
      2'b00:   offset <= addr + (imme << 1);  //B_type指令
      default: offset <= 32'd0;
    endcase

endmodule
