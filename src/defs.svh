`ifndef DEFS_SVH
`define DEFS_SVH

`define IR_WIDTH 32
`define IR_ADDR_WIDTH $clog2(IR_WIDTH)

parameter D_OFF_X = 700;
parameter D_OFF_Y = 20;
parameter int C_W = 8;
parameter int C_H = 8;
parameter int SCALE_X = 2;
parameter int SCALE_Y = 2;

parameter int HCC = 1280 / (C_W * SCALE_X);
parameter int VCC = 1024 / (C_H * SCALE_Y);
parameter int x_bound = HCC * C_W * SCALE_X;
parameter int y_bound = VCC * C_H * SCALE_Y;

localparam IO_START = 32'(128 * 1024);  //128*1024
localparam VGA_BUF_START = 32'(256 * 1024);  //128*1024
parameter MEM_ADDR_WIDTH = $clog2(128 * 1024 / 4);
parameter XLEN = 32;

parameter PC_START_ADDR = 32'h0;

// typedef logic[31:0]
typedef struct packed {
  logic [1:0] alu_src_sel;
  logic [32 - 1 : 0] immediate;
} alu_info_t;

parameter N_STAGES = 6;  //Including prefetch
typedef logic [XLEN - 1:0] word_t;
typedef logic [2*XLEN - 1:0] dword_t;
typedef logic signed [2*XLEN - 1:0] sdword_t;
typedef logic [4:0] reg_ind_t;

typedef enum logic [6:0] {
  OPC_OP_IMM   = 7'b0010011,
  OPC_LUI      = 7'b0110111,
  OPC_AUIPC    = 7'b0010111,
  OPC_OP       = 7'b0110011,
  OPC_JAL      = 7'b1101111,
  OPC_JALR     = 7'b1100111,
  OPC_BRANCH   = 7'b1100011,
  OPC_LOAD     = 7'b0000011,
  OPC_STORE    = 7'b0100011,
  OPC_MISC_MEM = 7'b0001111,
  OPC_SYSTEM   = 7'b1110011
} opcode_t;

typedef enum logic [2:0] {
  PF = 0,  //Prefetch
  F  = 1,
  D  = 2,
  E  = 3,
  M  = 4,
  W  = 5
} stage_t;

typedef enum logic [2:0] {
  ADD  = 0,
  SLL,
  SLT,
  SLTU,
  XOR,
  SRL,
  OR,
  AND
} alu_op_t;

typedef struct packed {
  logic ex;
  alu_op_t op;
} alu_op_ex_t;

typedef enum logic [2:0] {
  EQ  = 0,
  NE,
  LT  = 4,
  GE,
  LTU,
  GEU
} branch_op_t;

typedef enum logic [2:0] {
  MUL,
  MULH,
  MULHSU,
  MULHU,
  DIV,
  DIVU,
  REM,
  REMU
} mul_op_t;

typedef enum logic [2:0] {
  R,
  I,
  S,
  B,
  U,
  J
} instr_type;

typedef enum logic [1:0] {
  RAW,
  ALU,
  MEM,
  WB
} register_data_sel;

typedef enum logic [1:0] {
  WB_PASSTHROUGH,
  WB_MUL_RES,
  WB_M,
  WB_W
} alu_reg_src_t;

typedef enum logic [1:0] {
  ALU_S1_0  = 0,
  ALU_S1_PC,
  ALU_S1_R1
} alu_src_sel_1_t;

typedef enum logic [1:0] {
  ALU_S2_4   = 0,
  ALU_S2_IMM,
  ALU_S2_R2
} alu_src_sel_2_t;

typedef enum logic [0:0] {
  AGU_S1_R1 = 0,
  AGU_S1_PC
} agu_src_sel_t;


typedef enum logic [1:0] {
  DB = 0,
  DH,
  DW
} data_width;

typedef struct packed {
  //RV32I
  logic s;
  logic l;
  logic w;
  logic b;
  logic a;  //ALU
  logic sign_ex;
  logic [1:0] dw;  //TODO

  //RV32M
  logic m;
} control_signals_t;

typedef struct packed {
  logic [15:0] padding;
  logic [7:0]  ctrl;
  logic [7:0]  tx;
} uart_w;

typedef struct packed {
  logic [15:0] padding;
  logic [7:0]  state;
  logic [7:0]  rx;
} uart_r;

typedef struct packed {
  logic [15:0] x;
  logic [15:0] y;
} vga_ctrl;

typedef struct packed {
  logic [15:0] leds;
  logic [7:0]  JB;
  logic [7:0]  JC;
} gpio_t;

//Field size is to be multiple of word size
typedef struct packed {
  logic [3:0][7:0] sseg;
  gpio_t gpio;
  gpio_t gpio_mode;
  uart_w uart;
} io_registers_w;

typedef struct packed {
  uart_r uart;
  gpio_t gpio;
  logic [7:0] vga_active;
} io_registers_r;

typedef enum logic [1:0] {
  RESET   = 0,
  WAIT,
  RUNNING
} pl_state_t;

function [31:0] mask(data_width dw);
  case (dw)
    DB: return {24'd0, {8{1'b1}}};
    DH: return {16'd0, {16{1'b1}}};
    DW: return {32{1'b1}};
    default: return 0;
  endcase
endfunction

function [32 / 8  - 1:0] maskb(data_width dw);
  case (dw)
    DB: return 'b0001;
    DH: return 'b0011;
    DW: return 'b1111;
    default: return 0;
  endcase
endfunction

`endif

