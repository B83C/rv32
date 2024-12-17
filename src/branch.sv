`timescale 1ns / 1ps
`include "defs.svh"

//Branch module
module branch (
    input en,
    input [31:0] opr1,
    input [31:0] opr2,
    input [2:0] func3,
    output success
);
  wire signed [31:0] sopr1 = $signed(opr1);
  wire signed [31:0] sopr2 = $signed(opr2);
  wire branch_op_t opt;
  assign opt = branch_op_t'(func3);

  assign success = en & (
          (opr1 == opr2 && opt == EQ) |
          (opr1 != opr2 && opt == NE) |
          (opr1 < opr2 && opt == LT) |
          (opr1 > opr2 && opt == GE) |
          (sopr1 < sopr2 && opt == LTU) |
          (sopr1 > sopr2 && opt == GEU) 
     );
endmodule
