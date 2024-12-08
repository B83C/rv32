`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/08 14:42:21
// Design Name: 
// Module Name: control
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


module control(
    input clk,
	input [6:0] opcode,
	input [2:0] func3,
	input func,
	input pass,
	input cancel,
	output reg sub_en,
	output reg wr_en,
	output reg jmp_en,
	output reg lb_en,
	output reg sb_en,
	output reg lh_en,
	output reg sh_en,
	output reg lw_en,
	output reg sw_en
);

	always@(negedge clk)begin
		if(cancel)begin
			sw_en <= 1'b0; lw_en <= 1'b0;sh_en<=1'b0;lh_en<=1'b0;sb_en<=1'b0;lb_en<=1'b0; jmp_en <= 1'b0;sub_en<=1'b0;  wr_en <= 1'b0;
		end else begin
			case(opcode)
				7'b0_110_011: begin sw_en <= 1'b0; lw_en <= 1'b0; sh_en<=1'b0;lh_en<=1'b0;sb_en<=1'b0;lb_en<=1'b0;jmp_en <= 1'b0;sub_en <= func ? 1'b1 : 1'b0; wr_en <= 1'b1; end
				7'b0_010_011: begin sw_en <= 1'b0; lw_en <= 1'b0; sh_en<=1'b0;lh_en<=1'b0;sb_en<=1'b0;lb_en<=1'b0;jmp_en <= 1'b0;sub_en<=1'b0; wr_en <= 1'b1; end
				7'b1_101_111: begin sw_en <= 1'b0; lw_en <= 1'b0; sh_en<=1'b0;lh_en<=1'b0;sb_en<=1'b0;lb_en<=1'b0;jmp_en <= 1'b1;sub_en<=1'b0;  wr_en <= 1'b1; end
				7'b1_100_111: begin sw_en <= 1'b0; lw_en <= 1'b0; sh_en<=1'b0;lh_en<=1'b0;sb_en<=1'b0;lb_en<=1'b0;jmp_en <= 1'b1;sub_en<=1'b0;  wr_en <= 1'b1; end
				7'b1_100_011: begin sw_en <= 1'b0; lw_en <= 1'b0; sh_en<=1'b0;lh_en<=1'b0;sb_en<=1'b0;lb_en<=1'b0;jmp_en <= pass;sub_en<=1'b0;  wr_en <= 1'b0; end
				7'b0_000_011: begin 
				case(func3)
				3'b000:begin sw_en <= 1'b0; lw_en <= 1'b0; sh_en<=1'b0;lh_en<=1'b0;sb_en<=1'b0;lb_en<=1'b1;jmp_en <= 1'b0;sub_en<=1'b0;  wr_en <= 1'b1; end
				3'b001:begin sw_en <= 1'b0; lw_en <= 1'b0; sh_en<=1'b0;lh_en<=1'b1;sb_en<=1'b0;lb_en<=1'b0;jmp_en <= 1'b0;sub_en<=1'b0;  wr_en <= 1'b1; end
				3'b010:begin sw_en <= 1'b0; lw_en <= 1'b1; sh_en<=1'b0;lh_en<=1'b0;sb_en<=1'b0;lb_en<=1'b0;jmp_en <= 1'b0;sub_en<=1'b0;  wr_en <= 1'b1; end
				endcase
			    end
				7'b0_100_011: begin 
				case(func3)
				3'b000:begin sw_en <= 1'b0; lw_en <= 1'b0; sh_en<=1'b0;lh_en<=1'b0;sb_en<=1'b1;lb_en<=1'b0;jmp_en <= 1'b0;sub_en<=1'b0;  wr_en <= 1'b0; end
				3'b001:begin sw_en <= 1'b0; lw_en <= 1'b0; sh_en<=1'b1;lh_en<=1'b0;sb_en<=1'b0;lb_en<=1'b0;jmp_en <= 1'b0;sub_en<=1'b0;  wr_en <= 1'b0; end
				3'b010:begin sw_en <= 1'b1; lw_en <= 1'b0; sh_en<=1'b0;lh_en<=1'b0;sb_en<=1'b0;lb_en<=1'b0;jmp_en <= 1'b0;sub_en<=1'b0;  wr_en <= 1'b0; end
				endcase
				end
				default: begin sw_en <= 1'b0; lw_en <= 1'b0; sh_en<=1'b0;lh_en<=1'b0;sb_en<=1'b0;lb_en<=1'b0;jmp_en <= 1'b0;sub_en<=1'b0;  wr_en <= 1'b0; end
			endcase
		end
	end

endmodule 

