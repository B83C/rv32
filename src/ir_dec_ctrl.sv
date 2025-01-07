`timescale 1ns / 1ps

`include "defs.svh"

// Things to note here:
// s: Store
// l: Load
// w: Write
// b: Branch (or jump)
module ir_dec_ctrl #(
    IR_WIDTH = 32
) (
    input word_t ir,
    output reg_ind_t rs1,
    output reg_ind_t rs2,
    output reg_ind_t rd,
    output alu_op_ex_t alu_op,
    output control_signals_t cs,
    output word_t imm,
    output opcode_t op,
    output logic [2:0] func3,
    output agu_src_sel_t agu_sel,
    output alu_src_sel_1_t alu_sel_1,
    output alu_src_sel_2_t alu_sel_2
    // output [6:0] func7
);

  wire [2:0] f3;
  wire [6:0] f7;
  wire [11:0] f12;
  wire opcode_t opcode;
  instr_type instr_t;

  assign f3 = ir[14:12];
  assign f7 = ir[31:25];
  assign f12 = ir[31:20];
  assign func3 = f3;
  assign opcode = opcode_t'(ir[6:0]);
  assign op  = opcode;

  wire word_t imm_I = 32'(signed'({ir[31:20]}));
  wire word_t imm_S = 32'(signed'({ir[31:25], ir[11:7]}));
  wire word_t imm_B = 32'(signed'({ir[31], ir[7], ir[30:25], ir[11:8], 1'b0}));
  wire word_t imm_U = {ir[31:12], 12'b0};
  wire word_t imm_J = 32'(signed'({ir[31], ir[19:12], ir[20], ir[30:21], 1'b0}));

  assign rs1 = ir[19:15];
  assign rs2 = ir[24:20];
  assign rd = ir[11:7];
  // assign func3 = f3;

  always_comb begin : imm_decoding
    case (opcode)
      OPC_JALR, OPC_LOAD, OPC_OP_IMM: imm = imm_I;
      OPC_STORE:                      imm = imm_S;
      OPC_BRANCH:                     imm = imm_B;
      OPC_LUI, OPC_AUIPC:             imm = imm_U;
      OPC_JAL:                        imm = imm_J;
      default:                        imm = 0;
    endcase
  end

  assign cs.w = opcode inside {OPC_LOAD, OPC_LUI, OPC_AUIPC, OPC_JAL, OPC_JALR, OPC_OP_IMM, OPC_OP};
  assign cs.l = opcode inside {OPC_LOAD};
  assign cs.b = opcode inside {OPC_JAL, OPC_JALR, OPC_BRANCH};
  assign cs.s = opcode inside {OPC_STORE};
  assign cs.a = opcode inside {OPC_OP_IMM, OPC_OP} & !f7[0];
  assign cs.m = opcode inside {OPC_OP} & f7[0];
  // assign cs.sign = (opcode inside {OPC_OP_IMM, OPC_OP} & (f3 inside {SLT, SLTU} | ( f3 inside {ADD, SRL} & f7[5]))) | opcode inside { OPC_BRANCH };
  // assign cs.b = opcode inside {OPC_BRANCH};
  assign cs.sign_ex = f3[2];
  assign cs.dw = f3[1:0];

  // Referenced from https://github.com/dominiksalvet/super-riscv/blob/main/src/rtl/dec/inst_dec.sv
  always_comb begin
    case (opcode)
      OPC_LUI:                        alu_sel_1 = ALU_S1_0;
      OPC_AUIPC, OPC_JAL, OPC_JALR:   alu_sel_1 = ALU_S1_PC;
      OPC_BRANCH, OPC_OP_IMM, OPC_OP: alu_sel_1 = ALU_S1_R1;
      default:                        alu_sel_1 = alu_src_sel_1_t'('x);
    endcase

    case (opcode)
      OPC_JALR, OPC_JAL:              alu_sel_2 = ALU_S2_4;
      OPC_LUI, OPC_AUIPC, OPC_OP_IMM: alu_sel_2 = ALU_S2_IMM;
      OPC_BRANCH, OPC_OP:             alu_sel_2 = ALU_S2_R2;
      default:                        alu_sel_2 = alu_src_sel_2_t'('x);
    endcase

    case (opcode)
      OPC_OP: alu_op = '{f7[5], alu_op_t'(f3)};
      OPC_OP_IMM: alu_op = '{(f3 == SRL) & f7[5], alu_op_t'(f3)};
      OPC_BRANCH: alu_op = '{0, (f3 inside {LTU, GEU})?SLTU: SLT};
      OPC_LUI, OPC_AUIPC, OPC_JAL, OPC_JALR: alu_op = '{1'b0, ADD};
      default: alu_op = 'x;
    endcase

    case(opcode)
      OPC_JALR, OPC_LOAD, OPC_STORE: agu_sel = AGU_S1_R1;
      OPC_JAL, OPC_BRANCH: agu_sel = AGU_S1_PC;
      default: agu_sel = agu_src_sel_t'('x);
    endcase 
  end

endmodule
