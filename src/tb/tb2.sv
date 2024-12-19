`timescale 1ns/1ps
`include "defs.svh"

module tb2;

  logic clk = 0;
  logic rst_n = 1;

  logic [31:0] addr, data2, memory;
  control_signals_t cs;

  logic [7:0] JB, JC;

  always #1 clk = ~clk;

  logic utx, urx;
  
  risc_v rv32(.clk(clk), .rst_n(rst_n),.utx(utx), .urx(urx), .JB(JB), .JC(JC)
  );
  // data_mem dm(clk, addr, data2, cs, memory);

  initial begin
    $dumpfile("waveform.fst");
    $dumpvars(0, tb);
    #1000 $finish();
  end
// always #1 
// inital begin
// end

endmodule
