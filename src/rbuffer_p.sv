`timescale 1ns / 1ps
`include "defs.svh"

//                ------------>
// | in | out[N-1] | out[N-2] | out[N-3] ... | out[0] |
//                ------------>
// | en[N] | en[N-1] | en[N-2] | en[N-3] ... | en[0] |
// 
// if the correstponding enable bit is set, on the next clock, the result will be shifted into the right slot. Otherwise, it does not accept shift-ins from the left. However, if it happens that a slot has a disabled slot on its left, it reads 0 when shifting is applied.
module rbuffer_p #(
    parameter MRLen = 6,
    parameter Nitems = 1,
    // parameter integer Nbits[Nitems - 1:0] = {32},
    parameter integer start[Nitems - 1:0] = '{default: 0}
    // parameter RLen = 6
) (
    input clk,
    input grst_n,  //global reset
    input stall[MRLen-2:0],
    input flush[MRLen-2:0],
    input logic [XLEN-1:0] in[Nitems-1:0],
    output logic [Nitems-1:0][MRLen-2:0][XLEN-1:0] stream
);

  genvar i, w;

  generate
    for (w = 0; w < Nitems; w++) begin : gen_slot
      for (i = 4 - start[w]; i >= 0; i--) begin : gen_item
        always @(posedge clk, negedge grst_n) begin
          if (!grst_n | flush[4 - (i)]) begin
            stream[w][4 - (i)] <= 0;
          end else if (!stall[4 - (i)]) begin
            if (i == 4 - start[w]) begin
              $display("Shifting in %h", in[w]);
            end
            stream[w][4 - (i)] <= (i < 4 && !stall[4 - (i+1)])?(i == 4 - start[w])?in[w]:stream[w][4 - (i+1)] : (i == 4 - start[w])?in[w]: 0;
          end
        end
      end
    end
  endgenerate
  // generate
  //   for (w = 0; w < Nitems; w++) begin : gen_slot
  //     for (i = start[w]; i < MRLen- 1; i++) begin : gen_item
  //       always @(posedge clk, negedge grst_n) begin
  //         if (!grst_n | flush[i]) begin
  //           stream[w][i] <= 0;
  //         end else if (!stall[i]) begin
  //           stream[w][i] <= (!stall[i-1])?(i == start[w])?in[w]:stream[w][i-1] : 0;
  //         end
  //       end
  //     end
  //   end
  // endgenerate

endmodule
