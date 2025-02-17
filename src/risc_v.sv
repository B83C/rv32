`timescale 1ns / 1ps
`include "defs.svh"

module risc_v (
    input clk_raw,
    input rst,
    output [7:0] JB,
    output [7:0] JC,
    output logic [7:0] led, 
    input urx,
    output utx
    //io signals
);

  
    logic clk_66;
    wire clk = clk_66;

  clk_mcmm clk_m
   (
    // Clock out ports
    .clk_66(clk_66),     // output clk_66
    // Status and control signals
    .reset(0), // input reset
    .locked(0),       // output locked
   // Clock in ports
    .clk_in1(clk_raw)      // input clk_in1
);

  logic io_rw;
  io_registers_r io_r;
  io_registers_w io_w;

  wire [31:0] pc_addr;
  wire [31:0] instr;
  wire instr_ready, data_ready, read_instr;
  wire [31:0] mem_write_addr;
  wire [31:0] mem_write_data, mem_read_data, io_read;
  wire mem_rw;
  wire data_width dw;
  wire control_signals_t cs_o [N_STAGES-1:0];
  wire [31:0] mem_read_mux;
  wire mem_en, io_en;

  //io_signals 

  assign io_r.gpio.JB = JB;
  assign io_r.gpio.JC = JC;
  assign led = io_w.gpio.leds[7:0];

  // gpio_m gpio_rm (
  //     .p1(io_r.gpio_b.JB),
  //     .p2(io_r.gpio_b.JC),
  //     .p1_o(JB),
  //     .p2_o(JC)
  // );

  uart_rx uart_rm (
      .rx_data_valid(io_r.uart.state[0]),
      .rx_data(io_r.uart.rx),
      .rx(urx),
      .rx_ctrl(io_w.uart.ctrl[1:0]),
      .rx_ready(io_r.uart.state[1]),
      .clk(clk),
      .rst(rst)
  );

  uart_tx uart_wm (
      .tx_data_valid(io_w.uart.ctrl[2]),
      .tx_data(io_w.uart.tx),
      .tx(utx),
      // .tx_ctrl(io_w.uart.ctrl[1:0]),
      .tx_ready(io_r.uart.state[2]),

      .clk(clk),
      .rst(rst)
  );

  pipeline_unit pu1 (
      .*
      // .mem_read_data(mem_read_mux)
  );

  mmio mmio1 (
      .*,
      .addr(mem_write_addr),
      .wdata(mem_write_data)
      // .mem_read_mux(mem_read_mux),
  );

  data_src data_mem (
      .*,
      .addr(mem_write_addr),
      .wdata(mem_write_data),
      .memory(mem_read_data)
  );
endmodule
