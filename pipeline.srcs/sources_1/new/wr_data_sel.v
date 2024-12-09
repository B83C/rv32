`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/08 18:19:28
// Design Name: 
// Module Name: wr_data_sel
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

//�洢������ѡ������ALU�������洢���Ķ�ȡ������
module wr_data_sel (
    input clk,
    input [31:0] data_out,
    input [31:0] addr,
    input sel,  //opcode[6]
    output reg [31:0] wr_data
);

  always @(negedge clk) begin
    wr_data <= sel ? addr : data_out;
  end

endmodule
