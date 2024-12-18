`ifndef DEFS_SVH 
`define DEFS_SVH

`define IR_WIDTH 32
`define IR_ADDR_WIDTH $clog2(IR_WIDTH)

parameter XLEN = 32;

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

typedef enum logic[2:0]{
  MUL,
  MULH,
  MULHSU,
  MULHU,
  DIV,
  DIVU,
  REM,
  REMU
} mul_op_t;

typedef enum {
  R,
  I,
  S,
  B,
  U,
  J,
  None
} instr_type;

typedef enum logic [1:0]{
  RAW,
  ALU,
  MEM,
  WB
} register_data_sel;

typedef enum logic[1:0] {
  DW = 0,
  DH,
  DB
} data_width ;

typedef struct packed {
  //RV32I
  logic s;
  logic l;
  logic w;
  logic j;
  logic b;
  logic a; //ALU
  logic sign;
  logic sign_ex;
  logic [1:0] dw; //TODO
  logic ignore_first_operand;

  //RV32M
  logic m;
} control_signals_t;

typedef struct packed {
  logic [7:0] tx;
  logic [7:0] ctrl;
  logic [15:0] padding;
} uart_w;

typedef struct packed {
  logic [7:0] rx;
  logic [7:0] state;
  logic [15:0] padding;
} uart_r;

typedef struct packed {
  logic [15:0] x;
  logic [15:0] y;
} vga_ctrl;

//Field size is to be multiple of word size
typedef struct packed {
  logic [3:0][7:0] sseg;
  uart_w uart;
} io_registers_w;

typedef struct packed {
  uart_r uart;
} io_registers_r;

parameter io_r_w_cnt = $size(io_registers_w)/32;
parameter io_r_r_cnt = $size(io_registers_r)/32;
typedef logic [31:0]io_registers_w_raw[io_r_w_cnt - 1:0];
typedef logic [31:0]io_registers_r_raw[io_r_r_cnt - 1:0];

`endif
