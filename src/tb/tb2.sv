`timescale 1ns / 1ps
`include "defs.svh"

module tb2;

  logic clk = 0;
  logic rst = 0;

  logic [31:0] addr, data2, memory;
  control_signals_t cs;

  logic [7:0] JB, JC;
  logic utx, urx;
  logic [7:0] led;

  risc_v rv32 (
    .*
  );

  always #1 clk = ~clk;
  // initial begin
  //   integer stdin;
  //   stdin = $fopen("/dev/stdin", "r");  // Open standard input
  //   clk   = 0;
  //   if (stdin == 0) begin
  //     $error("Failed to open stdin.");
  //     $finish;
  //   end
  //   while (1) begin
  //     void'($fgetc(stdin));  // Wait for user input
  //     clk = ~clk;
  //     #1 clk = ~clk;
  //     $display("clk : %d %h", clk, rv32.pu1.write_back);
  //   end

  // end


  // data_mem dm(clk, addr, data2, cs, memory);

  initial begin
    $dumpfile("waveform.fst");
    $dumpvars(0, tb);
    #1000 rst = 1;
    #20 rst = 0;
    #2000 $finish();
  end
  // always #1 
  // inital begin
  // end

endmodule
