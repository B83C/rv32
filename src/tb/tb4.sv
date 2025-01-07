`timescale 1ns/1ps
`include "defs.svh"

module tb4;
  logic stall_f, stall_d, stall_e;
  logic flush_f, flush_d, flush_e;
 
  logic [31:0] pc, pc_f, pc_d, pc_e, pc_m, pc_w;
  logic [4:0] rs1, rs1_e;
  logic [4:0] rs2, rs2_e;

  logic [4:0] rd, rd_e, rd_m, rd_w;

  logic [31:0] r1_e_mux, r2_e_mux, r2_e_mux_m;
  logic [31:0] r1, r1_e;
  logic [31:0] r2, r2_e;

  logic [31:0] imm, imm_e;

  logic [2:0] func3, func3_e;
  logic [1:0] alu_src_sel, alu_src_sel_e;

  control_signals_t cs, cs_e, cs_m, cs_w;

  logic [31:0] mul_res, mul_res_m;
  logic [31:0] alu_mux_input_1;
  logic [31:0] alu_mux_input_2;
  logic [31:0] alu_res, alu_res_m, alu_res_w;

  logic branch_hit;
  logic [31:0] jmp_addr;
  logic overflow, zero;
  logic mul_busy;
  register_data_sel r1_e_sel, r2_e_sel;

  logic clk, rst_n;

  always #1 clk <= ~clk;

  initial begin
    $dumpfile("waveform.fst");
    $dumpvars(0, tb);
    clk = 0;
    stall_f = 0; stall_d = 0; stall_e = 0;
    rst_n = 1;
    flush_f = 0; flush_d = 0; flush_e = 0;
    #4 stall_f = 1; stall_d = 0; stall_e = 0;
    #4 stall_f = 0; stall_d = 0; stall_e = 0;
    #4 stall_f = 0; stall_d = 1; stall_e = 0;
    #4 stall_f = 0; stall_d = 0; stall_e = 0;
    #4 stall_f = 0; stall_d = 0; stall_e = 1;
    #4 stall_f = 0; stall_d = 0; stall_e = 0;
    #4 flush_f = 1; flush_d = 0; flush_e = 0;
    #4 flush_f = 0; flush_d = 0; flush_e = 0;
    #4 flush_f = 0; flush_d = 1; flush_e = 0;
    #4 flush_f = 0; flush_d = 0; flush_e = 0;
    #4 flush_f = 0; flush_d = 0; flush_e = 1;
    #4 flush_f = 0; flush_d = 0; flush_e = 0;
    #200 $finish();
  end

  inc #( logic[$size(pc)-1:0], 1) im_0 (clk, pc);
  inc #( logic[$size(rs1)-1:0], 10) im_1 (clk, rs1);
  inc #( logic[$size(rs2)-1:0], 11) im_2 (clk, rs2);
  inc #( logic[$size(rd)-1:0], 12) im_3 (clk, rd);
  inc #( logic[$size(cs)-1:0], 13) im_4 (clk, cs);
  inc #( logic[$size(r1)-1:0], 14) im_5 (clk, r1);
  inc #( logic[$size(r2)-1:0], 15) im_6 (clk, r2);
  inc #( logic[$size(imm)-1:0], 16) im_7 (clk, imm);
  inc #( logic[$size(func3)-1:0], 0) im_8 (clk, func3);
  inc #( logic[$size(alu_src_sel)-1:0], 1) im_9 (clk, alu_src_sel);

  parameter integer start_pos[10 - 1:0 ] = '{0,2,2,2,2,2,2,2,2,2};
  rbuffer_p #(
    .MRLen(5),
    .Nitems(10),
    .start(start_pos)
  )
  rp1 (
    .clk(clk),
    .grst_n(rst_n),
    .stall('{0:stall_f, 1:stall_d, 2:stall_e}),
    .flush('{0:flush_f, 1:flush_d, 2:flush_e}),
    .in({
      32'(pc),
      32'(rs1),
      32'(rs2),
      32'(rd),
      32'(cs),
      32'(r1),
      32'(r2),
      32'(imm),
      32'(func3),
      32'(alu_src_sel)
    }),
    .stream('{
      '{0:32'(pc_f), 1:32'(pc_d), 2:32'(pc_e), 3:32'(pc_m)},
      '{2:32'(rs1_e), default: 32'd0},
      '{2:32'(rs2_e), default: 32'd0},
      '{2:32'(rd_e), default: 32'd0},
      '{2:32'(cs_e), default: 32'd0},
      '{2:32'(r1_e), default: 32'd0},
      '{2:32'(r2_e), default: 32'd0},
      '{2:32'(imm_e), default: 32'd0},
      '{2:32'(func3_e), default: 32'd0},
      '{2:32'(alu_src_sel_e), default: 32'd0}
    })
  );
endmodule 

module inc #(
  parameter type T = int,
  parameter T INITIAL = 0
) (
  input clk,
  output T cntr
);

  always @(posedge clk) begin
    cntr <= cntr + 1;
  end

  initial begin 
    cntr = INITIAL;
  end
  
endmodule
