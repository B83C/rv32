`timescale 1ns / 1ps
`include "defs.svh"

module mmio (
    input clk,
    input [31:0] addr,
    input [31:0] wdata,
    input mem_rw,
    input io_en,
    input data_width dw,
    output logic [31:0] io_read,
    input io_registers_r io_r,
    output io_registers_w io_w
);


  wire io_rw;
  //input
  assign io_rw = (addr >= IO_START + (IO_START/2)); //0: Read, !: Write
  // assign io_en = (addr >= IO_START && mem_en);

  //output
  // assign mem_read_mux = io_en_buffer? mem_read_data: io_read;


  // always @(posedge clk) begin
  //   io_en_buffer <= io_en;
  // end

  always @(posedge clk) begin
    if (io_en && !mem_rw && !io_rw) begin
      io_read <= io_r[addr[15:0] * 8 +: 32] & mask(dw);
      $display("[io] Reading from io_register at %h, data: %h", addr, io_r[addr[15:0] * 8 +: 32]& mask(dw));
    end
  end

  always_ff @(posedge clk) begin
    // if (io_rw) begin
    //   $display("io_rw triggered io_en %d cs_o[E].s %d cs %h addr %h", io_en, cs_o[E].s,cs, addr);
    // end
    if (io_en && mem_rw && io_rw) begin
      case(dw)
        DB:  io_w[addr[15:0] * 8 +: 8] <= wdata[8-1:0];
        DH:  io_w[addr[15:0] * 8 +: 16] <= wdata[16-1:0];
        DW:  io_w[addr[15:0] * 8 +: 32] <= wdata[32-1:0];
        default: begin end
      endcase
      $display("[io %d] Writing to io_register at %h, data: %h", $time(), addr, wdata);
    end
  end
endmodule
