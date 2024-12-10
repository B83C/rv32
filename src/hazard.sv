`timescale 1ns/1ps
`include "defs.svh"

module hazard (
  input [4:0] rs1_e, rs2_e, rd_m, rd_w,
  input control_signals_t cs_m, cs_w,
  output register_data_sel r1_sel, r2_sel
);

  assign r1_sel = (cs_m.w && rs1_e == rd_m)? ALU : (cs_w.w && rs1_e == rd_w)? WB: RAW;
  assign r2_sel = (cs_m.w && rs2_e == rd_m)? ALU : (cs_w.w && rs2_e == rd_w)? WB: RAW;

endmodule 

