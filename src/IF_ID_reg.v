`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/05 23:33:18
// Design Name: 
// Module Name: IF_ID_reg
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


module IF_ID_reg(
     input clk,
     input rst_n,
     input [31:0] pc_IF_ID_I,
     input [31:0] instr_IF_ID_I,
     output reg [31:0] pc_IF_ID_O,
     output reg [31:0] instr_IF_ID_O
     );
     
     always @(posedge clk or negedge rst_n)
     begin
     if(~rst_n) pc_IF_ID_O<=32'b0;
     else pc_IF_ID_O<=pc_IF_ID_I;
     end
     
     always @(posedge clk or negedge rst_n)
     begin
     if(~rst_n) instr_IF_ID_O<=32'b0;
     else instr_IF_ID_O<=instr_IF_ID_I;
     end
     
endmodule
