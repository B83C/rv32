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
  // output s, l, w, j, b, sub,
  // output wb_src,
  output [4:0] rs1, rs2, rd,
  output [1:0] alu_src_sel,
  // output alu_op_t alu_op,
  output [IR_WIDTH - 1: 0] imm,
  output [IR_WIDTH - 1: 0] jmp_addr,
  output [6:0] opcode,
  output [2:0] func3,
  output [6:0] func7
);

// typedef struct {
//   logic [31:0] pattern;
//   logic [31:0] mask;
//   logic ld, str, w, b;
//   instr_type it;
// } instr_t;

// instr_type it

// wire [2:0] func3;
// wire [6:0] func7;
wire [11:0] func12;
// wire [6:0] opcode;

//Buffered;
// logic [31:0] ir;

assign func3 = ir[14:12];
assign func7 = ir[31:25];
assign func12 = ir[31:20];
assign opcode = ir[6:0];

assign rs1 = ir[19:15];
assign rs2 = ir[24:20];
assign rd = ir[11:7];

assign jmp_addr = { {12{ir[31]}}, ir[31], ir[19:12], ir[20], ir[30:21] };  //jal立即数扩展输出

function logic[33:0] im_sel (instr_type t); 
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

// function logic[1:0] sel(instr_type t); 
//   case (t) 
//     R: return 2'b00; 
//     I: return 2'b10; 
//     S: return 2'b00; 
//     B: return 2'b00; 
//     U: return 2'b11; 
//     J: return 2'b11; 
//     default: return 32'b0;
//   endcase
// endfunction


typedef struct packed {
  control_signals_t control_signals;
  alu_info_t alu_info;
  // logic [5 - 1 :0] control_signals;
} result_t;

result_t d_res; // Decode result

assign cs = d_res.control_signals;
// assign {s, l, w, j, b, wb_src, sub} = d_res.control_signals;

assign imm = d_res.alu_info.immediate;

assign alu_src_sel = d_res.alu_info.alu_src_sel;

