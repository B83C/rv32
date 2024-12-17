`timescale 1ns / 1ps
`include "defs.svh"

module risc_v (
    input clk,
    input rst_n,
  //io signals
    output [15:0] segment_data,

    input [7:0] uart_r_data,
    input uart_r_state,
    output [1:0] uart_r_ctrl,

    output [7:0]uart_t_data,
    input uart_t_state,
    output [1:0]uart_t_ctrl,

    output h_sync,
    output v_sync,
    output [15:0] x,
    output [15:0] y,
    output video_active
    
    
    );

  wire [31:0] pc_addr;
  wire [31:0] instr;
  wire [31:0] mem_write_addr;
  wire [31:0] mem_write_data;
  wire control_signals_t cs_m;
  wire [31:0] out_bus;
  wire mem_en;



  //io_signals 



  instr_src instr_mem(
      .addr (pc_addr),
      .instr(instr)
  );

  pipeline_unit pu1 (
      .clk(clk),
      .rst_n(rst_n),
      .instr(instr),
      .data_mem(out_bus),
      .pc_addr(pc_addr),
      .mem_write_addr(mem_write_addr),
      .mem_write_data(mem_write_data),
      .cs_om(cs_m)
  );
  mmio mmio1(
      .clk(clk),
      .addr(mem_write_addr),
      .wdata(mem_write_data),
      .cs(cs_m),
      .out_bus(out_bus),
      .mem_en(mem_en),

      .memory(mem_read_data),


      .segment_data(segment_data),

      .uart_r_data(uart_r_data),
      .uart_r_state(uart_r_state),
      .uart_r_ctrl(uart_r_ctrl),

      .uart_t_data(uart_t_data),
      .uart_t_state(uart_t_state),
      .uart_t_ctrl(uart_t_ctrl),

      .h_sync(h_sync),
      .v_sync(v_sync),
      .x(x),
      .y(y),
      .video_active(video_active)


  ); 

  data_src data_mem(
      .clk(clk),
      .mem_en(mem_en),
      .addr(mem_write_addr),
      .wdata(mem_write_data),
      .cs(cs_m),
      .memory(mem_read_data)
  );
endmodule
