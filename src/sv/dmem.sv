`timescale 1ns/1ps

module dmem #(
  RAM_SIZE = 256 * 1024
) (
  input clk,
  input [$clog2(RAM_SIZE) - 1:0] addr,
  input [31:0] wd,
  input we,
  output [31:0] rd
);

  logic [31:0] ram [RAM_SIZE - 1:0];
  always @(posedge clk) begin
    if (we) begin
      ram[addr] <= wd;
    end
  end

  assign rd =  ram[addr];

endmodule
