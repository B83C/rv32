`timescale 1ns / 1ps
`include "defs.svh"

module vga (
    input clk,
    input  clk_108,
    output logic [3:0] r, g, b,
    output hsync,
    vsync,
    vga_active,
    input [31:0] mem_write_addr,
    input word_t mem_write_data,
    input mem_rw,
    input io_en,
    input data_width dw
);
  logic [$clog2(SCALE_X) - 1:0] scale_cntr_x = 0;
  logic [$clog2(SCALE_Y) - 1:0] scale_cntr_y = 0;

  wire vga_buffer = (mem_write_addr >= VGA_BUF_START);

  logic [12:0] fb_addr = 0;
  logic [7:0] fb_chr;

  ram_sdp #(8, 64*128) text_buff(
    .clk_w(clk),
    .we(io_en && mem_rw && vga_buffer),
    .addr_w(13'(mem_write_addr)),
    .data_w(8'(mem_write_data)),

    .clk_r(clk_108),
    .addr_r(fb_addr),
    .data_r(fb_chr)
  );

  logic [$clog2(C_W) - 1:0] x_cntr = 0;
  logic [$clog2(C_H) - 1:0] y_cntr = 0;
  logic [$clog2(HCC) - 1:0] c_x = 0;
  logic [$clog2(VCC) - 1:0] c_y = 0;
  logic [C_H - 1 : 0][C_W - 1 : 0] char_buf;
  rom #(
      .WIDTH(C_W * C_H),
      .DEPTH(128),
      .binaryFile("ascii.rom")
  ) ascii (
      .addr(fb_chr[6:0]),
      .data(char_buf)
  );
  wire [$clog2(1280):0] x;
  wire [$clog2(1024):0] y;

  vga_ctrl vga_c (
      .pclk(clk_108),
      .x(x),
      .y(y),
      .hsync(hsync),
      .vsync(vsync),
      .active(vga_active)
  );

  always @(posedge clk) begin
    if (io_en && mem_rw && vga_buffer) begin
      $display("[io %d] Writing to vga at x: %h y: %h, data: %h", $time(), mem_write_addr[6:0], mem_write_addr[12:7], mem_write_data);
    end
  end

  wire x_last_scale = scale_cntr_x == $size(scale_cntr_x)'(SCALE_X - 1);
  wire x_slast_scale = scale_cntr_x == $size(scale_cntr_x)'(SCALE_X - 2);
  wire x_cntr_last = x_cntr == $size(x_cntr)'(C_W - 1);
  wire x_chr_last = c_x == $size(c_x)'(HCC - 1);
  wire y_last_scale = scale_cntr_y == $size(scale_cntr_y)'(SCALE_Y - 1);
  wire y_slast_scale = scale_cntr_y == $size(scale_cntr_y)'(SCALE_Y - 2);
  wire y_cntr_last = y_cntr == $size(y_cntr)'(C_H - 1);
  wire y_chr_last = c_y == $size(c_y)'(VCC - 1);

  always @(posedge clk_108) begin
    {r, g, b} <= 12'b0;
    if (vga_active) begin
      if (x < $size(x)'(x_bound) && y < $size(y)'(y_bound)) begin
        scale_cntr_x <= scale_cntr_x + 1;
        if (x_last_scale) begin
          scale_cntr_x <= 0;
          x_cntr <= x_cntr + 1;
          if (x_cntr_last) begin
            x_cntr <= 0;
            c_x <= c_x + 1;
            if (x_chr_last) begin
              c_x <= 0;
              scale_cntr_y <= scale_cntr_y + 1;
              if (y_last_scale) begin
                scale_cntr_y <= 0;
                y_cntr <= y_cntr + 1;
                if (y_cntr_last) begin
                  y_cntr <= 0;
                  c_y <= c_y + 1;
                  if (y_chr_last) begin
                    c_y <= 0;
                  end                
                end
              end else if (y_slast_scale && y_cntr_last) begin
                if (y_chr_last) begin
                  fb_addr <= 0;
                end else begin
                  fb_addr <= (13'(c_y) + 1) * 128;
                end
              end            
            end          
          end
        end else if (x_slast_scale & x_cntr_last) begin
          if (x_chr_last) begin
            fb_addr <= (13'(c_y)) * 128;
          end else begin
            fb_addr <= (13'(c_y)) * 128 + 13'(c_x) + 1;
          end
        end
        if (char_buf[y_cntr][x_cntr]) begin
          {r, g, b} <= {12{char_buf[y_cntr][x_cntr] ^ fb_chr[7]}};
        end
      end
    end
  end
endmodule
