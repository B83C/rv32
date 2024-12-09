`ifndef DEFS_SVH 
`define DEFS_SVH

`define IR_WIDTH 32

typedef struct packed {
  logic s;
  logic l;
  logic w;
  logic j;
  logic b;
  logic wb_src;
  logic sub;
} control_signals_t;

typedef struct packed {
  logic [1:0] alu_src_sel; //
  logic [32 - 1 :0] immediate;
} alu_info_t;

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
