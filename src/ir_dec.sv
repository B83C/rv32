`timescale 1ns/1ps

`include "defs.svh"

module ir_dec #(
  IR_WIDTH = 32
)(
  input clk,
  input en,
  input [IR_WIDTH - 1: 0] ir,
  output logic s, l, w, b,
  output logic [4:0] rs1, rs2, rd,
  // output alu_op_t alu_op, 
  output logic [IR_WIDTH - 1: 0] imm,
  output logic wb_src
);

typedef enum {
  R,
  I,
  S,
  B,
  U,
  J,
  None
} instr_type;

// typedef struct {
//   logic [31:0] pattern;
//   logic [31:0] mask;
//   logic ld, str, w, b;
//   instr_type it;
// } instr_t;

// instr_type it

wire [2:0] funct3;
wire [6:0] funct7;
wire [11:0] funct12;
wire [6:0] opcode;

assign funct3 = ir[14:12];
assign funct7 = ir[31:25];
assign funct12 = ir[31:20];
assign opcode = ir[6:0];

assign rs1 = ir[19:15];
assign rs2 = ir[24:20];
assign rd = ir[11:7];

function logic[31:0] im (instr_type t); 
  case (t) 
    I: begin
      return {{20{ir[31]}}, ir[31:20]}; 
    end
    S: begin
      return {{20{ir[31]}}, ir[31:25], ir[11:7]}; 
    end
    B: begin
      return {{20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0}; 
    end
    U: begin
      return {ir[31:12], 12'b0}; 
    end
    J: begin
      return {{12{ir[31]}}, ir[19:12], ir[20], ir[30:21], 1'b0}; 
    end
    default: return 32'b0;
  endcase
endfunction

always @(posedge clk) begin
  if(en) begin
    casez ({funct7, funct3, opcode}) 
      {7'd?, 3'd?, 7'b0110111}:  {s, l, w, b, wb_src, imm} <= {5'b00100, im(U)}; //LUI
      {7'd?, 3'd?, 7'b0010111}:  {s, l, w, b, wb_src, imm} <= {5'b00100, im(U)}; //AUIPC
      {7'd?, 3'd?, 7'b1101111}:  {s, l, w, b, wb_src, imm} <= {5'b00110, im(J)}; //JAL
      {7'd?, 3'd?, 7'b1100111}:  {s, l, w, b, wb_src, imm} <= {5'b00110, im(I)}; //JALR
      {7'd?, 3'd0, 7'b1100011}:  {s, l, w, b, wb_src, imm} <= {5'b00010, im(B)}; //BEQ
      {7'd?, 3'd1, 7'b1100011}:  {s, l, w, b, wb_src, imm} <= {5'b00010, im(B)}; //BNE
      {7'd?, 3'd4, 7'b1100011}:  {s, l, w, b, wb_src, imm} <= {5'b00010, im(B)}; //BLT
      {7'd?, 3'd5, 7'b1100011}:  {s, l, w, b, wb_src, imm} <= {5'b00010, im(B)}; //BGE
      {7'd?, 3'd6, 7'b1100011}:  {s, l, w, b, wb_src, imm} <= {5'b00010, im(B)}; //BLTU
      {7'd?, 3'd7, 7'b1100011}:  {s, l, w, b, wb_src, imm} <= {5'b00010, im(B)}; //BGEU
      {7'd?, 3'd0, 7'b0000011}:  {s, l, w, b, wb_src, imm} <= {5'b01101, im(I)}; //LB
      {7'd?, 3'd1, 7'b0000011}:  {s, l, w, b, wb_src, imm} <= {5'b01101, im(I)}; //LH
      {7'd?, 3'd2, 7'b0000011}:  {s, l, w, b, wb_src, imm} <= {5'b01101, im(I)}; //LW
      {7'd?, 3'd4, 7'b0000011}:  {s, l, w, b, wb_src, imm} <= {5'b01101, im(I)}; //LBU
      {7'd?, 3'd5, 7'b0000011}:  {s, l, w, b, wb_src, imm} <= {5'b01101, im(I)}; //LHU
      {7'd?, 3'd0, 7'b0100011}:  {s, l, w, b, wb_src, imm} <= {5'b10000, im(S)}; //SB
      {7'd?, 3'd1, 7'b0100011}:  {s, l, w, b, wb_src, imm} <= {5'b10000, im(S)}; //SH
      {7'd?, 3'd2, 7'b0100011}:  {s, l, w, b, wb_src, imm} <= {5'b10000, im(S)}; //SW
      {7'd?, 3'd0, 7'b0010011}:  {s, l, w, b, wb_src, imm} <= {5'b00100, im(I)}; //ADDI
      {7'd?, 3'd2, 7'b0010011}:  {s, l, w, b, wb_src, imm} <= {5'b00100, im(I)}; //SLTI
      {7'd?, 3'd3, 7'b0010011}:  {s, l, w, b, wb_src, imm} <= {5'b00100, im(I)}; //SLTIU
      {7'd?, 3'd4, 7'b0010011}:  {s, l, w, b, wb_src, imm} <= {5'b00100, im(I)}; //XORI
      {7'd?, 3'd6, 7'b0010011}:  {s, l, w, b, wb_src, imm} <= {5'b00100, im(I)}; //ORI
      {7'd?, 3'd7, 7'b0010011}:  {s, l, w, b, wb_src, imm} <= {5'b00100, im(I)}; //ANDI
      {7'd?, 3'd1, 7'b0010011}:  {s, l, w, b, wb_src, imm} <= {5'b00100, im(I)}; //SLLI
      {7'd0, 3'd5, 7'b0010011}:  {s, l, w, b, wb_src, imm} <= {5'b00100, im(I)}; //SRLI 
      {7'd1, 3'd5, 7'b0010011}:  {s, l, w, b, wb_src, imm} <= {5'b00100, im(I)}; //SRAI
      {7'd0, 3'd0, 7'b0110011}:  {s, l, w, b, wb_src, imm} <= {5'b00100, im(R)}; //ADD
      {7'd1, 3'd0, 7'b0110011}:  {s, l, w, b, wb_src, imm} <= {5'b00100, im(R)}; //SUB
      {7'd0, 3'd1, 7'b0110011}:  {s, l, w, b, wb_src, imm} <= {5'b00100, im(R)}; //SLL
      {7'd0, 3'd2, 7'b0110011}:  {s, l, w, b, wb_src, imm} <= {5'b00100, im(R)}; //SLT
      {7'd0, 3'd3, 7'b0110011}:  {s, l, w, b, wb_src, imm} <= {5'b00100, im(R)}; //SLTU
      {7'd0, 3'd4, 7'b0110011}:  {s, l, w, b, wb_src, imm} <= {5'b00100, im(R)}; //XOR
      {7'd0, 3'd5, 7'b0110011}:  {s, l, w, b, wb_src, imm} <= {5'b00100, im(R)}; //SRL
      {7'd1, 3'd5, 7'b0110011}:  {s, l, w, b, wb_src, imm} <= {5'b00100, im(R)}; //SRA
      {7'd0, 3'd6, 7'b0110011}:  {s, l, w, b, wb_src, imm} <= {5'b00100, im(R)}; //OR
      {7'd0, 3'd7, 7'b0110011}:  {s, l, w, b, wb_src, imm} <= {5'b00100, im(R)}; //AND
      //TODO: {10'd?, 7'b0001111}:  {s, l, w, b, imm} = {4'b0000, im(None)}; //FENCE
      //TODO: {10'd?, 7'b0001111}:  {s, l, w, b, imm} = {4'b0000, im(None)};  //FENCE.TSO
      //TODO: {10'd?, 7'b0001111}:  {s, l, w, b, imm} = {4'b0000, im(None)}; //PAUSE
      //TODO: {10'd?, 7'b1110011}:  {s, l, w, b, imm} = {4'b0000, im(None)}; //ECALL
      //TODO: {10'd?, 7'b1110011}:  {s, l, w, b, imm} = {4'b0000, im(None)}; //EBREAK 
      default: {s, l, w, b, imm} <= {4'b0000, im(None)};
    endcase
  end
end

  

endmodule
