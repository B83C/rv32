`timescale 1ns/1ps
`include "defs.svh"

interface pipeline_i(input clk);
  logic stall_f, stall_d, stall_e;
  logic flush_f, flush_d, flush_e;
 
  logic stalls [N_STAGES-1:0];
  logic flushes [N_STAGES-1:0];

  word_t instr [N_STAGES:0];
  word_t pc [N_STAGES:0];
  reg_ind_t rs1 [N_STAGES:0];
  reg_ind_t rs2 [N_STAGES:0];
  reg_ind_t rd [N_STAGES:0];
  word_t r1 [N_STAGES:0];
  word_t r2 [N_STAGES:0];
  word_t imm [N_STAGES:0];
  logic [2:0] func3 [N_STAGES:0];
  logic [1:0] alu_src_sel [N_STAGES:0];
  control_signals_t cs [N_STAGES:0];
  word_t mul_res [N_STAGES:0];
  word_t alu_res [N_STAGES:0];

  word_t r1_temp, r2_temp;
  word_t instr_in;

  logic [31:0] r1_e_mux, r2_e_mux, r2_e_mux_m;

  logic [31:0] alu_mux_input_1;
  logic [31:0] alu_mux_input_2;
  word_t mem_read_data [N_STAGES:0];

  logic branch_hit;
  logic [31:0] jmp_addr;
  logic overflow, zero;
  logic mul_busy;
  register_data_sel r1_e_sel, r2_e_sel;

  modport ir_dec(input clk,
    input instr,
    input flush_d, 
    output cs,
    output rs1, rs2, rd,
    output alu_src_sel,
    output imm,
    output func3
  );

  // modport hazard(input clk,
  //  input rs1, rs2, rs1_e, rs2_e, rd_e, rd_m, rd_w,
  //  input cs_e, cs_m, cs_w, 
  //  input branch_hit,
  //  output r1_e_sel, r2_e_sel,
  //  output stall_f, stall_d,
  //  output flush_f, flush_d, flush_e 
  // );
endinterface
