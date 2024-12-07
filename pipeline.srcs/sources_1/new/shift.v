`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/08 17:23:26
// Design Name: 
// Module Name: shift
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
//移位寄存，取出数据
module shift #(parameter M = 3, N = 32)(
	input clk,
	input [N-1:0]data,
	output [N-1:0]data_s
);

	reg [M*N-1:0]shift;
	
	always @(posedge clk) 
	begin
	shift <= {shift[(M-1)*N-1:0],data};
	end
	
	assign data_s = shift[M*N-1:(M-1)*N];

endmodule 
