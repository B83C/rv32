`timescale 1ns / 1ps
`include "defs.svh"

module risc_v #(
    VIRT = 0,
    ILA = 0
) (
    input clk_raw,
    input rst,
    inout logic [7:0] JB,
    inout logic [7:0] JC,
    inout logic [15:0] led,
    input urx,
    output utx,
    output logic hsync, vsync,
    output logic [3:0] r, g, b,
    //io signals


    input cpu_or_imem
);


  logic clk, clk_108;

  generate
    if (!VIRT) begin
      // logic clk_66;
      clk_mcmm clk_m (
          .clk_108 (clk_108),
          .reset  (rst),     
          .clk_in1(clk_raw)  
      );
      assign clk = clk_raw;
    end else begin
      assign clk = clk_raw;
      assign clk_108 = clk_raw;
    end
  endgenerate

  logic io_rw;
  io_registers_r io_r;
  io_registers_w io_w;

  wire [31:0] pc_addr;
  wire [31:0] instr;
  wire sign_ex, instr_ready, data_ready, io_read_ready, read_instr;
  wire [31:0] mem_write_addr;
  wire [31:0] mem_write_data, mem_read_data, io_read;
  wire mem_rw;
  wire data_width dw;
  wire control_signals_t cs_o[N_STAGES-1:0];
  wire [31:0] mem_read_mux;
  wire mem_en, io_en;
  logic [7:0] vga [VCC - 1:0][HCC - 1:0];

  wire [31:0] addr_rx;
  wire [31:0] instr_data_rx;
  wire [7:0] data_in_rx;
  wire rx_data_valid;
  wire w_ready_rx;
  wire pos_instr_w;
  wire neg_instr_w;





  //io_signals 

  assign io_r.gpio.JC = JC;
  assign io_r.gpio.JB = JB;

  generate
    for (genvar i = 0; i < 16; i++) begin
      assign led[i] = io_w.gpio_mode.leds[i]?io_w.gpio.leds[i]: 'z;
    end
    for (genvar i = 0; i < 8; i++) begin
      assign JB[i] = io_w.gpio_mode.JB[i]?io_w.gpio.JB[i]: 'z;
      assign JC[i] = io_w.gpio_mode.JC[i]?io_w.gpio.JC[i]: 'z;
    end
  endgenerate

  uart_rx uart_rm (
      .rx_data_valid(io_r.uart.state[0]),
      .rx_data(io_r.uart.rx),
      .rx(urx),
      .rx_ctrl(io_w.uart.ctrl[1:0]),
      .rx_ready(io_r.uart.state[1]),
      .clk(clk),
      .rst(rst)
  );

  uart_tx #(
    // .CLK_FREQ(100_000_000),
    // .BODE_RATE(10_000_000)
  ) uart_wm (
      .tx_data_valid(io_w.uart.ctrl[2]),
      .tx_data(io_w.uart.tx),
      .tx(utx),
      // .tx_ctrl(io_w.uart.ctrl[1:0]),
      .tx_ready(io_r.uart.state[2]),

      .clk(clk),
      .rst(rst)
  );

  vga vga_m (
    .*,
    .vga_active(io_r.vga_active[0])
  );

  pipeline_unit #(
      .VIRT(VIRT),
      .ILA(ILA)
  ) pu1 (
      .*,
      .data_ready(data_ready | io_read_ready),
      // .mem_read_data(mem_read_mux)
      .rst(rst|direct_rx)
  );

  mmio #(
    .VIRT(VIRT),
    .ILA(ILA)
  ) mmio1 (
      .*,
      .addr (mem_write_addr),
      .wdata(mem_write_data)
      // .mem_read_mux(mem_read_mux),
  );





  data_src data_mem (
      .*,
      
      .mem_en(mem_en|direct_rx),
      .mem_rw(mem_rw|w_ready_rx),

      .dw(direct_rx?DW:dw),
      .addr  (direct_rx?addr_rx:mem_write_addr),
      .wdata (direct_rx?instr_data_rx:mem_write_data),
      .memory(mem_read_data)
  );


  debounce#(//消抖加边沿触发
    .EDGE(1)
  ) dbp(
    .edgebut(pos_instr_w),
    .button(cpu_or_imem),
    .clk(clk),
    .rst(rst)
  );
  debounce#(
    .EDGE(0)
  ) dbn(
    .edgebut(neg_instr_w),
    .button(cpu_or_imem),
    .clk(clk),
    .rst(rst)
  );  


  instr_w_rx rx_d_crtl(
    .addr_rx(addr_rx),
    .instr_data_rx(instr_data_rx),
    .data_in_rx(data_in_rx),
    .rx_data_valid(rx_data_valid),
    .w_ready_rx(w_ready_rx),
    .direct_rx(direct_rx),

    .pos_instr_w(pos_instr_w),
    .neg_instr_w(neg_instr_w),

    .clk(clk),
    .rst(rst)
  );

  uart_rx_direct urd(
    .rx_data_valid(rx_data_valid),
    .rx_data(data_in_rx),
    .rx(urx),
    .rst(rst),
    .clk(clk)
  );






  generate
    if(ILA) begin
        ila_1 debug_probe1 (
      	.clk(clk), // input wire clk
        .trig_in(1),
      	.probe0(32'({mem_rw, io_en, dw, mem_en, io_read_ready, data_ready, urx, utx, JC, JB, led})), // input wire [31:0]  probe0  
      	.probe1(mem_write_addr) // input wire [31:0]  probe1 
      );
    end
  endgenerate

endmodule
