`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/08 15:32:49
// Design Name: 
// Module Name: datapath_1
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


module datapath_1(
      input clk,
      input rst_n,
      input [31:0] instr,
      input [31:0] data_mem,
      output [31:0] addr,
      output [31:0] wr_addr_s,
      output [31:0] data2_s,
      output  lw_en_s,
      output  sw_en_s,
      output  lh_en_s,
      output  sh_en_s,
      output  lb_en_s,
      output  sb_en_s
    );
    //第一级
    wire cancel;
    wire [31:0] offset_r;
    PC_addr U1(.clk(clk),.rst_n(rst_n),.cancel(cancel),.offset(offset_r),.pc_out(addr));
    
    //第二级
    wire [31:0] instr_r;
    wire [31:0] addr_r;
    receive #32 U2(.clk(clk),.data(instr),.data_r(instr_r));
    receive #32 U3(.clk(clk),.data(addr),.data_r(addr_r));
    
    wire [6:0] opcode;
    wire [2:0] func3;
    wire [2:0] func3_d;
    wire [2:0] func3_r;
    wire func;
    wire func_d;
    wire func_r;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [4:0] rd_d;
    wire [4:0] rd_s;
    wire [31:0] imme;
    wire [31:0] jmp;
    decoding U4(.instr(instr_r),.opcode(opcode),.func3(func3),.func(func),.Rs1(rs1),.Rs2(rs2),.Rd(rd),.imme(imme),.jmp(jmp));
    
    wire [31:0] data;
    wire [31:0] data_r;
    wire [31:0] data1;
    wire [31:0] data1_d;
    wire [31:0] data1_r;
    wire [31:0] data2;
    wire [31:0] data2_d;
    wire [31:0] data2_in;
    wire [31:0] data_out;
    wire pass;
    wire sub_en;
    wire sub_en_r;
    wire wr_en;
    wire wr_en_s;
    wire jmp_en;
    wire lb_en;
    wire sb_en;
    wire lh_en;
    wire sh_en;
    wire lw_en;
    wire sw_en;
    jmp U5(.data1(data1),.data2(data2),.func3(func3),.pass(pass));
    
    control U6(.clk(clk),.opcode(opcode),.func3(func3),.func(func),.pass(pass),.cancel(cancel),.sub_en(sub_en),
    .wr_en(wr_en),.jmp_en(jmp_en),.lb_en(lb_en),.sb_en(sb_en),.lh_en(lh_en),.sh_en(sh_en),.lw_en(lw_en),.sw_en(sw_en));
        
    Mux U7(.clk(clk),.data1(data2),.data2(imme),.sel(opcode[5]),.dout(data2_in));
    
    wire [31:0] offset;
    offset_sel U8(.clk(clk),.jmp(jmp),.addr(addr_r),.ext_imm(imme),.data1(data1),.sel(opcode[3:2]),.offset(offset));
    
    wire [31:0] wr_addr;
    wr_addr U9(.clk(clk),.ext_imme(imme),.data1(data1),.wr_addr(wr_addr));
    
    temporary #32 U10(.clk(clk),.data(data1),.data_d(data1_d));
	temporary #32 U11(.clk(clk),.data(data2),.data_d(data2_d));
	temporary #5 U12(.clk(clk),.data(rd),.data_d(rd_d));
	temporary #3 U13(.clk(clk),.data(func3),.data_d(func3_d));
	temporary #1 U14(.clk(clk),.data(func),.data_d(func_d));
	
	//第三级流水线
    wire [31:0] data_in2;
    wire [31:0] data_in2_r;
    wire [31:0] wr_data;
	shift #(2,32) U15(.clk(clk),.data(wr_addr),.data_s(wr_addr_s));
	shift #(2,32) U16(.clk(clk),.data(data2_d),.data_s(data2_s));
	shift #(2,1)  U17(.clk(clk),.data(lw_en),.data_s(lw_en_s));
	shift #(2,1)  U18(.clk(clk),.data(sw_en),.data_s(sw_en_s));
    shift #(2,1)  U19(.clk(clk),.data(lh_en),.data_s(lh_en_s));
	shift #(2,1)  U20(.clk(clk),.data(sh_en),.data_s(sh_en_s));
	shift #(2,1)  U21(.clk(clk),.data(lb_en),.data_s(lb_en_s));
	shift #(2,1)  U22(.clk(clk),.data(sb_en),.data_s(sb_en_s));
	shift #(3,5)  U23(.clk(clk),.data(rd_d),.data_s(rd_s));
	shift #(3,1)  U24(.clk(clk),.data(wr_en),.data_s(wr_en_s));
	receive #32   U25(.clk(clk),.data(offset),.data_r(offset_r));
	receive #32   U26(.clk(clk),.data(data1_d),.data_r(data1_r));
	receive #32   U27(.clk(clk),.data(data_in2),.data_r(data_in2_r));
	receive #3    U28(.clk(clk),.data(func3_d),.data_r(func3_r));
	receive #1    U29(.clk(clk),.data(func_d),.data_r(func_r));
	receive #1    U30(.clk(clk),.data(sub_en),.data_r(sub_en_r));
	receive #1    U31(.clk(clk),.data(jmp_en),.data_r(cancel));
	ALU U32(.func3(func3_r),.func(func),.ALU_A(data1_r),.ALU_B(data_in2_r),.sub_en(sub_en_r),.overflow(),.ALU_result(data_out));
	wr_data_sel U33(.clk(clk),.data_out(data_out),.addr(addr_r),.sel(cancel),.wr_data(wr_data));
	
	//第四级流水线
	wire [31:0] wr_data_r;
	receive #32 U34(.clk(clk),.data(wr_data),.data_r(wr_data_r));
	wr_data_sel U35(.clk(clk),.data_out(wr_data_r),.addr(data_mem),.sel(lw_en_s),.wr_data(data));
	wr_data_sel U36(.clk(clk),.data_out(wr_data_r),.addr(data_mem),.sel(lh_en_s),.wr_data(data));
	wr_data_sel U37(.clk(clk),.data_out(wr_data_r),.addr(data_mem),.sel(lb_en_s),.wr_data(data));
	
	//第五级流水线
	receive #32 U38(.clk(clk),.data(data),.data_r(data_r));
	register register_cpu(.clk(clk),.rst_n(rst_n),.w_en(wr_en_s),.Rs1(rs1),.Rs2(rs2),.Rd(rd_s),.w_data(data_r),.Rd_data1(data1),.Rd_data2(data2));
endmodule
