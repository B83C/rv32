`ifndef DEFS_SVH 
`define DEFS_SVH

`define IR_WIDTH 32
`define IR_ADDR_WIDTH $clog2(IR_WIDTH)

typedef struct packed {
  logic [1:0] alu_src_sel; 
  logic [32 - 1 :0] immediate;
} alu_info_t;

typedef enum logic[2:0]{
  ADD = 0,
  SLL,
  SLT,
  SLTU,
  XOR,
  SRL,
  OR,
  AND
} alu_op_t;

typedef enum logic[2:0]{
  EQ = 0,
  NE,
  LT = 4,
  GE,
  LTU,
  GEU
} branch_op_t;

typedef enum {
  R,
  I,
  S,
  B,
  U,
  J,
  None
} instr_type;

typedef enum logic[1:0] {
  DW = 0,
  DH,
  DB
} data_width ;

typedef struct packed {
  logic s;
  logic l;
  logic w;
  logic j;
  logic b;
  logic wb_src;
  logic sign;
  logic [1:0] dw; //TODO
  logic ignore_first_operand;
} control_signals_t;

`endif
