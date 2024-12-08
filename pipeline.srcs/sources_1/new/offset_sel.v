`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/08 15:24:27
// Design Name: 
// Module Name: offset_sel
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


module offset_sel(
	input clk,
	input [31:0] jmp,
	input [31:0] addr,
	input [31:0] ext_imm,
	input [31:0] data1,
	input [1:0] sel, //op[3:2]
	output reg [31:0] offset
);

	always@(negedge clk)
		case(sel)
			2'b11: offset <= addr + (jmp << 1);
			2'b01: offset <= ext_imm + data1;
			2'b00: offset <= addr + (ext_imm << 1);
			default: offset <= 32'd0;
		endcase

endmodule 