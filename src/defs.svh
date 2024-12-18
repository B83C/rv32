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
} data_width;

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
  logic [15:0] padding;
  logic [7:0] ctrl;
  logic [7:0] tx;
} uart_w;

typedef struct packed {
  logic [15:0] padding;
  logic [7:0] state;
  logic [7:0] rx;
} uart_r;

typedef struct packed {
  logic [15:0] x;
  logic [15:0] y;
} vga_ctrl;

typedef struct packed {
  logic [15:0] padding;
  logic [7:0] JB;
  logic [7:0] JC;
} gpio;

//Field size is to be multiple of word size
typedef struct packed {
  logic [3:0][7:0] sseg;
  gpio gpio;
  uart_w uart;
} io_registers_w;

typedef struct packed {
  uart_r uart;
} io_registers_r;

function [31:0] mask(data_width dw);
  case(dw) 
    DB: return {24'd0, {8{1'b1}}};
    DH: return {16'd0, {16{1'b1}}};
    DW: return {32{1'b1}};
    default: return 0;
  endcase
endfunction

function get_msb(data_width dw, logic[31:0] r);
  case(dw) 
    DB: return r[7];
    DH: return r[15];
    DW: return r[31];
    default: return 0;
  endcase
endfunction

`endif
