`timescale 1ns / 1ps

module rbuffer #(parameter Nbits = 32, parameter RLen= 1)(
    input clk,
    input [RLen-1:0] en,
    input [RLen-1:0] rst_n,
    input [Nbits-1:0] in,
    output logic [RLen - 1:0][Nbits-1:0] out
);
  genvar i;
  generate
    for(i = RLen - 1; i >= 0; i--) begin
      always @(posedge clk, negedge rst_n) begin
        if(!rst_n[i]) begin
          out[i] <= 0;
        end else if (en[i]) begin
          out[i] <= (i == RLen -1)? in: en[i+1]?out[i+1]:0;
        end       
      end
    end
  endgenerate

endmodule
