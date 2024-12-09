`timescale 1ns/1ps

`include "defs.svh"

// Things to note here:
// s: Store
// l: Load
// w: Write
// b: Branch (or jump)
module ir_dec_ctrl #(
  IR_WIDTH = 32
)(
  input clk,
  input en,
  input [IR_WIDTH - 1: 0] ir,
  output s, l, w, b,
  output wb_src,
  output logic [4:0] rs1, rs2, rd,
  output logic [1:0] alu_op_sel,
  output alu_op_t alu_op,
  output logic [IR_WIDTH - 1: 0] imm
);

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

function logic[33:0] im_sel (instr_type t); 
  case (t) 
    R: return {2'b10, 32'b0};
    I: return {2'b10, {{20{ir[31]}}, ir[31:20]}}; 
    S: return {2'b00, {{20{ir[31]}}, ir[31:25], ir[11:7]}}; 
    B: return {2'b00, {{20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0}}; 
    U: return {2'b11, {ir[31:12], 12'b0}}; 
    J: return {2'b11, {{12{ir[31]}}, ir[19:12], ir[20], ir[30:21], 1'b0}}; 
    default: return 34'b0;
  endcase
endfunction

function logic[1:0] sel(instr_type t); 
  case (t) 
    R: return 2'b10; 
    I: return 2'b10; 
    S: return 2'b00; 
    B: return 2'b00; 
    U: return 2'b11; 
    J: return 2'b11; 
    default: return 32'b0;
  endcase
endfunction

logic [5 - 1:0] c_sig = 0; // Control signal 控制信号

typedef struct {
  logic [5 - 1 :0] control_signals;
  logic [1:0] alu_op_sel; //
  logic [32 - 1 :0] immediate;
} result_t;

result_t dres; // Decode result

assign {s, l, w, b, wb_src} = d_res;

assign imm = dres.immediate;

always @(posedge clk) begin
  casez ({funct7, funct3, opcode}) 
    {7'd?, 3'd?, 7'b0110111}:  d_res <= {5'b00100, im_sel(U)}; //LUI
    {7'd?, 3'd?, 7'b0010111}:  d_res <= {5'b00100, im_sel(U)}; //AUIPC
    {7'd?, 3'd?, 7'b1101111}:  d_res <= {5'b00110, im_sel(J)}; //JAL
    {7'd?, 3'd?, 7'b1100111}:  d_res <= {5'b00110, im_sel(I)}; //JALR
    {7'd?, 3'd0, 7'b1100011}:  d_res <= {5'b00010, im_sel(B)}; //BEQ
    {7'd?, 3'd1, 7'b1100011}:  d_res <= {5'b00010, im_sel(B)}; //BNE
    {7'd?, 3'd4, 7'b1100011}:  d_res <= {5'b00010, im_sel(B)}; //BLT
    {7'd?, 3'd5, 7'b1100011}:  d_res <= {5'b00010, im_sel(B)}; //BGE
    {7'd?, 3'd6, 7'b1100011}:  d_res <= {5'b00010, im_sel(B)}; //BLTU
    {7'd?, 3'd7, 7'b1100011}:  d_res <= {5'b00010, im_sel(B)}; //BGEU
    {7'd?, 3'd0, 7'b0000011}:  d_res <= {5'b01101, im_sel(I)}; //LB
    {7'd?, 3'd1, 7'b0000011}:  d_res <= {5'b01101, im_sel(I)}; //LH
    {7'd?, 3'd2, 7'b0000011}:  d_res <= {5'b01101, im_sel(I)}; //LW
    {7'd?, 3'd4, 7'b0000011}:  d_res <= {5'b01101, im_sel(I)}; //LBU
    {7'd?, 3'd5, 7'b0000011}:  d_res <= {5'b01101, im_sel(I)}; //LHU
    {7'd?, 3'd0, 7'b0100011}:  d_res <= {5'b10000, im_sel(S)}; //SB
    {7'd?, 3'd1, 7'b0100011}:  d_res <= {5'b10000, im_sel(S)}; //SH
    {7'd?, 3'd2, 7'b0100011}:  d_res <= {5'b10000, im_sel(S)}; //SW
    {7'd?, 3'd0, 7'b0010011}:  d_res <= {5'b00100, im_sel(I)}; //ADDI
    {7'd?, 3'd2, 7'b0010011}:  d_res <= {5'b00100, im_sel(I)}; //SLTI
    {7'd?, 3'd3, 7'b0010011}:  d_res <= {5'b00100, im_sel(I)}; //SLTIU
    {7'd?, 3'd4, 7'b0010011}:  d_res <= {5'b00100, im_sel(I)}; //XORI
    {7'd?, 3'd6, 7'b0010011}:  d_res <= {5'b00100, im_sel(I)}; //ORI
    {7'd?, 3'd7, 7'b0010011}:  d_res <= {5'b00100, im_sel(I)}; //ANDI
    {7'd?, 3'd1, 7'b0010011}:  d_res <= {5'b00100, im_sel(I)}; //SLLI
    {7'd0, 3'd5, 7'b0010011}:  d_res <= {5'b00100, im_sel(I)}; //SRLI 
    {7'b0100000, 3'd5, 7'b0010011}:  d_res <= {5'b00100, im_sel(I)}; //SRAI
    {7'd0, 3'd0, 7'b0110011}:  d_res <= {5'b00100, im_sel(R)}; //ADD
    {7'b0100000, 3'd0, 7'b0110011}:  d_res <= {5'b00100, im_sel(R)}; //SUB
    {7'd0, 3'd1, 7'b0110011}:  d_res <= {5'b00100, im_sel(R)}; //SLL
    {7'd0, 3'd2, 7'b0110011}:  d_res <= {5'b00100, im_sel(R)}; //SLT
    {7'd0, 3'd3, 7'b0110011}:  d_res <= {5'b00100, im_sel(R)}; //SLTU
    {7'd0, 3'd4, 7'b0110011}:  d_res <= {5'b00100, im_sel(R)}; //XOR
    {7'd0, 3'd5, 7'b0110011}:  d_res <= {5'b00100, im_sel(R)}; //SRL
    {7'b0100000, 3'd5, 7'b0110011}:  d_res <= {5'b00100, im_sel(R)}; //SRA
    {7'd0, 3'd6, 7'b0110011}:  d_res <= {5'b00100, im_sel(R)}; //OR
    {7'd0, 3'd7, 7'b0110011}:  d_res <= {5'b00100, im_sel(R)}; //AND
    //TODO: {10'd?, 7'b0001111}:  {s, l, w, b, imm, alu_op_sel} <= {4'b0000, im(No, sel(ne)}; //FENCE
    //TODO: {10'd?, 7'b0001111}:  {s, l, w, b, imm, alu_op_sel} <= {4'b0000, im(No, sel(ne)};  //FENCE.TSO
    //TODO: {10'd?, 7'b0001111}:  {s, l, w, b, imm, alu_op_sel} <= {4'b0000, im(No, sel(ne)}; //PAUSE
    //TODO: {10'd?, 7'b1110011}:  {s, l, w, b, imm, alu_op_sel} <= {4'b0000, im(No, sel(ne)}; //ECALL
    //TODO: {10'd?, 7'b1110011}:  {s, l, w, b, imm, alu_op_sel} <= {4'b0000, im(No, sel(ne)}; //EBREAK 
    default: d_res <= {5'b00000, im_sel(None)};
  endcase
end

  

endmodule
