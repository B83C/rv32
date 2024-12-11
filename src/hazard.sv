`timescale 1ns/1ps
`include "defs.svh"

module hazard (
  input [4:0] rs1_e, rs2_e, rd_m, rd_w,
  input control_signals_t cs_m, cs_w,
  output register_data_sel r1_sel, r2_sel,
  output logic stall_f,
  output logic stall_d
);

  assign r1_sel = (cs_m.w && rs1_e == rd_m)? ALU : (cs_w.w && rs1_e == rd_w)? WB: RAW;
  assign r2_sel = (cs_m.w && rs2_e == rd_m)? ALU : (cs_w.w && rs2_e == rd_w)? WB: RAW;
  
  assign stall_f=cs_m.j||cs_m.b||cs_m.m;//有跳转，分支，乘除，流水线暂停
  assign stall_d=stall_f||(cs_w.w && (rs1_e == rd_w || rs2_e == rd_w));//有写回，暂停

endmodule 

