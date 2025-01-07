
`timescale 1ns / 1ps
`include "defs.svh"

module tb5;

  logic clk, rst_n;
  pipeline_i p (clk);

  always #1 clk <= ~clk;

  initial begin
    $dumpfile("waveform.fst");
    $dumpvars(0, tb);
    clk = 0;
    p.stalls[F] = 0;
    p.stalls[D] = 0;
    p.stalls[E] = 0;
    rst_n = 1;
    p.flushes[F] = 0;
    p.flushes[D] = 0;
    p.flushes[E] = 0;
    #4 p.stalls[F] = 1;
    p.stalls[D] = 0;
    p.stalls[E] = 0;
    #4 p.stalls[F] = 0;
    p.stalls[D] = 0;
    p.stalls[E] = 0;
    #4 p.stalls[F] = 0;
    p.stalls[D] = 1;
    p.stalls[E] = 0;
    #4 p.stalls[F] = 0;
    p.stalls[D] = 0;
    p.stalls[E] = 0;
    #4 p.stalls[F] = 0;
    p.stalls[D] = 0;
    p.stalls[E] = 1;
    #4 p.stalls[F] = 0;
    p.stalls[D] = 0;
    p.stalls[E] = 0;
    #4 p.flushes[F] = 1;
    p.flushes[D] = 0;
    p.flushes[E] = 0;
    #4 p.flushes[F] = 0;
    p.flushes[D] = 0;
    p.flushes[E] = 0;
    #4 p.flushes[F] = 0;
    p.flushes[D] = 1;
    p.flushes[E] = 0;
    #4 p.flushes[F] = 0;
    p.flushes[D] = 0;
    p.flushes[E] = 0;
    #4 p.flushes[F] = 0;
    p.flushes[D] = 0;
    p.flushes[E] = 1;
    #4 p.flushes[F] = 0;
    p.flushes[D] = 0;
    p.flushes[E] = 0;
    #200 $finish();
  end

  word_t pc;
  inc #(logic [$size(
pc
)-1:0], 1) im_0 (
      clk,
      pc
  );

  reg_ind_t rs1;
  inc #(logic [$size(
rs1
)-1:0], 1) im_1 (
      clk,
      rs1
  );

  pbuffer #(.Nitems(2), .meta({
        {W, W},
        {F, W}
      })
  ) rp (
      clk, rst_n, p.stalls, p.flushes,
      '{ pc, pc },
      '{ p.pc, p.mem_read_data }
  );

  pbuffer #( 1, reg_ind_t, .meta({
        {F, W}
  })) rp1 ( clk, rst_n, p.stalls, p.flushes,
      '{ rs1 },
      '{ p.rs1 }
  );

  `define SB(x, t, y, z, w) \
  pbuffer #( 1, t, .meta({ \
    y \
  })) x ( clk, rst_n, p.stalls, p.flushes, \
      '{ z }, \
      '{ w } \
  );

  `SB(rp2, reg_ind_t, {F, W}, rs1, p.rs2);

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
