`timescale 1ns / 1ps
`include "defs.svh"

module alu (
    input alu_op_ex_t alu_op,
    input control_signals_t cs,
    input [31:0] alu_a,
    input [31:0] alu_b,
    // input overwrite_add,
    output overflow,
    output zero,
    output logic [31:0] alu_result
);

  logic sign_ex, sign;
  assign sign_ex = alu_op.op != SLTU; //The only unsiged here
  assign sign = alu_op.op != ADD; //The only unsiged here
  logic [32:0] s1; 
  assign s1 = {sign_ex & alu_a[31], alu_a};
  logic [32:0] s2; 
  assign s2 = {sign_ex & alu_b[31], alu_b} ^ {33{sign}};

  logic [31:0] add_result;
  assign {overflow, add_result} = s1 + s2 + 33'(sign);

  wire [4:0] shamt;
  assign shamt = alu_b[4:0];

  assign zero  = alu_a == alu_b;

  logic [31:0] res;

  assign alu_result = res;

  always_comb begin : calculations
    // if (cs.a) begin
      case (alu_op.op)
        ADD: res = add_result;
        SLL: res = alu_a << shamt;
        SLT, SLTU: res = {31'd0, overflow};
        // SLTU: res = {31'd0, add_result[31]};
        XOR: res = alu_a ^ alu_b;
        SRL: begin
          if (alu_op.ex) begin
            res = signed'(alu_a) >>> shamt;
          end else begin
            res = alu_a >> shamt;
          end
        end
        OR: res = alu_a | alu_b;
        AND: res = alu_a & alu_b;
        default: res = 'x;
      endcase
    // end else begin
    //   res = add_result;
    // end
  end
endmodule
