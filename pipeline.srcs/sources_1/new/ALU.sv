`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/03 14:45:26
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU (
    input [2:0] func3,
    input func,
    input [31:0] ALU_A,
    input [31:0] ALU_B,
    input sub_en,
    output overflow,
    output reg [31:0] ALU_result
);


  /*add sub op*/
  wire [31:0] XOR_B, SUB_EN;
  wire [31:0] ADD_result;
  CL_adder_32 adder1 (
      .A(ALU_A),
      .B(XOR_B),
      .c_in(1'b0),
      .C(ADD_result),
      .c_out(overflow)
  );
  assign XOR_B  = ALU_B ^ SUB_EN;
  assign SUB_EN = (sub_en) ? 32'b1 : 32'b0;
  /* logic op*/
  reg [31:0] logic_result;
  always @(*) begin
    case (func3)
      3'b100:  logic_result = ALU_A ^ ALU_B;  // xor
      3'b110:  logic_result = ALU_A | ALU_B;  // or
      3'b111:  logic_result = ALU_A & ALU_B;  // and
      default: logic_result = 0;
    endcase
  end

  /*shift op*/
  wire [ 4:0] shamt;
  reg  [31:0] shift_result;
  assign shamt = ALU_B[4:0];
  always @(*) begin
    case (func3)
      3'b001:  shift_result = ALU_A << shamt;  //sll
      3'b101: begin
        case (func)
          1'b0: shift_result = ALU_A >> shamt;  //srl
          1'b1: shift_result = ALU_A >>> shamt;  //sral
        endcase
      end
      default: shift_result = 0;
    endcase
  end

  /* slt op */
  reg [31:0] slt_result;
  reg signed [31:0] slt_A;
  reg signed [31:0] slt_B;
  always @(*) begin
    slt_A = ALU_A;
    slt_B = ALU_B;
    case (func3)
      3'b010: begin
        if (slt_A < slt_B) slt_result = 32'd1;
        else slt_result = 32'd0;
      end
      3'b011: begin
        if (ALU_A < ALU_B) slt_result = 32'd1;
        else slt_result = 32'd0;
      end
      default: slt_result = 32'd0;
    endcase
  end

  /* ALU result */
  always @(*) begin
    case ({
      func, func3
    })
      4'b0000: ALU_result = ADD_result;
      4'b0001: ALU_result = shift_result;
      4'b0010: ALU_result = slt_result;
      4'b0011: ALU_result = slt_result;
      4'b0100: ALU_result = logic_result;
      4'b0101: ALU_result = shift_result;
      4'b0110: ALU_result = logic_result;
      4'b0111: ALU_result = logic_result;
      4'b1000: ALU_result = ADD_result;
      4'b1101: ALU_result = shift_result;
      default: ALU_result = 32'd0;
    endcase
  end

endmodule
