`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/08 16:12:14
// Design Name: 
// Module Name: jmp
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

//有条件跳转指令的实现
module jmp(
    input [31:0]data1,
	input [31:0]data2,
	input [2:0]func3,
	output reg pass
);
    reg signed [31:0] data_1;//用于有符号数的比较
    reg signed [31:0] data_2;
	always@(*)
	   begin
	   data_1=data1;
	   data_2=data2;
		case(func3)
			3'b000: 
				if(data1 == data2) pass <= 1'b1;//beq
				else pass <= 1'b0;
			3'b001:
				if(data1 != data2) pass <= 1'b1;//bne
				else pass <= 1'b0;
			3'b100:
				if(data_1<data_2) pass <= 32'd1;//blt
				else pass<=32'd0;
			3'b101:
				if(data_1>data_2) pass<=32'd1;//bge
				else pass<=32'd0;
			3'b110:
				if(data1 < data2) pass <= 1'b1;//bltu
				else pass <= 1'b0;
			3'b111:
				if(data1 < data2) pass <= 1'b0;//bgeu
				else pass <= 1'b1;
			default: pass <= 1'b0;
		endcase
      end
   
endmodule
