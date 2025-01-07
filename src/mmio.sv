`timescale 1ns / 1ps
`include "defs.svh"

module mmio #(
  VIRT = 0,
  ILA = 0
) (
    input clk,
    input [31:0] addr,
    input [31:0] wdata,
    input mem_rw,
    input io_en,
    input sign_ex,
    input data_width dw,
    output logic [31:0] io_read,
    output logic io_read_ready,
    input io_registers_r io_r,
    output io_registers_w io_w
    // output logic [$size(io_registers_w)-1:0] io_w,
);


  wire io_rw;
  //input
  assign io_rw = (addr >= IO_START + (IO_START/2)); //0: Read, !: Write

  wire vga_buffer = (addr >= VGA_BUF_START);

  always @(posedge clk) begin
    io_read_ready <= 0;
    if (io_en && !mem_rw && !vga_buffer) begin
      io_read_ready <= 1;
      case(dw)
        DB:  io_read <= 32'(signed'({sign_ex & io_r[addr[16:0] * 8 + 8 -1], io_r[addr[16:0] * 8 +: 8]}));
        DH:  io_read <= 32'(signed'({sign_ex & io_r[addr[16:0] * 8 + 16 -1], io_r[addr[16:0] * 8 +: 16]}));
        DW:  io_read <= io_r[addr[16:0] * 8 +: 32];
        default: begin end
      endcase
      // io_read <= io_r[addr[15:0] * 8 +: 32] & mask(dw);
      $display("[io] Reading from io_register at %h, data: %h", addr, io_r[addr[16:0] * 8 +: 32]& mask(dw));
    end
  end

  always_ff @(posedge clk) begin
    if (io_en && mem_rw && io_rw && !vga_buffer) begin
      case(dw)
        DB:  io_w[addr[16:0] * 8 +: 8] <= wdata[8-1:0];
        DH:  io_w[addr[16:0] * 8 +: 16] <= wdata[16-1:0];
        DW:  io_w[addr[16:0] * 8 +: 32] <= wdata[32-1:0];
        default: begin end
      endcase
      $display("[io %d] Writing to io_register at %h, data: %h", $time(), addr, wdata);
    end
  end

  generate
    if(ILA) begin
        ila_0 debug_probe2 (
      	.clk(clk), // input wire clk
        .trig_in(1),
      	.probe0(wdata), // input wire [31:0]  probe0  
      	.probe1(32'({addr})), // input wire [31:0]  probe1 
      	.probe2(32'({io_en, mem_rw, io_rw})), // input wire [31:0]  probe2
        .probe3(0),
        .probe4(0),
        .probe5(0),
        .probe6(0),
        .probe7(0)
      );
    end
  endgenerate
endmodule
