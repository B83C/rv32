`timescale 1ns/1ps
`include "defs.svh"

module tb2;

  logic clk = 0;
  logic rst_n = 1;

  logic [31:0] addr, data2, memory;
  control_signals_t cs;

  always #1 clk = ~clk;

  logic uart_tx, uart_rx;
  
  risc_v rv32(.clk(clk), .rst_n(rst_n),.uart_tx(uart_tx), .uart_rx(uart_rx)
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
