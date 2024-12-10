`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/04 23:29:17
// Design Name: 
// Module Name: instr_register
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

//指令存储器，取值用
module instr_register (
    input [31:0] addr,
    output reg [31:0] instr
);
  reg [7:0] instr_mem[255:0];
  initial $readmemb("/tmp/risc_v2.txt", instr_mem);  //我指令文件的地址
  always @(*) begin
    instr[7:0]   = instr_mem[addr+3];
    instr[15:8]  = instr_mem[addr+2];
    instr[23:16] = instr_mem[addr+1];
    instr[31:24] = instr_mem[addr];
  end

endmodule
