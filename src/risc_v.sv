`timescale 1ns / 1ps
`include "defs.svh"

module risc_v (
    input clk,
    input rst_n,
    output [7:0]JB,
    output [7:0]JC,
    input uart_rx, 
    output uart_tx
    //io signals
);

  logic io_rw;
  io_registers_r io_r;
  io_registers_w io_w;

  wire [31:0] pc_addr;
  wire [31:0] instr;
  wire [31:0] mem_write_addr;
  wire [31:0] mem_write_data, mem_read_data;
  wire control_signals_t cs_m;
  wire [31:0] mem_read_mux;
  wire mem_en;

  //io_signals 

  // assign io_r.gpio.JB = JB;
  gpio gpio_rm (
    .JB(io_r.gpio.JB),
    .JC(io_r.gpio.JC),
    .JB_o(JB),
    .JC_o(JC)
  );


  uart_rx uart_rm (
     .rx_data_valid(io_r.uart.state[0]),
     .rx_data(io_r.uart.rx),
     .rx(uart_rx),
     .rx_ctrl(io_w.uart.ctrl[1:0]),
     .rx_ready(io_r.uart.state[1]),
     .clk(clk),
     .rst(!rst_n)
    );

  uart_tx uart_wm (
     .tx_data_valid(io_w.uart.ctrl[2]),
     .tx_data(io_w.uart.tx),
     .tx(uart_tx),
     // .tx_ctrl(io_w.uart.ctrl[1:0]),
     .tx_ready(io_r.uart.state[2]),

     .clk(clk),
     .rst(!rst_n)
    );

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
