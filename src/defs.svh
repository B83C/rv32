`ifndef DEFS_SVH 
`define DEFS_SVH

`define IR_WIDTH 32
`define IR_ADDR_WIDTH $clog2(IR_WIDTH)

localparam IO_START = 32'(128 * 1024);  //128*1024
parameter MEM_ADDR_WIDTH = $clog2(128 * 1024 / 4);
parameter XLEN = 32;

parameter PC_START_ADDR = 32'h0;

// typedef logic[31:0]
typedef struct packed {
  logic [1:0] alu_src_sel; 
  logic [32 - 1 :0] immediate;
} alu_info_t;

parameter N_STAGES = 6; //Including prefetch
typedef logic [31:0] word_t;
typedef logic [4:0] reg_ind_t;
typedef enum logic[2:0]{
  PF = 0, //Prefetch
  F = 1 ,
  D = 2 ,
  E = 3 ,
  M = 4 ,
  W = 5
} stage_t;

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
  logic [15:0] leds;
  logic [7:0] JB;
  logic [7:0] JC;
} gpio_t;

//Field size is to be multiple of word size
typedef struct packed {
  logic [3:0][7:0] sseg;
  gpio_t gpio;
  uart_w uart;
} io_registers_w;

typedef struct packed {
  uart_r uart;
  gpio_t gpio;
} io_registers_r;

function [31:0] mask(data_width dw);
  case(dw) 
    DB: return {24'd0, {8{1'b1}}};
    DH: return {16'd0, {16{1'b1}}};
    DW: return {32{1'b1}};
    default: return 0;
  endcase
endfunction

function [32 / 8  - 1:0] maskb(data_width dw);
  case(dw) 
    DB: return 'b0001;
    DH: return 'b0011;
    DW: return 'b1111;
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

//Big to little endian
function [31:0] le(logic [31:0] r);
  return {<<8{r}};
endfunction

function [63:0] le32(logic [63:0] r);
  return {<<32{r}};
endfunction

function [31:0] be(logic [31:0] r);
  return {<<8{r}};
endfunction

typedef struct {
  word_t stream[N_STAGES - 1:0];
} pbuffer_entry_t ; 

typedef struct {
  word_t in;
} pbuffer_entry_in_t ; 

typedef struct packed {
  stage_t  start_stage;
  stage_t  end_stage;
} pbuffer_meta_t ; 

typedef union {
  word_t w;
  reg_ind_t r;
} mixed_t;

typedef enum {
  RESET,
  RUNNING
} pl_state_t;

`endif
