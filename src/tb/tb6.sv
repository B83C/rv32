
`timescale 1ns / 1ps
`include "defs.svh"

module tb6;

  logic clk, rst_n;
  logic [31:0] pc_addr;
  logic read_instr;
  logic [31:0] instr;
  logic instr_ready;

  logic mem_en;
  logic [31:0] addr;
  logic [31:0] wdata;
  control_signals_t cs;
  logic [31:0] memory; 
  pipeline_i po (clk);
  data_src ds (.*);

  always #1 clk <= ~clk;

  initial begin
    $dumpfile("waveform.fst");
    $dumpvars(0, tb);
    pc_addr = 0;
    read_instr = 0;
    instr = 0;

    mem_en = 1;
    addr = 'h1011e;
    po.alu_res[M]= 'h1011e;
    wdata = 'h7565;
    cs.dw = DH;
    po.cs[M].dw = DH;
    cs.s = 1;
    po.cs[M].s = 1;

    #5 mem_en = 1;
    cs.s = 0;
    po.cs[M].s = 0;
    addr = 'h1011e;
    po.alu_res[M]= 'h1011e;
    wdata = 'h1;
    cs.dw = DH;
    po.cs[M].dw = DH;
    cs.l = 1;
    po.cs[M].l = 1;

    #100 $finish();
  end

endmodule 
