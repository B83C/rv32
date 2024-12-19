`timescale 1ns/1ps
`include "defs.svh"

module multiplier(
  input clk_n,
  input en,
  input [XLEN - 1:0] r1, r2,
  input mul_op_t op,
  // output busy,
  output reg [XLEN - 1:0] rd
);

  // logic [2*XLEN - 1:0] full_mul;
  // logic signed [2*XLEN - 1:0] full_mul_s;
  // logic signed [2*XLEN - 1:0] full_mul_su;

  always @(negedge clk_n) begin
    if(en) begin
      case(op)
        MUL: rd <= 32'($signed(r1) * $signed(r2));
        MULH: rd <= ($signed(r1) * $signed(r2)) >> 32; 
        MULHSU: rd <= ($signed(r1) * r2) >> 32;
        MULHU: rd <= (r1 * r2) >> 32;
        DIV: rd <= $signed(r1) / $signed(r2);
        DIVU: rd <= r1 / r2;
        REM: rd <= $signed(r1) % $signed(r2);
        REMU: rd <= r1 % r2;
      endcase 
      // full_mul <= r1 * r2;
      // full_mul_s <= $signed(r1) * $signed(r2);
      // full_mul_su <= $signed(r1) * r2;
    end
  end

  // always_comb begin
  //   if(en) begin
  //     case(op)
  //       MUL: rd = full_mul_s[0 +:XLEN];
  //       MULH: rd = full_mul_s[XLEN  +:XLEN]; 
  //       MULHSU: rd = full_mul_su[XLEN +: XLEN];
  //       MULHU: rd = full_mul[XLEN +: XLEN];
  //       DIV: rd = $signed(r1) / $signed(r2);
  //       DIVU: rd = r1 / r2;
  //       REM: rd = $signed(r1) % $signed(r2);
  //       REMU: rd = r1 % r2;
  //     endcase
  //   end else begin
  //     rd = 0;
  //   end
  // end

endmodule
