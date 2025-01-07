`timescale 1ns/1ps
`include "defs.svh"

module tb3;

  logic clk = 0;
  logic rst_n = 1;

  logic [31:0] addr, data2, memory;
  control_signals_t cs;

  always #1 clk = ~clk;

  word_t r1, r2;
  wire word_t rd;
  mul_op_t op;
  logic en, rst;
  wire mul_busy;
  multiplier m(.*);

  initial begin
    rst = 0;
    en = 1;
    $dumpfile("waveform.fst");
    $dumpvars(0, tb);
    r1 = -32'd1024;
    r2 = 32'h01020304;
    op = MUL;
    #6 op = MULH;
    #6 op = MULHSU;
    #6 op = MULHU;
    #6 op = DIV;
    #6 op = DIVU;
    #6 op = REM;
    #6 op = REMU;

    // #2 cs.dw = DW;
   	 #300 $finish();
  end
// always #1 
// inital begin
// end

endmodule
