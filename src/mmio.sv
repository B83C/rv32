`timescale 1ns / 1ps
`include "defs.svh"

module mmio (
    input clk,
    input [31:0] addr,
    input [31:0] wdata,
    input control_signals_t cs,
    output logic [31:0] mem_read_mux,
    output io_rw,
    input [31:0] mem_read_data,
    output mem_en,
    input io_registers_r io_r,
    output io_registers_w io_w
);

  localparam IO_START = 32'(128 * 1024);  //128*1024
  // assign mem_en = (addr[17]==1'b0);
  assign io_rw = (addr >= IO_START + (IO_START/2)); //0: Read, !: Write
  assign mem_en = !(addr >= IO_START && (cs.l | cs.s));
  assign mem_read_mux = mem_en? mem_read_data: io_read;

  logic [31:0] io_read;

  always @(negedge clk) begin
    if (!mem_en && cs.l && !io_rw) begin
      io_read <= io_r[addr[15:0] * 8 +: 32] & mask(data_width'(cs.dw));
      $display("[io] Reading from io_register at %h, data: %h", addr, io_r[addr[15:0] * 8 +: 32]& mask(data_width'(cs.dw)));
    end
  end

  always @(negedge clk) begin
    if (!mem_en && cs.s && io_rw) begin
      io_w[addr[15:0] * 8 +: 32] <= (io_w[addr[15:0] * 8 +: 32] & ~mask(data_width'(cs.dw))) | {wdata & mask(data_width'(cs.dw))};
      $display("[io] Writing to io_register at %h, data: %h", addr, wdata);
    end
  end
endmodule
