`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/06 00:05:40
// Design Name: 
// Module Name: ID_EX_reg
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


module ID_EX_reg(
    input clk,
    input rst_n,
    input [31:0] pc_ID_EX_I,
    input [31:0] imme_ID_EX_I,
    input [31:0] Rd_data1_ID_EX_I,
    input [31:0] Rd_data2_ID_EX_I,
    output reg [31:0] pc_ID_EX_O,
    output reg [31:0] imme_ID_EX_O,
    output reg [31:0] Rd_data1_ID_EX_O,
    output reg [31:0] Rd_data2_ID_EX_O
    );
    always @(posedge clk or negedge rst_n)
       begin
       if(~rst_n) 
       pc_ID_EX_O<=32'b0;
       else 
       pc_ID_EX_O<=pc_ID_EX_I;
       end
       
       always @(posedge clk or negedge rst_n)
       begin
       if(~rst_n)
       imme_ID_EX_O<=32'b0;
       else 
       imme_ID_EX_O<=imme_ID_EX_I;
       end
       
       always @(posedge clk or negedge rst_n)
       begin
       if(~rst_n)
       Rd_data1_ID_EX_O<=32'b0;
       else 
       Rd_data1_ID_EX_O<=Rd_data1_ID_EX_I;
       end
       
       always @(posedge clk or negedge rst_n)
       begin
       if(~rst_n)
       Rd_data2_ID_EX_O<=32'b0;
       else 
       Rd_data2_ID_EX_O<=Rd_data2_ID_EX_I;
       end
       
endmodule
