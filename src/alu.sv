`timescale 1ns/1ps

`include "defs.svh"

module alu #(
  
)(
  input alu_op_t alu_op,
  input [31:0] r1, r2,
  output logic [31:0] out
);
always_comb begin
  case(alu_op)
    ADD:
      out = r1 + r2;
    SUB:
      out = r1 - r2;
    XOR:
      out = r1 ^ r2;
    OR:
      out = r1 | r2;
    AND:
      out = r1 & r2;
    SLL:
      out = r1 << r2;
    SRLL:
      out = r1 >> r2;
    SRA:
      out = r1 >> r2;
  endcase
end

endmodule
