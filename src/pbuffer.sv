`timescale 1ns / 1ps
`include "defs.svh"

//                ------------>
// | in | out[N-1] | out[N-2] | out[N-3] ... | out[0] |
//                ------------>
// | en[N] | en[N-1] | en[N-2] | en[N-3] ... | en[0] |
// 
// if the correstponding enable bit is set, on the next clock, the result will be shifted into the right slot. Otherwise, it does not accept shift-ins from the left. However, if it happens that a slot has a disabled slot on its left, it reads 0 when shifting is applied.

module pbuffer #(
    parameter Nitems = 2,
    parameter type T = word_t,
    parameter stage_t [Nitems-1:0][1:0] meta = {{F, W}, {F, W}}
) (
    input clk,
    input grst,  //global reset
    input stall[N_STAGES-1:0], 
    input flush[N_STAGES-1:0],
    input T entries_in[Nitems-1:0],
    output T entries [Nitems-1:0][N_STAGES-1:0]
);

  // generate
  //   for (genvar w = 0; w < Nitems; w++) begin : item
  //     for (genvar i = int'(meta[w][1]); i <= meta[w][0] && i != int'(IN) && i < N_STAGES; i++) begin : stage
  //       always @(posedge clk, posedge grst) begin
  //         if (grst | flush[i]) begin
  //           entries[w][i] <= 0;
  //         end else if (!stall[i]) begin
  //           if (i == int'(meta[w][1])) begin
  //             entries[w][i] <= (i > 0 && !stall[(i-1)] || i == 0)?entries_in[w]:0;
  //           end else begin
  //             entries[w][i] <= (i > 0 && !stall[(i-1)])?entries[w][i-1] : 0;
  //           end
  //         end
  //       end
  //     end
  //   end
  // endgenerate

  // typedef struct {
  //   stage_t [1:0] meta;
  // } pipeline_t;


  // generate
  //   for (w = 0; w < Nitems; w++) begin : gen_slot
  //     for (i = start[w]; i < MRLen- 1; i++) begin : gen_item
  //       always @(posedge clk, negedge grst) begin
  //         if (!grst | flush[i]) begin
  //           stream[w][i] <= 0;
  //         end else if (!stall[i]) begin
  //           stream[w][i] <= (!stall[i-1])?(i == start[w])?in[w]:stream[w][i-1] : 0;
  //         end
  //       end
  //     end
  //   end
  // endgenerate

endmodule
