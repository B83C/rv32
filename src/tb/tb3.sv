`timescale 1ns/1ps
`include "defs.svh"

module tb3;

  logic clk = 0;
  logic rst_n = 1;

  logic [31:0] addr, data2, memory;
  control_signals_t cs;

  always #1 clk = ~clk;

  logic [XLEN - 1:0] r1, r2;
  wire logic [XLEN - 1:0] rd;
  mul_op_t op;
  multiplier m(r1, r2, rd, op);

  initial begin
    $dumpfile("waveform.fst");
    $dumpvars(0, tb);
    r1 = -32'd1024;
    r2 = 32'h01020304;
    op = MUL;
    #1 op = MULH;
    #1 op = MULHSU;
    #1 op = MULHU;
    #1 op = DIV;
    #1 op = DIVU;
    #1 op = REM;
    #1 op = REMU;

    // #2 cs.dw = DW;
   	 #300 $finish();
  end
// always #1 
// inital begin
// end

endmodule
