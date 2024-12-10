`timescale 1ns / 1ps
`include "defs.svh"

module datapath_1 (
    input clk,
    input rst_n,
    input [31:0] instr,
    input [31:0] data_mem,
    output [31:0] addr,
    output [31:0] wr_addr_s,
    output [31:0] data2_s,
    // data_width dw,
    output control_signals_t cs_o
);
  //第一级
  wire [31:0] branch_addr;
  wire cancel;

  wire [31:0] offset_r;
  wire [31:0] pc_current; //TODO
  wire [31:0] pc_next;

  assign pc_next = (cs.j)? data_out: (branch_hit)? branch_addr: pc_current + 4;

  //第二级
  // wire [31:0] instr_r;
  wire [4:0] rs1;
  wire [4:0] rs2;
  wire [4:0] rd;
  wire [31:0] imm;
  // wire [31:0] jmp_addr;
  wire control_signals_t cs;
  wire control_signals_t cs_s;
  wire [2:0] func3;
  wire [1:0] alu_src_sel;

  wire s, l, w, j, b, wb_src, sub;
  wire data_width dw;
  wire ignore_first_operand; 
  assign {s, l, w, j, b, wb_src, sub, dw, ignore_first_operand} = cs;
  assign cs_o = cs;  //TODO make it stored in register

  ir_dec_ctrl layer2 (.clk(clk), .ir(instr), .cs(cs), .rs1(rs1), .rs2(rs2), .rd(rd), .imm(imm),.func3(func3), .alu_src_sel(alu_src_sel));

  registers regs (
      .clk(clk),
      .rst_n(rst_n),
      .w_en(wr_en_s),
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd_s),
      .w_data(data_r),
      .rd_data1(data1),
      .rd_data2(data2)
  );  //数据写回

  wire [31:0] addr_r;
  receive #32 U3 (
      .clk(clk),
      .data(addr),
      .data_r(addr_r)
  );  //取出地址

  wire [2:0] func3_d;
  wire [2:0] func3_r;
  wire func_d;
  wire func_r;
  wire [4:0] rd_d;
  wire [4:0] rd_s;

  wire [31:0] data;
  wire [31:0] data_r;
  wire [31:0] data1;
  wire [31:0] data1_d;
  wire [31:0] data1_r;
  wire [31:0] data2;
  wire [31:0] data2_d;
  wire [31:0] alu_mux_input_1;
  wire [31:0] alu_mux_input_2;
  wire [31:0] data_out;

  assign branch_addr = pc_current + imm;
  wire branch_hit;
  wire wr_en_s;
  branch branch_m (
    .en(cs.b),
    .opr1(data1),
    .opr2(data2),
    .func3(func3),
    .success(branch_hit)
    );

  assign alu_mux_input_1 = (cs.ignore_first_operand)? 0: alu_src_sel[0]?pc_current: data1;
  assign alu_mux_input_2 = alu_src_sel[1]?imm: data2;


  wire [31:0] wr_addr;
  wr_addr U9 (
      .clk(clk),
      .imme(imm),
      .data1(data1),
      .wr_addr(wr_addr)
  );  //地址计算
  //寄存器存数据，到下一级流水线中取出使用
  temporary #32 U10 (
      .clk(clk),
      .data(data1),
      .data_d(data1_d)
  );  //寄存器存入数据，源寄存器rs1的数据
  temporary #32 U11 (
      .clk(clk),
      .data(data2),
      .data_d(data2_d)
  );  //寄存器存入数据，源寄存器rs2的数据
  temporary #5 U12 (
      .clk(clk),
      .data(rd),
      .data_d(rd_d)
  );  //寄存器存入数据目标寄存器
  temporary #3 U13 (
      .clk(clk),
      .data(func3),
      .data_d(func3_d)
  );  //寄存器存入数据func3
  temporary #1 U14 (
      .clk(clk),
      .data(cs.s),
      .data_d(func_d)
  );  //寄存器存入数据func

  //第三级流水线
  //通过移位寄存器取出数据和放入数据
  shift #(2, 32) U15 (
      .clk(clk),
      .data(wr_addr),
      .data_s(wr_addr_s)
  );  //取出
  shift #(2, 32) U16 (
      .clk(clk),
      .data(data2_d),
      .data_s(data2_s)
  );  //取出rs2中的数据

  shift #(2, $size(control_signals_t)) buffered_control_signals (
    .clk(clk),
    .data(cs),
    .data_s(cs_s)
  );
  shift #(2, 1) buffered_w (
    .clk(clk),
    .data(cs_s.w),
    .data_s(wr_en_s)
  );

  shift #(3, 5) U23 (
      .clk(clk),
      .data(rd_d),
      .data_s(rd_s)
  );

  receive #3 U28 (
      .clk(clk),
      .data(func3_d),
      .data_r(func3_r)
  );  //取出func3

  alu alu_m (
      .func3(func3_r),
      .cs(cs),
      .alu_a(alu_mux_input_1),
      .alu_b(alu_mux_input_2),
      .overwrite_add(cs.j | alu_src_sel[1] & alu_src_sel[0]), //TODO clarify more, when both bits are set, it means its either U or J type. However, we only want to detect jump type. This is not a good solution
      .overflow(),
      .alu_result(data_out)
  );

  // assign mem_write = cs.w;
  assign data = cs.l? data_mem : data_out;

  receive #32 U38 (
      .clk(clk),
      .data(data),
      .data_r(data_r)
  );
endmodule
