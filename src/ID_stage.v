`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/05 23:39:30
// Design Name: 
// Module Name: ID_stage
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


module ID_stage(
     input clk,
     input rst_n,
     input w_en_I,//输入写使能信号
     input [31:0] wr_reg_data_ID_I,
     input [31:0] instr_ID_I,
     output [6:0] opcode_ID_O,
     output [2:0] func3_ID_O,
     output func_ID_O,
     output [31:0] imme_ID_O,
     output [31:0] Rd_data1_ID_O,
     output [31:0] Rd_data2_ID_O
    );
    
    wire [4:0] Rs1;
    wire [4:0] Rs2;
    wire [4:0] Rd;
    
    decoding U1(.instr(instr_ID_I),.opcode(opcode_ID_O),.func3(func3_ID_O),.func(func_ID_O),.Rs1(Rs1),.Rs2(Rs2),.Rd(Rd),.imme(imme_ID_O));
    
    register U2(.clk(clk),.rst_n(rst_n),.w_en(w_en_I),.Rs1(Rs1),.Rs2(Rs2),.Rd(Rd),.w_data(wr_reg_data_ID_I),.Rd_data1(Rd_data1_ID_O),.Rd_data2(Rd_data2_ID_O));
    
endmodule
