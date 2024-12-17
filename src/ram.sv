`timescale 1ns/1ps

module ram(
  input rclk,
  input [128 * 1024 / 4096 - 1:0] raddr,
  input wclk, 
  input [128 * 1024 / 4096 - 1:0] waddr,
  input [4096-1:0] wdata,
  output logic [4096-1:0] rdata
);
  logic [128*1024 / 4096 - 1: 0][4096 - 1 :0] ram;

  always @(posedge rclk) begin
    rdata <= ram[raddr];
  end

  always @(posedge wclk) begin
    ram[waddr] <= wdata;
  end
endmodule 
