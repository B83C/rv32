`timescale 1ns / 1ps

//                ------------>
// | in | out[N-1] | out[N-2] | out[N-3] ... | out[0] |
//                ------------>
// | en[N] | en[N-1] | en[N-2] | en[N-3] ... | en[0] |
// 
// if the correstponding enable bit is set, on the next clock, the result will be shifted into the right slot. Otherwise, it does not accept shift-ins from the left. However, if it happens that a slot has a disabled slot on its left, it reads 0 when shifting is applied.
module rbuffer #(parameter Nbits = 32, parameter RLen= 1)(
    input clk,
    input rst_ng, //global reset
    input [RLen:0] en,
    input [RLen-1:0] clr,
    input [Nbits-1:0] in,
    output logic [RLen - 1:0][Nbits-1:0] out
);
  genvar i;
  generate
    for(i = RLen - 1; i >= 0; i--) begin
      always @(posedge clk, negedge rst_ng) begin
        if(!rst_ng | !clr[i]) begin
          out[i] <= 0;
        end else if (en[i]) begin
          out[i] <= (i == RLen -1)? in: en[i+1]? out[i+1]:0;
        end        
      end
    end
  endgenerate

endmodule
