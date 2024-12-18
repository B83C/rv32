`timescale 1ns / 1ps
`include "defs.svh"

module risc_v (
    input clk,
    input rst_n,
    //io signals
    output io_rw,
    input io_registers_r_raw io_r,
    output io_registers_w_raw io_w
);

  wire [31:0] pc_addr;
  wire [31:0] instr;
  wire [31:0] mem_write_addr;
  wire [31:0] mem_write_data, mem_read_data;
  wire control_signals_t cs_m;
  wire [31:0] mem_read_mux;
  wire mem_en;

  //io_signals 

  pipeline_unit pu1 (
      .clk(clk),
      .rst_n(rst_n),
      .instr(instr),
      .pc_addr(pc_addr),
      .mem_read_data(mem_read_mux),
      .mem_write_addr(mem_write_addr),
      .mem_write_data(mem_write_data),
      .cs_om(cs_m)
  );

  mmio mmio1 (
      .clk(clk),
      .addr(mem_write_addr),
      .wdata(mem_write_data),
      .cs(cs_m),
      .mem_read_mux(mem_read_mux),
      .mem_en(mem_en),
      .mem_read_data(mem_read_data),
      .io_rw(io_rw),
      .io_r(io_r),
      .io_w(io_w)
  );

  data_src data_mem (
      .clk(clk),
      .pc_addr(pc_addr),
      .instr(instr),
      .mem_en(mem_en),
      .addr(mem_write_addr),
      .wdata(mem_write_data),
      .cs(cs_m),
      .memory(mem_read_data)
  );
endmodule
