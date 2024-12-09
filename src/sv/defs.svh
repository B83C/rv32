`ifndef DEFS_SVH 
`define DEFS_SVH

parameter IR_WIDTH = 32;

typedef enum {
  ADD = 0,
  SUB,
  SLL,
  SLA,
  SRL,
  SRA,
  SLT,
  SLTU,
  XOR,
  OR,
  AND,
  NONE
} alu_op_t;

typedef enum {
  R,
  I,
  S,
  B,
  U,
  J,
  None
} instr_type;

`endif
