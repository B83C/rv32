`timescale 1ns/1ps
`include "defs.svh"

module multiplier(
  input [XLEN - 1:0] r1, r2,
  output logic [XLEN - 1:0] rd,
  input mul_op_t op
);

  wire [2*XLEN - 1:0] full_mul;
  wire signed [2*XLEN - 1:0] full_mul_s;
  wire [XLEN - 1:0] div;

  assign full_mul = r1 * r2;
  assign full_mul_s = $signed(r1) * $signed(r2);

  always_comb begin
    case(op)
      MUL: rd = full_mul[0 +:XLEN];
      MULH: rd = full_mul[XLEN  +:XLEN]; 
      MULHSU: rd = 
      MULHU: 
      DIV: 
      DIVU: 
      REM: 
      REMU:
    endcase
  	
  end

endmodule
