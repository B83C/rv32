`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/06 11:55:22
// Design Name: 
// Module Name: EX_MEM_reg
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


module EX_MEM_reg(
    input clk,
	input rst_n,
	input [31:0] ALU_result_EX_MEM_I,
	input [31:0] pc_jump_EX_MEM_I,
	input [31:0] Rd_data2_EX_MEM_I,
	input [31:0] imme_EX_MEM_I,
	input [31:0] pc_order_EX_MEM_I,
	output reg [31:0] ALU_result_EX_MEM_O,   
	output reg [31:0] pc_jump_EX_MEM_O,
	output reg [31:0] Rd_data2_EX_MEM_O,     //DM
	output reg [31:0] imme_EX_MEM_O,
	output reg [31:0] pc_order_EX_MEM_O
    );
    always @(posedge clk or negedge rst_n)
    begin 
    if(~rst_n)
    ALU_result_EX_MEM_O<=32'd0;
    else 
    ALU_result_EX_MEM_O<=ALU_result_EX_MEM_I;
    end
    
    always @(posedge clk or negedge rst_n)
    begin 
    if(~rst_n)
    pc_jump_EX_MEM_O<=32'd0;
    else 
    pc_jump_EX_MEM_O<=pc_jump_EX_MEM_I;
    end
    
    always @(posedge clk or negedge rst_n)
    begin 
    if(~rst_n)
    Rd_data2_EX_MEM_O<=32'd0;
    else 
    Rd_data2_EX_MEM_O<=Rd_data2_EX_MEM_I;
    end
    
    always @(posedge clk or negedge rst_n)
    begin 
    if(~rst_n)
    imme_EX_MEM_O<=32'd0;
    else 
    imme_EX_MEM_O<=imme_EX_MEM_I;
    end
    
    always @(posedge clk or negedge rst_n)
    begin 
    if(~rst_n)
    pc_order_EX_MEM_O<=32'd0;
    else 
    pc_order_EX_MEM_O<=pc_order_EX_MEM_I;
    end
endmodule
