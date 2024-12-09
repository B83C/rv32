`timescale 1ns / 1ps
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
  wire lw_en_s;
  wire sw_en_s;
  wire lh_en_s;
  wire sh_en_s;
  wire lb_en_s;
  wire sb_en_s;
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
      .lw_en_s(lw_en_s),
      .sw_en_s(sw_en_s),
      .lh_en_s(lh_en_s),
      .sh_en_s(sh_en_s),
      .lb_en_s(lb_en_s),
      .sb_en_s(sb_en_s)
  );
  data_mem U3 (
      .clk(clk),
      .addr(addr),
      .data2(data2_s),
      .lw_en(lw_en_s),
      .sw_en(sw_en_s),
      .lh_en(lh_en_s)
      , .sh_en(sh_en_s),
      .lb_en(lb_en_s),
      .sb_en(sb_en_s),
      .data_mem(data_mem)
  );
endmodule
