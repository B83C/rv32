`timescale 1ns/1ps
`include "defs.svh"

interface pipeline_i(input clk);
  logic stall_f, stall_d, stall_e;
  logic flush_f, flush_d, flush_e;
 
  logic [31:0] instr_d;
  logic [31:0] pc, pc_f, pc_d, pc_e, pc_m, pc_w;
  logic [4:0] rs1, rs1_e;
  logic [4:0] rs2, rs2_e;

  logic [4:0] rd, rd_e, rd_m, rd_w;

  logic [31:0] r1_e_mux, r2_e_mux, r2_e_mux_m;
  logic [31:0] r1, r1_e;
  logic [31:0] r2, r2_e;

  logic [31:0] imm, imm_e;

  logic [2:0] func3, func3_e;
  logic [1:0] alu_src_sel, alu_src_sel_e;

  control_signals_t cs, cs_d, cs_e, cs_m, cs_w;

  logic [31:0] mul_res, mul_res_m;
  logic [31:0] alu_mux_input_1;
  logic [31:0] alu_mux_input_2;
  logic [31:0] alu_res, alu_res_m, alu_res_w;
  logic [31:0] mem_read_data_w;

  logic branch_hit;
  logic [31:0] jmp_addr;
  logic overflow, zero;
  logic mul_busy;
  register_data_sel r1_e_sel, r2_e_sel;

  modport ir_dec(input clk,
    input instr_d,
    input flush_d, 
    output cs,
    output rs1, rs2, rd,
    output alu_src_sel,
    output imm,
    output func3
  );

  modport hazard(input clk,
   input rs1, rs2, rs1_e, rs2_e, rd_e, rd_m, rd_w,
   input cs_e, cs_m, cs_w, 
   input branch_hit,
   output r1_e_sel, r2_e_sel,
   output stall_f, stall_d,
   output flush_f, flush_d, flush_e 
  );
endinterface
