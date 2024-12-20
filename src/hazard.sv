`timescale 1ns/1ps
`include "defs.svh"

module hazard (
  input [4:0] rs1, rs2, rs1_e, rs2_e, rd_e, rd_m, rd_w,
  input control_signals_t cs_e, cs_m, cs_w, 
  input branch_hit,
  input instr_ready,
  output register_data_sel r1_e_sel, r2_e_sel,
  output logic stall_f, stall_d,
  output logic flush_f, flush_d, flush_e 
);

  assign r1_e_sel = (cs_m.w && (rs1_e == rd_m))?
     ALU : (cs_w.w && (rs1_e == rd_w))?
     WB: RAW;
  assign r2_e_sel = (cs_m.w && (rs2_e == rd_m))?
     ALU : (cs_w.w && (rs2_e == rd_w))?
     WB: RAW;
  
  // assign stall_f = 0;
  // assign stall_d = 0;
  // assign stall_f = cs_e.j | (cs_e.b & branch_hit);
  // assign stall_d = cs_e.j | (cs_m.b & branch_hit);

  assign flush_f = 1;
  assign flush_d = !(cs_e.j | (cs_e.b & branch_hit));
  // assign flush_e = !stall_d;
  assign flush_e = flush_d & !stall_d;
  // assign flush_e = flush_f;

  assign stall_d = (cs_e.l && (rd_e == rs2 | rd_e == rs1) && rd_e != 0) + !instr_ready;
  assign stall_f = stall_d;
  // assign stall_f=cs_m.j||cs_m.b||cs_m.m;//有跳转，分支，乘除，流水线暂停
  // assign stall_d=stall_f||(cs_w.w && (rs1_e == rd_w || rs2_e == rd_w));//有写回，暂停

endmodule 

