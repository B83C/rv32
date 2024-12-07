`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/06 23:11:38
// Design Name: 
// Module Name: WB_stage
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


module WB_stage(
    input MemtoReg,
	input jal,
	input jalr,
	input lui,
	input U_type,
	input [31:0] ALU_result_WB_I,   
	input [31:0] pc_jump_WB_I,
	input [31:0] loaddata_WB_I,    
	input [31:0] imme_WB_I,
	input [31:0] pc_order_WB_I,
	output [31:0] Wr_data_WB_O
    );
    wire [31:0] WB_data;
    //ALU_result or DM_output
    Mux U1(.data1(loaddata_WB_I),.data2(ALU_result_WB_I),.sel(MemtoReg),.dout(WB_data));
    
    //Wr_data_sel
    wire sel;
    wire [31:0] Wr_data1;
    wire [31:0] Wr_data2;
    assign sel=jal|jalr;
    //jalr
    Mux U2(.data1(pc_order_WB_I),.data2(WB_data),.sel(sel),.dout(Wr_data2));
    
    //lui
    
    Mux U3(.data1(imme_WB_I),.data2(pc_jump_WB_I),.sel(lui),.dout(Wr_data1));
    
    //reg
    
    Mux U4(.data1(Wr_data1),.data2(Wr_data2),.sel(U_type),.dout(Wr_data_WB_O));
    
endmodule
