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
  // input en,
  input [IR_WIDTH - 1: 0] ir,
  output control_signals_t cs,
  output [4:0] rs1, rs2, rd,
  output [1:0] alu_src_sel,
  output [IR_WIDTH - 1: 0] imm,
  output [2:0] func3
  // output [6:0] func7
);
wire [6:0] func7;
wire [11:0] func12;
wire [6:0] opcode;

assign func3 = ir[14:12];
assign func7 = ir[31:25];
assign func12 = ir[31:20];
assign opcode = ir[6:0];

assign rs1 = ir[19:15];
assign rs2 = ir[24:20];
assign rd = ir[11:7];

function logic[33:0] T(instr_type t); 
  case (t) 
    R: return {2'b00, 32'b0};
    I: return {2'b10, {{20{ir[31]}}, ir[31:20]}}; 
    S: return {2'b00, {{20{ir[31]}}, ir[31:25], ir[11:7]}}; 
    B: return {2'b00, {{20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0}}; 
    U: return {2'b11, {ir[31:12], 12'b0}}; 
    J: return {2'b11, {{12{ir[31]}}, ir[19:12], ir[20], ir[30:21], 1'b0}}; 
    default: return 34'b0;
  endcase
endfunction

typedef struct packed {
  control_signals_t control_signals;
  alu_info_t alu_info;
} result_t;

result_t d_res; // Decode result

assign cs = d_res.control_signals;

assign imm = d_res.alu_info.immediate;

assign alu_src_sel = d_res.alu_info.alu_src_sel;

always @(posedge clk) begin
  d_res <= '{'{default:0}, T(None)};
  casez ({func7, func3, opcode}) 
    //RV32I
    {7'd?, 3'd?, 7'b0110111}:  d_res <= '{'{w:1,ignore_first_operand:1,default:0}, T(U)}; //LUI
    {7'd?, 3'd?, 7'b0010111}:  d_res <= '{'{w:1,default:0}, T(U)}; //AUIPC
    {7'd?, 3'd?, 7'b1101111}:  d_res <= '{'{w:1,j:1,default:0}, T(J)}; //JAL
    {7'd?, 3'd?, 7'b1100111}:  d_res <= '{'{w:1,j:1,default:0}, T(I)}; //JALR
    {7'd?, EQ, 7'b1100011}:  d_res <= '{'{b:1,default:0}, T(B)}; //BEQ
    {7'd?, NE, 7'b1100011}:  d_res <= '{'{b:1,default:0}, T(B)}; //BNE
    {7'd?, LT, 7'b1100011}:  d_res <= '{'{b:1,default:0}, T(B)}; //BLT
    {7'd?, GE, 7'b1100011}:  d_res <= '{'{b:1,default:0}, T(B)}; //BGE
    {7'd?, LTU, 7'b1100011}:  d_res <= '{'{b:1,default:0}, T(B)}; //BLTU
    {7'd?, GEU, 7'b1100011}:  d_res <= '{'{b:1,default:0}, T(B)}; //BGEU
    {7'd?, 3'd0, 7'b0000011}:  d_res <= '{'{l:1,w:1,dw:DB,wb_src:1,sign:1,default:0}, T(I)}; //LB
    {7'd?, 3'd1, 7'b0000011}:  d_res <= '{'{l:1,w:1,dw:DH,wb_src:1,sign:1,default:0}, T(I)}; //LH
    {7'd?, 3'd2, 7'b0000011}:  d_res <= '{'{l:1,w:1,dw:DW,wb_src:1,sign:1,default:0}, T(I)}; //LW
    {7'd?, 3'd4, 7'b0000011}:  d_res <= '{'{l:1,w:1,dw:DB,wb_src:1,default:0}, T(I)}; //LBU
    {7'd?, 3'd5, 7'b0000011}:  d_res <= '{'{l:1,w:1,dw:DH,wb_src:1,default:0}, T(I)}; //LHU
    {7'd?, 3'd0, 7'b0100011}:  d_res <= '{'{s:1,dw:DB,default:0}, T(S)}; //SB
    {7'd?, 3'd1, 7'b0100011}:  d_res <= '{'{s:1,dw:DH,default:0}, T(S)}; //SH
    {7'd?, 3'd2, 7'b0100011}:  d_res <= '{'{s:1,dw:DW,default:0}, T(S)}; //SW
    {7'd?, ADD, 7'b0010011}:  d_res <= '{'{w:1,default:0}, T(I)}; //ADDI
    {7'd?, SLT, 7'b0010011}:  d_res <= '{'{w:1,default:0}, T(I)}; //SLTI
    {7'd?, SLTU, 7'b0010011}:  d_res <= '{'{w:1,default:0}, T(I)}; //SLTIU
    {7'd?, XOR, 7'b0010011}:  d_res <= '{'{w:1,default:0}, T(I)}; //XORI
    {7'd?, OR, 7'b0010011}:  d_res <= '{'{w:1,default:0}, T(I)}; //ORI
    {7'd?, AND, 7'b0010011}:  d_res <= '{'{w:1,default:0}, T(I)}; //ANDI
    {7'd?, SLL, 7'b0010011}:  d_res <= '{'{w:1,default:0}, T(I)}; //SLLI
    {7'd0, SRL, 7'b0010011}:  d_res <= '{'{w:1,default:0}, T(I)}; //SRLI 
    {7'b0100000, SRL, 7'b0010011}:  d_res <= '{'{w:1,default:0}, T(I)}; //SRAI
    {7'd0, ADD, 7'b0110011}:  d_res <= '{'{w:1,default:0}, T(R)}; //ADD
    {7'b0100000, ADD, 7'b0110011}:  d_res <= '{'{w:1, sign:1 ,default:0}, T(R)}; //SUB
    {7'd0, SLL, 7'b0110011}:  d_res <= '{'{w:1,default:0}, T(R)}; //SLL
    {7'd0, SLT, 7'b0110011}:  d_res <= '{'{w:1,default:0}, T(R)}; //SLT
    {7'd0, SLTU, 7'b0110011}:  d_res <= '{'{w:1,default:0}, T(R)}; //SLTU
    {7'd0, XOR, 7'b0110011}:  d_res <= '{'{w:1,default:0}, T(R)}; //XOR
    {7'd0, SRL, 7'b0110011}:  d_res <= '{'{w:1,default:0}, T(R)}; //SRL
    {7'b0100000, SRL, 7'b0110011}:  d_res <= '{'{w:1,default:0}, T(R)}; //SRA
    {7'd0, OR, 7'b0110011}:  d_res <= '{'{w:1,default:0}, T(R)}; //OR
    {7'd0, AND, 7'b0110011}:  d_res <= '{'{w:1,default:0}, T(R)}; //AND
    //TODO: {10'd?, 7'b0001111}:  {s, l, w, b, imm, alu_op_sel} <= {4'b0000, im(No, sel(ne)}; //FENCE
    //TODO: {10'd?, 7'b0001111}:  {s, l, w, b, imm, alu_op_sel} <= {4'b0000, im(No, sel(ne)};  //FENCE.TSO
    //TODO: {10'd?, 7'b0001111}:  {s, l, w, b, imm, alu_op_sel} <= {4'b0000, im(No, sel(ne)}; //PAUSE
    //TODO: {10'd?, 7'b1110011}:  {s, l, w, b, imm, alu_op_sel} <= {4'b0000, im(No, sel(ne)}; //ECALL
    //TODO: {10'd?, 7'b1110011}:  {s, l, w, b, imm, alu_op_sel} <= {4'b0000, im(No, sel(ne)}; //EBREAK 

    //RV32M
    {7'b0000001, MUL, 7'b0110011}: d_res <= '{'{w:1,m:1,default:0}, T(R)}; //MUL
    {7'b0000001, MULH, 7'b0110011}: d_res <= '{'{w:1,m:1,default:0}, T(R)}; //MULH
    {7'b0000001, MULHSU, 7'b0110011}: d_res <= '{'{w:1,m:1,default:0}, T(R)}; //MULHSU
    {7'b0000001, MULHU, 7'b0110011}: d_res <= '{'{w:1,m:1,default:0}, T(R)}; //MULHU
    {7'b0000001, DIV, 7'b0110011}: d_res <= '{'{w:1,m:1,default:0}, T(R)}; //DIV
    {7'b0000001, DIVU, 7'b0110011}: d_res <= '{'{w:1,m:1,default:0}, T(R)}; //DIVU
    {7'b0000001, REM, 7'b0110011}: d_res <= '{'{w:1,m:1,default:0}, T(R)}; //REM
    {7'b0000001, REM, 7'b0110011}: d_res <= '{'{w:1,m:1,default:0}, T(R)}; //REMU    
    default: d_res <= '{'{default:0}, T(None)}; //NOP
  endcase
end

  

endmodule
