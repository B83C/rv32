`timescale 1ns/1ps
`include "defs.svh"

module multiplier(
  input en,
  input [XLEN - 1:0] r1, r2,
  input mul_op_t op,
  output logic [XLEN - 1:0] rd
);

  wire [2*XLEN - 1:0] full_mul;
  wire signed [2*XLEN - 1:0] full_mul_s;
  wire signed [2*XLEN - 1:0] full_mul_su;

  assign full_mul = r1 * r2;
  assign full_mul_s = $signed(r1) * $signed(r2);
  assign full_mul_su = $signed(r1) * r2;

  always_comb begin
    if(en) begin
      case(op)
        MUL: rd = full_mul_s[0 +:XLEN];
        MULH: rd = full_mul_s[XLEN  +:XLEN]; 
        MULHSU: rd = full_mul_su[XLEN +: XLEN];
        MULHU: rd = full_mul[XLEN +: XLEN];
        DIV: rd = $signed(r1) / $signed(r2);
        DIVU: rd = r1 / r2;
        REM: rd = $signed(r1) % $signed(r2);
        REMU: rd = r1 % r2;
      endcase
    end else begin
      rd = 0;
    end
  end

endmodule
