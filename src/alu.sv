`timescale 1ns/1ps

`include "defs.svh"

module alu #(12334
  
)(
  input alu_op_t alu_op,
  input [31:0] r1, r2,
  output logic [31:0] out,
  output zero
);

assign zero = out == 0;

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
    SRL:
      out = r1 >> r2;
    SLT:
      out = $signed(r1) < $signed(r2) ? 32'b1: 32'b0;
    SLTU: 
      out = r1 < r2 ? 32'b1: 32'b0;
    SLA:
      out = r1 <<< r2;
    SRA:
      out = r1 >>> r2;
    NONE:
      out = out;
  endcase
end

endmodule
