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
//����ģ��
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
  wire I_type;  //I_typeָ��
  wire U_type;  //U_type
  wire J_type;
  wire B_type;
  wire S_type;

  wire [31:0] I_imme;  //I��������չ
  wire [31:0] U_imme;
  wire [31:0] J_imme;
  wire [31:0] B_imme;
  wire [31:0] S_imme;

  assign opcode = instr[6:0];  //������
  assign func3 = instr[14:12];  //��λ������
  assign func7 = instr[31:25];  //��λ�����룬ȡ�ڶ�λ
  assign Rs1 = instr[19:15];  //Դ�Ĵ���Rs1
  assign Rs2 = instr[24:20];  //Դ�Ĵ���Rs2
  assign Rd = instr[11:7];  //д��Ĵ���Rd

  assign I_type = (opcode == `jalr | opcode == `load | opcode == `I_type);  //I����ָ�����������
  assign U_type = (opcode == `lui | opcode == `auipc);  //U����ָ�����������
  assign J_type = (opcode == `jal);  //J����ָ��
  assign B_type = (opcode == `B_type);  //B����ָ��
  assign S_type = (opcode == `store);  //S����ָ��

  assign I_imme = {{20{instr[31]}}, instr[31:20]};  //I��������չ
  assign U_imme = {instr[31:12], 12'b0};  //U��������չ
  assign J_imme = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};  //J��������չ
  assign B_imme = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};  //B��������չ
  assign S_imme = {{20{instr[31]}}, instr[31:25], instr[11:7]};  //S��������չ

  assign imme=I_type?I_imme:U_type?U_imme:J_type?J_imme:B_type?B_imme:S_type?S_imme:32'b0;//���������
  assign jmp = {
    {12{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21]
  };  //jal��������չ���
endmodule
