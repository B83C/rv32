`timescale 1ns/1ps

module ram(
  input rclk,
  input [128 * 1024 / 4096 - 1:0] raddr,
  input wclk, 
  input [128 * 1024 / 4096 - 1:0] waddr,
  input [4096-1:0] wdata,
  output logic [4096-1:0] rdata
);
  reg [(128 * 1024) - 1:0][7:0] data;
  reg [7:0] unpacked_data [(128 * 1024) - 1:0];

  always @(posedge rclk) begin
    rdata <= ram[raddr];
  end

  always @(posedge wclk) begin
    ram[waddr] <= wdata;
  end
endmodule 
