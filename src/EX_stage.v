`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/06 00:18:40
// Design Name: 
// Module Name: EX_stage
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


module EX_stage(
    input [3:0] ALUctl_EX_I,
	input beq_EX_I,
	input bne_EX_I,
	input blt_EX_I,
	input bge_EX_I,
	input bltu_EX_I,
	input bgeu_EX_I,
	input jal_EX_I,
	input jalr_EX_I,
	input ALUSrc_EX_I,
	input [31:0]pc_EX_I,
	input [31:0]imme_EX_I,
	input [31:0]Rd_data1_EX_I,
	input [31:0]Rd_data2_EX_I,
	output [31:0]ALU_result_EX_O,
	output [31:0]pc_new_EX_O,
	output [31:0]pc_jump_O,
	output [31:0]Rd_data2_EX_O,
	output [31:0]imme_EX_O,
	output [31:0]pc_order_EX_O
    );
    wire [31:0] ALU_B;
    
    ALU U1(.func3(ALUctl_EX_I[2:0]),.func(ALUctl_EX_I[3]),.ALU_A(Rd_data1_EX_I),.ALU_B(ALU_B),.overflow(),.ALU_result(ALU_result_EX_O));
    
    wire jump_flag;
    branch U2(.beq(beq_EX_I),.bne(bne_EX_I),.blt(blt_EX_I),.bge(bge_EX_I),.bltu(bltu_EX_I),.bgeu(bgeu_EX_I),.jal(jal_EX_I),.jalr(jalr_EX_I),.jump_flag(jump_flag));
    
    wire [31:0] pc_order;
    //pc+4
    CL_adder_32 U3(.A(pc_EX_I),.B(32'd4),.c_in(1'd0),.C(pc_order),.c_out());
    
    //pc+imme
    CL_adder_32 U4(.A(pc_EX_I),.B(imme_EX_I),.c_in(1'd0),.C(pc_jump_O),.c_out());
    
    wire [31:0] pc_jump_order;
    //pc_sel
    Mux U5(.data1(pc_jump_O),.data2(pc_order),.sel(jump_flag),.dout(pc_jump_order));
    
    //pc_jalr
    wire [31:0] pc_jalr;
    assign pc_jalr={ALU_result_EX_O[31:1],1'b0};
    Mux U6(.data1(pc_jalr),.data2(pc_jump_order),.sel(jalr_EX_I),.dout(pc_new_EX_O));
    
    //ALU_sel
    Mux U7(.data1(imme_EX_I),.data2(Rd_data2_EX_I),.sel(ALUSrc_EX_I),.dout(ALU_B));
    
    assign imme_EX_O=imme_EX_I;
	assign pc_order_EX_O=pc_order;
	
endmodule
