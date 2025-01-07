`timescale 1ns/1ps
`include "defs.svh"

module tb;

  logic clk = 0;
  logic rst_n = 1;

  // logic [31:0] addr, data2, memory;
  // control_signals_t cs;

  always #1 clk = ~clk;
  // risc_v rv32(.clk(clk), .rst_n(rst_n));
  // data_mem dm(clk, addr, data2, cs, memory);
  logic [3:0][1:0][7:0] tt = {
    {8'd1,8'd2},
    {8'd3,8'd4},
    {8'd5,8'd6},
    {<<8{8'd7,8'd0}}
  };

  initial begin
    $dumpfile("waveform.fst");
    $dumpvars(0, tb);

    $display("%h", tt[0][0], tt[0][1]);
    // cs.l = 0;
    // cs.s = 1;
    // cs.sign = 1;
    // addr = 0;
    // data2 = 32'h0102F3F4;
    // #2 cs.dw = DB;
    // #2 cs.dw = DH;
    // #2 cs.dw = DW;
    // #3 cs.l = 1;
    // cs.s = 0;
    // #2cs.dw = DB;
    // #2 cs.dw = DH;
    // #3 cs.l = 0;
    // cs.s = 1;
    // cs.sign = 0;
    // addr = 0;
    // data2 = 32'h0102F3F4;
    // #2 cs.dw = DB;
    // #2 cs.dw = DH;
    // #2 cs.dw = DW;
    // #3 cs.l = 1;
    // cs.s = 0;
    // #2cs.dw = DB;
    // #2 cs.dw = DH;
    // #2 cs.dw = DW;
    // 

   	 #300 $finish();
  end
// always #1 
// inital begin
// end

endmodule
