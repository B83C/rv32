`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/03 16:40:32
// Design Name: 
// Module Name: register
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

`include"define.v"
module register(
      input clk,
      input rst_n,
      input w_en,
      input [4:0] Rs1,
      input [4:0] Rs2,
      input [4:0] Rd,
      input [31:0] w_data,
      output [31:0] Rd_data1,
      output [31:0] Rd_data2
    );
    reg [31:0] regs[31:0];
    
    always @(posedge clk or negedge rst_n)
        begin
        if(~rst_n)
        regs[Rd]<=0;
        else if(w_en&(Rd!=0))
        regs[Rd] <=w_data;
        else regs[Rd]<=regs[Rd];
        end
    
    assign Rd_data1=(Rs1==5'd0)?`zero_word:regs[Rs1];
    assign Rd_data2=(Rs2==5'd0)?`zero_word:regs[Rs2];
endmodule
