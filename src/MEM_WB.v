`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/06 22:38:32
// Design Name: 
// Module Name: MEM_WB
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


module MEM_WB(
    input clk,
    input rst_n,
    input [31:0] ALU_result_MEM_WB_I,   
	input [31:0] pc_jump_MEM_WB_I,
	input [31:0] loaddata_MEM_WB_I,     //DM，访存阶段的新数据
	input [31:0] imme_MEM_WB_I,
	input [31:0] pc_order_MEM_WB_I,
	output reg [31:0] ALU_result_MEM_WB_O,   
	output reg [31:0] pc_jump_MEM_WB_O,
	output reg [31:0] loaddata_MEM_WB_O,     //DM
	output reg [31:0] imme_MEM_WB_O,
	output reg [31:0] pc_order_MEM_WB_O
    );
    always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			ALU_result_MEM_WB_O<=32'd0;
		else
			ALU_result_MEM_WB_O<=ALU_result_MEM_WB_I;
	end
	
	always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			pc_jump_MEM_WB_O<=32'd0;
		else
			pc_jump_MEM_WB_O<=pc_jump_MEM_WB_I;
	end

    always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			loaddata_MEM_WB_O<=32'd0;
		else
			loaddata_MEM_WB_O<=loaddata_MEM_WB_I;
	end
	
	always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			imme_MEM_WB_O<=32'd0;
		else
			imme_MEM_WB_O<=imme_MEM_WB_I;
	end
	
	always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			pc_order_MEM_WB_O<=32'd0;
		else
			pc_order_MEM_WB_O<=pc_order_MEM_WB_I;
	end
endmodule
