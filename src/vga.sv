module vga(
  input clk,
  output hsync, vsync,
  output [3:0] r,g,b
);

  wire pclk;
  clk_108 c108 (.clk_in1(clk), .clk_out1(pclk), .reset(0), .locked(0));
  wire [$clog2(1280):0] x;
  wire [$clog2(1024):0] y;
  wire active;
  
  vga_ctrl vga_c (.pclk(pclk), .x(x), .y(y), .hsync(hsync), .vsync(vsync), .active(active));

  assign r = {4{active}} & x[3:0];
  assign g = {4{active}} & y[3:0];
  assign b = {4{active}} & x[3:0];

endmodule
