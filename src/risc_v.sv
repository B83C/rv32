`timescale 1ns / 1ps
`include "defs.svh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/08 18:32:34
// Design Name: 
// Module Name: risc_v
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


module risc_v (
    input clk,
    input rst_n
);
  wire [31:0] addr;
  wire [31:0] instr;
  wire [31:0] wr_addr_s;
  wire [31:0] data2_s;
  wire control_signals_t cs;
  wire [31:0] data_mem;

  instr_register U1 (
      .addr (addr),
      .instr(instr)
  );
  datapath_1 U2 (
      .clk(clk),
      .rst_n(rst_n),
      .instr(instr),
      .data_mem(data_mem),
      .addr(addr),
      .wr_addr_s(wr_addr_s),
      .data2_s(data2_s),
      .cs_o(cs)
  );
  data_mem U3 (
      .clk(clk),
      .addr(addr),
      .data2(data2_s),
      .cs(cs),
      .memory(data_mem)
  );
endmodule
