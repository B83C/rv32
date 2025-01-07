`timescale 1ns/1ps
`include "defs.svh"

module multiplier(
  input clk,
  input en,
  input word_t r1, r2,
  input mul_op_t op,
  output mul_busy,
  output word_t rd
);

  logic running;
  assign mul_busy = running;
  // logic [2*XLEN - 1:0] full_mul;
  // logic signed [2*XLEN - 1:0] full_mul_s;
  // logic signed [2*XLEN - 1:0] full_mul_su;
  word_t rd_buf;

  always @(posedge clk) begin
    if(en) begin
      running <= 1;
      case(op)
        MUL: rd_buf <= 32'($signed(r1) * $signed(r2));
        MULH: rd_buf <= 32'((64'($signed(r1)) * 64'($signed(r2))) >> 32); 
        MULHSU: rd_buf <= 32'((64'($signed(r1)) * 64'(r2)) >> 32); 
        MULHU: rd_buf <= 32'((64'(r1) * 64'(r2)) >> 32); 
        DIV: rd_buf <= $signed(r1) / $signed(r2);
        DIVU: rd_buf <= r1 / r2;
        REM: rd_buf <= $signed(r1) % $signed(r2);
        REMU: rd_buf <= r1 % r2;
      endcase 
    end else if (running) begin
      running <= 0;
      rd <= rd_buf;
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
