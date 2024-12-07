`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/05 20:29:41
// Design Name: 
// Module Name: data_road
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


module data_road(
     input clk,
     input rst_n,
     input [31:0] instr,
     input memtoReg,
     input ALUsrc,
     input reg_w,
     input lui,
     input U_type,
     input jal,
     input jalr,
     input beq,
     input bne,
     input blt,
     input bge,
     input bltu,
     input bgeu,
     
     input [31:0] Rd_data,
     output [7:0] rom_addr,
     output [31:0] Wr_data,
     output [31:0] ALU_result,
     output [6:0] opcode,
     output [2:0] func3,
     output func
    );
    
    wire [4:0] Rs1;
    wire [4:0] Rs2;
    wire [4:0] Rd;
    wire [31:0] imme;
    wire [31:0] Wr_reg_data;
    wire [31:0] Wr_reg_data1;
    wire [31:0] Wr_reg_data2;
    wire [31:0] Rd_data1;
    wire [31:0] Rd_data2;
    
    wire [31:0] ALU_B;
    wire [31:0] WB_data;
    
    wire [31:0] pc_order;
    wire [31:0] pc_jump;
    wire [31:0] pc_jalr;
    
    wire [31:0] pc_new;
    wire [31:0] pc_out;
    
    wire jump_flag;
    wire jump_sel;
    wire [31:0] pc_jump_order;
    
    assign jump_sel=jal|jalr;
    assign Wr_data=Rd_data2;
    assign rom_addr=pc_out[9:2];
    assign pc_jalr={ALU_result[31:1],1'b0};
    PC_addr U1(.clk(clk),.rst_n(rst_n),.pc_new(pc_new),.pc_out(pc_out));
    
    decoding U2(.instr(instr),.opcode(opcode),.func3(func3),.func(func),.Rs1(Rs1),.Rs2(Rs2),.Rd(Rd),.imme(imme));
    
    register U3(.clk(clk),.w_en(reg_w),.Rs1(Rs1),.Rs2(Rs2),.Rd(Rd),.w_data(Wr_reg_data),.Rd_data1(Rd_data1),.Rd_data2(Rd_data2));
    
    ALU U4(.func3(func3),.func(func),.ALU_A(Rd_data1),.ALU_B(ALU_B),.overflow(),.ALU_result(ALU_result));
    
    branch U5(.beq(beq),.bne(bne),.blt(blt),.bge(bge),.bltu(bltu),.bgeu(bgeu),.jal(jal),.jalr(jalr));
    
    //pc+4
    CL_adder_32 U6(.A(pc_out),.B(32'd4),.c_in(1'b0),.C(pc_order),.c_out());
    
    //pc+imme
    CL_adder_32 U7(.A(pc_out),.B(imme),.c_in(32'd0),.C(pc_jump),.c_out());
    
    //pc_sel
    Mux U8(.data1(pc_jump),.data2(pc_order),.sel(jump_flag),.dout(pc_jump_order));
    
    //pc_jalr
    Mux U9(.data1(pc_jalr),.data2(pc_jump_order),.sel(jalr),.dout(pc_new));
    
    //ALU_sel
    Mux U10(.data1(imme),.data2(Rd_data2),.sel(ALUsrc),.dout(ALU_B));
    
    //ALU_result or datamemory
    Mux U11(.data1(Rd_data),.data2(ALU_result),.sel(memtoReg),.dout(WB_data));
    
    //Wr_data_sel
    
    //1.lui处理
    Mux U12(.data1(imme),.data2(pc_jump),.sel(lui),.dout(Wr_reg_data1));
    
    //2.jalr处理
    Mux U13(.data1(pc_order),.data2(WB_data),.sel(jump_sel),.dout(Wr_reg_data2));
    
    //3.总reg处理
     Mux U14(.data1(Wr_reg_data1),.data2(Wr_reg_data2),.sel(U_type),.dout(Wr_reg_data));
endmodule
