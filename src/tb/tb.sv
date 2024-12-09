`timescale 1ns/1ps

module tb;

  logic clk = 0;
  logic rst_n = 1;

  always #1 clk = ~clk;
  risc_v rv32(.clk(clk), .rst_n(rst_n));

  initial begin
    $dumpfile("waveform.fst");
    $dumpvars(0, tb);
  	 #300 $finish();
  end
// always #1 
// inital begin
// end

endmodule
