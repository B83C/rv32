`timescale 1ns / 1ps

module rbuffer #(parameter Nbits = 32 )(
    input clk,
    input en,
    input rst_n,
    input [Nbits-1:0] in,
    output logic [Nbits-1:0] out
);
  always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
      out <= 0;
    end else if (en) begin
      out <= in;
    end
  end
endmodule
