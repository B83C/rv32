`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/03 15:19:43
// Design Name: 
// Module Name: decoding
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
//译码模块
`include "define.sv"
module decoding (
    input  [31:0] instr,
    output [ 6:0] opcode,
    output [ 2:0] func3,
    output [ 6:0] func7,
    output [ 4:0] Rs1,
    output [ 4:0] Rs2,
    output [ 4:0] Rd,
    output [31:0] jmp,
    output [31:0] imme
);
  wire I_type;  //I_type指令
  wire U_type;  //U_type
  wire J_type;
  wire B_type;
  wire S_type;

  wire [31:0] I_imme;  //I立即数扩展
  wire [31:0] U_imme;
  wire [31:0] J_imme;
  wire [31:0] B_imme;
  wire [31:0] S_imme;

  assign opcode = instr[6:0];  //操作码
  assign func3 = instr[14:12];  //三位功能码
  assign func7 = instr[31:25];  //七位功能码，取第二位
  assign Rs1 = instr[19:15];  //源寄存器Rs1
  assign Rs2 = instr[24:20];  //源寄存器Rs2
  assign Rd = instr[11:7];  //写入寄存器Rd

  assign I_type = (opcode == `jalr | opcode == `load | opcode == `I_type);  //I类型指令，包括这三种
  assign U_type = (opcode == `lui | opcode == `auipc);  //U类型指令，包括这两种
  assign J_type = (opcode == `jal);  //J类型指令
  assign B_type = (opcode == `B_type);  //B类型指令
  assign S_type = (opcode == `store);  //S类型指令

  assign I_imme = {{20{instr[31]}}, instr[31:20]};  //I立即数扩展
  assign U_imme = {instr[31:12], 12'b0};  //U立即数扩展
  assign J_imme = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};  //J立即数扩展
  assign B_imme = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};  //B立即数扩展
  assign S_imme = {{20{instr[31]}}, instr[31:25], instr[11:7]};  //S立即数扩展

  assign imme=I_type?I_imme:U_type?U_imme:J_type?J_imme:B_type?B_imme:S_type?S_imme:32'b0;//立即数输出
  assign jmp = {
    {12{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21]
  };  //jal立即数扩展输出
endmodule
