`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/03 09:25:54
// Design Name: 
// Module Name: adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CL_adder_4 (
    input [3:0] p,
    input [3:0] g,
    input c_in,
    output [3:0] c,
    output cp,
    cg
);
  assign c[0] = g[0] | (p[0] & c_in);
  assign c[1] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c_in);
  assign c[2] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & c_in);
  assign c[3] = cg | (cp & c_in);

  assign cg   = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]);
  assign cp   = p[3] & p[2] & p[1] & p[0];
endmodule

