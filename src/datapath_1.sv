`timescale 1ns / 1ps
`include "defs.svh"

module datapath_1 (
    input clk,
    input rst_n,
    input [31:0] instr,
    input [31:0] data_mem,
    output [31:0] pc_addr,
    output [31:0] wr_addr_s,
    output [31:0] data2_s,
    // data_width dw,
    output control_signals_t cs_om
);

  wire branch_hit;
  wire [31:0] branch_addr;
  logic [31:0] pc_current; //TODO
  wire [31:0] pc_next;
 
  wire [31:0] instr_d, pc_d, pc_e, pc_m, pc_w;
  rbuffer #(32) instr_b (clk, instr, instr_d);
  rbuffer #(32) pc_bd (clk, pc_current, pc_d);
  rbuffer #(32) pc_be (clk, pc_d, pc_e);
  rbuffer #(32) pc_bm (clk, pc_e, pc_m);
  rbuffer #(32) pc_bw (clk, pc_m, pc_w);

  wire [4:0] rs1, rs1_e;
  wire [4:0] rs2, rs2_e;
  rbuffer #(5) rs1_be (clk, rs1, rs1_e);
  rbuffer #(5) rs2_be (clk, rs2, rs2_e);
  wire [4:0] rd, rd_e, rd_m, rd_w;
  rbuffer #(5) rd_be (clk, rd, rd_e);
  rbuffer #(5) rd_bm (clk, rd_e, rd_m);
  rbuffer #(5) rd_bw (clk, rd_m, rd_w);

  wire [31:0] r1, r1_e, r1_m, r1_w;
  rbuffer #(32) r1_be (clk, r1, r1_e);
  rbuffer #(32) r1_bm (clk, r1_e, r1_m);
  rbuffer #(32) r1_bw (clk, r1_m, r1_w);
  wire [31:0] r2, r2_e, r2_m, r2_w;
  rbuffer #(32) r2_be (clk, r2, r2_e);
  rbuffer #(32) r2_bm (clk, r2_e, r2_m);
  rbuffer #(32) r2_bw (clk, r2_m, r2_w);

  wire [31:0] imm, imm_e;
  rbuffer #(32) imm_be (clk, imm, imm_e);

  wire [2:0] func3, func3_e;
  rbuffer #(3) func3_be (clk, func3, func3_e);
  wire [1:0] alu_src_sel;

  wire control_signals_t cs, cs_e, cs_m, cs_w;
  rbuffer #($size(control_signals_t)) cs_be (clk, cs, cs_e);
  rbuffer #($size(control_signals_t)) cs_bm (clk, cs_e, cs_m);
  rbuffer #($size(control_signals_t)) cs_bw (clk, cs_m, cs_w);

  wire [31:0] alu_mux_input_1;
  wire [31:0] alu_mux_input_2;
  wire [31:0] alu_res, alu_res_m;
  rbuffer #(32) alu_res_bm (clk, alu_res, alu_res_m);

  wire [31:0] write_back;

  assign pc_next = (cs.j)? alu_res : (branch_hit)? branch_addr: pc_current + 4;
  assign pc_addr = pc_current;
  always @(posedge clk) begin
    pc_current <= pc_next;
  end

  ir_dec_ctrl layer2 (.clk(clk), .ir(instr), .cs(cs), .rs1(rs1), .rs2(rs2), .rd(rd), .imm(imm),.func3(func3), .alu_src_sel(alu_src_sel));

  registers regs (
      .clk(clk),
      .rst_n(rst_n),
      .w_en(cs_w.w),
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd_w),
      .w_data(write_back),
      .rd_data1(r1),
      .rd_data2(r2)
  ); 


  assign branch_addr = pc_current + imm;
  branch branch_e (
    .en(cs.b),
    .opr1(r1_e),
    .opr2(r2_e),
    .func3(func3_e),
    .success(branch_hit)
    );

  assign alu_mux_input_1 = (cs.ignore_first_operand)? 0: alu_src_sel[0]? pc_current: r1_e;
  assign alu_mux_input_2 = alu_src_sel[1]? imm: r2_e;

  alu alu_e (
      .func3(func3_e),
      .cs(cs_e),
      .alu_a(alu_mux_input_1),
      .alu_b(alu_mux_input_2),
      .overwrite_add(cs_e.j | alu_src_sel[1] & alu_src_sel[0]), //TODO clarify more, when both bits are set, it means its either U or J type. However, we only want to detect jump type. This is not a good solution
      .overflow(),
      .alu_result(alu_res)
  );

  assign cs_om = cs_m;
  assign write_back = cs_w.j? pc_w + 4: cs_w.l? data_mem : alu_res_m;
endmodule