always @(posedge clk) begin
  casez ({func7, func3, opcode}) 
    {7'd?, 3'd?, 7'b0110111}:  d_res <= '{'{w:1, default: 0}, im_sel(U)}; //LUI
    {7'd?, 3'd?, 7'b0010111}:  d_res <= '{'{w:1,default:0}, im_sel(U)}; //AUIPC
    {7'd?, 3'd?, 7'b1101111}:  d_res <= '{'{w:1,j:1,default:0}, im_sel(J)}; //JAL
    {7'd?, 3'd?, 7'b1100111}:  d_res <= '{'{w:1,j:1,default:0}, im_sel(I)}; //JALR
    {7'd?, 3'd0, 7'b1100011}:  d_res <= '{'{b:1,default:0}, im_sel(B)}; //BEQ
    {7'd?, 3'd1, 7'b1100011}:  d_res <= '{'{b:1,default:0}, im_sel(B)}; //BNE
    {7'd?, 3'd4, 7'b1100011}:  d_res <= '{'{b:1,default:0}, im_sel(B)}; //BLT
    {7'd?, 3'd5, 7'b1100011}:  d_res <= '{'{b:1,default:0}, im_sel(B)}; //BGE
    {7'd?, 3'd6, 7'b1100011}:  d_res <= '{'{b:1,default:0}, im_sel(B)}; //BLTU
    {7'd?, 3'd7, 7'b1100011}:  d_res <= '{'{b:1,default:0}, im_sel(B)}; //BGEU
    {7'd?, 3'd0, 7'b0000011}:  d_res <= '{'{l:1,w:1,wb_src:1,default:0}, im_sel(I)}; //LB
    {7'd?, 3'd1, 7'b0000011}:  d_res <= '{'{l:1,w:1,wb_src:1,default:0}, im_sel(I)}; //LH
    {7'd?, 3'd2, 7'b0000011}:  d_res <= '{'{l:1,w:1,wb_src:1,default:0}, im_sel(I)}; //LW
    {7'd?, 3'd4, 7'b0000011}:  d_res <= '{'{l:1,w:1,wb_src:1,default:0}, im_sel(I)}; //LBU
    {7'd?, 3'd5, 7'b0000011}:  d_res <= '{'{l:1,w:1,wb_src:1,default:0}, im_sel(I)}; //LHU
    {7'd?, 3'd0, 7'b0100011}:  d_res <= '{'{s:1,default:0}, im_sel(S)}; //SB
    {7'd?, 3'd1, 7'b0100011}:  d_res <= '{'{s:1,default:0}, im_sel(S)}; //SH
    {7'd?, 3'd2, 7'b0100011}:  d_res <= '{'{s:1,default:0}, im_sel(S)}; //SW
    {7'd?, 3'd0, 7'b0010011}:  d_res <= '{'{w:1,default:0}, im_sel(I)}; //ADDI
    {7'd?, 3'd2, 7'b0010011}:  d_res <= '{'{w:1,default:0}, im_sel(I)}; //SLTI
    {7'd?, 3'd3, 7'b0010011}:  d_res <= '{'{w:1,default:0}, im_sel(I)}; //SLTIU
    {7'd?, 3'd4, 7'b0010011}:  d_res <= '{'{w:1,default:0}, im_sel(I)}; //XORI
    {7'd?, 3'd6, 7'b0010011}:  d_res <= '{'{w:1,default:0}, im_sel(I)}; //ORI
    {7'd?, 3'd7, 7'b0010011}:  d_res <= '{'{w:1,default:0}, im_sel(I)}; //ANDI
    {7'd?, 3'd1, 7'b0010011}:  d_res <= '{'{w:1,default:0}, im_sel(I)}; //SLLI
    {7'd0, 3'd5, 7'b0010011}:  d_res <= '{'{w:1,default:0}, im_sel(I)}; //SRLI 
    {7'b0100000, 3'd5, 7'b0010011}:  d_res <= '{'{w:1,default:0}, im_sel(I)}; //SRAI
    {7'd0, 3'd0, 7'b0110011}:  d_res <= '{'{w:1,default:0}, im_sel(R)}; //ADD
    {7'b0100000, 3'd0, 7'b0110011}:  d_res <= '{'{w:1, sub:1 ,default:0}, im_sel(R)}; //SUB
    {7'd0, 3'd1, 7'b0110011}:  d_res <= '{'{w:1,default:0}, im_sel(R)}; //SLL
    {7'd0, 3'd2, 7'b0110011}:  d_res <= '{'{w:1,default:0}, im_sel(R)}; //SLT
    {7'd0, 3'd3, 7'b0110011}:  d_res <= '{'{w:1,default:0}, im_sel(R)}; //SLTU
    {7'd0, 3'd4, 7'b0110011}:  d_res <= '{'{w:1,default:0}, im_sel(R)}; //XOR
    {7'd0, 3'd5, 7'b0110011}:  d_res <= '{'{w:1,default:0}, im_sel(R)}; //SRL
    {7'b0100000, 3'd5, 7'b0110011}:  d_res <= '{'{w:1,default:0}, im_sel(R)}; //SRA
    {7'd0, 3'd6, 7'b0110011}:  d_res <= '{'{w:1,default:0}, im_sel(R)}; //OR
    {7'd0, 3'd7, 7'b0110011}:  d_res <= '{'{w:1,default:0}, im_sel(R)}; //AND
    //TODO: {10'd?, 7'b0001111}:  {s, l, w, b, imm, alu_op_sel} <= {4'b0000, im(No, sel(ne)}; //FENCE
    //TODO: {10'd?, 7'b0001111}:  {s, l, w, b, imm, alu_op_sel} <= {4'b0000, im(No, sel(ne)};  //FENCE.TSO
    //TODO: {10'd?, 7'b0001111}:  {s, l, w, b, imm, alu_op_sel} <= {4'b0000, im(No, sel(ne)}; //PAUSE
    //TODO: {10'd?, 7'b1110011}:  {s, l, w, b, imm, alu_op_sel} <= {4'b0000, im(No, sel(ne)}; //ECALL
    //TODO: {10'd?, 7'b1110011}:  {s, l, w, b, imm, alu_op_sel} <= {4'b0000, im(No, sel(ne)}; //EBREAK 
    default: d_res <= '{'{default:0}, im_sel(None)};
  endcase
end

  

endmodule
