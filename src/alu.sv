`timescale 1ns / 1ps
`include "defs.svh"

module alu (
    input [2:0] func3,
    input control_signals_t cs,
    input [31:0] alu_a, 
    input [31:0] alu_b,
    // input overwrite_add,
    output overflow,
    output zero,
    output reg [31:0] alu_result
);

  wire [31:0] add_result;

  CL_adder_32 adder1 (
      .A(alu_a),
      .B(alu_b ^ {32{cs.sign}}),
      .c_in(cs.sign),
      .C(add_result),
      .c_out(overflow)
  );

  wire [ 4:0] shamt;
  // wire signed [31:0] salu_a, salu_b;
  // assign salu_a = $signed(alu_a);
  // assign salu_b = $signed(alu_b);
  assign shamt = alu_b[4:0];

  assign zero = alu_result == 0;

  // wire alu_op_t opr;

  //Add when instruction is jump
  // assign opr = (overwrite_add)? ADD: alu_op_t'(func3);

  always_comb begin
    if(cs.a) begin
      case(alu_op_t'(func3)) 
        ADD: begin
          alu_result = add_result;
        end
        SLL: begin
          alu_result = alu_a << shamt;
        end
        SLT: begin
          alu_result = {31'd0, overflow & add_result[31]};
        end
        SLTU: begin
          alu_result = {31'd0, overflow};
        end
        XOR: begin
          alu_result = alu_a ^ alu_b;
        end
        SRL: begin
          if(cs.sign) begin
            alu_result = alu_a >>> shamt;
          end else begin
            alu_result = alu_a >> shamt;
          end
        end
        OR: begin
          alu_result = alu_a | alu_b;
        end
        AND: begin
          alu_result = alu_a & alu_b;
        end
        default: begin
          alu_result = 0;
        end
      endcase
    end else begin
      alu_result = add_result;
    end
  end
endmodule
