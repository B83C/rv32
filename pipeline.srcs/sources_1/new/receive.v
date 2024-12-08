`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/08 14:40:44
// Design Name: 
// Module Name: receive
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


module receive #(parameter N = 32)(
    input clk,
	input [N-1:0]data,
	output reg [N-1:0]data_r
    );
    always@(posedge clk) 
    begin
    data_r <= data;
    end
endmodule
