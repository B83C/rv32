`timescale 1ns/1ps
`include "defs.svh"

interface pipeline_i(input clk);
  // logic stall_f, stall_d, stall_e;
  // logic flush_f, flush_d, flush_e;
 
  logic stalls [N_STAGES-1:0];
  logic flushes [N_STAGES-1:0];

 `define D(x, y) \
    x y [N_STAGES-1:0], y``_in[N_STAGES-1:0];
    
  `D(word_t, instr)
  `D(word_t, pc)
  `D(reg_ind_t, rs1)
  `D(reg_ind_t, rs2)
  `D(reg_ind_t, rd)
  `D(word_t, r1)
  `D(word_t, r2)
  `D(word_t, imm)
  `D(alu_op_ex_t, alu_op)
  `D(logic[2:0], func3)
  `D(logic [$size(opcode_t)-1:0], op)
  `D(logic [$size(agu_src_sel_t)-1:0], agu_sel)
  `D(logic [$size(alu_src_sel_1_t)-1:0], alu_sel_1)
  `D(logic [$size(alu_src_sel_2_t)-1:0], alu_sel_2)
  `D(control_signals_t, cs)
  `D(logic[$size(alu_reg_src_t) -1 :0], reg_src_1)
  `D(logic[$size(alu_reg_src_t) -1 :0], reg_src_2)
  `D(word_t, mul_res)
  `D(word_t, alu_res)
  `D(word_t, write_back)
  `D(logic, io_en_i)
  `D(logic, mem_en_i)


  logic [31:0] alu_mux_input_1;
  logic [31:0] alu_mux_input_2;
  `D(word_t, mem_read_data);

  logic branch_hit;
  logic [31:0] jmp_addr;
  logic overflow, zero;
  logic mul_busy;
  register_data_sel r1_e_sel, r2_e_sel;

  // modport hazard(input clk,
  //  input rs1, rs2, rs1_e, rs2_e, rd_e, rd_m, rd_w,
  //  input cs_e, cs_m, cs_w, 
  //  input branch_hit,
  //  output r1_e_sel, r2_e_sel,
  //  output stall_f, stall_d,
  //  output flush_f, flush_d, flush_e 
  // );
endinterface
