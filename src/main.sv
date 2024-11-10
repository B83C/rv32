// %include ips/c
`timescale 1ns/1ps
module main #(
)
(
    input clk,
    input [7:0] JB,
    output reg [3:0] r, g, b,
    inout [7:0] JC,
    // output [7:4] JC,
    output reg hsync, vsync
);
    vga vga_u0 (.clk(clk), .r(r), .g(g), .b(b), .hsync(hsync), .vsync(vsync));
    ov7670 cam (.clk(clk), .plk(JC[0]), .D(JB), .vsync(JC[1]), .hsync(JC[2]), .sda(JC[3]), .scl(JC[4]), .xclk(JC[5]), .pwdn(JC[6]), .rst(JC[7]));
    // assign JC = {1'b0, 1'b0, hsync, vsync};
endmodule
