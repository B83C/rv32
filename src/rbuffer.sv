`timescale 1ns / 1ps

module rbuffer #(parameter Nbits = 32 )(
    input clk,
    input [Nbits-1:0] in,
    output logic [Nbits-1:0] out
);
  always @(posedge clk) begin
    out <= in;
  end
endmodule
