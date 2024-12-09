`timescale 1ns / 1ps
`include "defs.svh"

module risc_v (
    input clk,
    input rst_n
);
  wire [31:0] pc_addr;
  wire [31:0] instr;
  wire [31:0] mem_write_addr;
  wire [31:0] mem_write_data;
  wire control_signals_t cs_m;
  wire [31:0] mem_read_data;

  instr_src instr_mem(
      .addr (pc_addr),
      .instr(instr)
  );

  pipeline_unit pu1 (
      .clk(clk),
      .rst_n(rst_n),
      .instr(instr),
      .data_mem(mem_read_data),
      .pc_addr(pc_addr),
      .mem_write_addr(mem_write_addr),
      .mem_write_data(mem_write_data),
      .cs_om(cs_m)
  );

  data_src data_mem(
      .clk(clk),
      .addr(mem_write_addr),
      .wdata(mem_write_data),
      .cs(cs_m),
      .memory(mem_read_data)
  );
endmodule
