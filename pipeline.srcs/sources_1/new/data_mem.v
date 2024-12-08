`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/08 15:03:57
// Design Name: 
// Module Name: data_mem
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

//数据存储器
module data_mem(
    input clk,
	input [31:0]addr,
	input [31:0]data2,
	input lw_en,
	input sw_en,
	input lh_en,
	input sh_en,
	input lb_en,
	input sb_en,
	output reg [31:0]data_mem
);

	reg [7:0]data[0:255];
	//上升沿写入
	always@(posedge clk)
	begin
		if(lw_en)begin
			data_mem[7:0] <= data[addr+3];
			data_mem[15:8] <= data[addr+2];
			data_mem[23:16] <= data[addr+1];
			data_mem[31:24] <= data[addr];
		end
		else if(lh_en) begin
		    data_mem[7:0] <= data[addr+3];
			data_mem[15:8] <= data[addr+2];
			data_mem[23:16] <= 8'b0;
			data_mem[31:24] <= 8'b0;
		end
		else if(lb_en) begin
	        data_mem[7:0] <= data[addr+3];
			data_mem[15:8] <=  8'b0;
			data_mem[23:16] <= 8'b0;
			data_mem[31:24] <= 8'b0;
		end
		else begin
		    data_mem[7:0] <=   8'b0;
			data_mem[15:8] <=  8'b0;
			data_mem[23:16] <= 8'b0;
			data_mem[31:24] <= 8'b0;
			end
			end
    //下降沿读取
	always@(negedge clk)
	begin
		if(sw_en)begin
			data[addr+3] <= data2[7:0];
			data[addr+2] <= data2[15:8];
			data[addr+1] <= data2[23:16];
			data[addr] <= data2[31:24];
		end
		else if(sh_en) begin
		    data[addr+3] <= data2[7:0];
			data[addr+2] <= data2[15:8];
			data[addr+1] <= 8'b0;
			data[addr] <= 8'b0;
		end
		else if(sb_en) begin
		    data[addr+3] <= data2[7:0];
			data[addr+2] <= 8'b0;
			data[addr+1] <= 8'b0;
			data[addr] <= 8'b0;
		 end
		 else begin
		    data[addr+3] <=8'b0;
			data[addr+2] <= 8'b0;
			data[addr+1] <= 8'b0;
			data[addr] <= 8'b0;
        end
        end
endmodule