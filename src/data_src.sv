`timescale 1ns / 1ps
`include "defs.svh"

module data_src #(DEBUG = 1)(
    input clk,
    input [31:0] pc_addr,
    input read_instr,
    output logic [31:0] instr,
    output logic instr_ready,

    input mem_en,
    input [31:0] addr,
    input [31:0] wdata,
    input mem_rw,
    input sign_ex,
    data_width dw,
    output logic data_ready,
    output logic [31:0] memory
);

  logic [63:0] read_mem;
  logic [31:0] memory_buffer;
  logic [7:0] b_en;
  logic [63:0] wdata_e; 
  wire [31:0] rdata_e; 

  logic instr_sel, sign_ex_c;
  data_width dw_c;
  logic [31:0] addr_c;
  logic [63:0] instr_buffer;

  logic [1:0] readya, readyb;
  assign instr_ready = readya[0];
  assign instr = instr_buffer[instr_sel*32 +: 32];
  assign data_ready = readyb[1];

  always @(posedge clk) begin
    {readya[0], readyb[0]} <= 0;
    readya[1] <= readya[0];
    readyb[1] <= readyb[0];
    if(read_instr) begin
      readya[0] <= 1;
      instr_sel <= pc_addr[2];
    end
    if(mem_en && !mem_rw) begin
      readyb[0] <= 1;
    end 
    if(readyb[0]) begin
      memory <= memory_buffer;
    end
    addr_c <= addr;
    sign_ex_c <= sign_ex;
    dw_c <= dw;
  end

  //Input
  assign wdata_e = {64'(wdata) << ((addr % 8) * 8)};

  //Output
  // assign instr = ram_instr[instr_sel*32 +: 32];
  assign rdata_e = 32'({read_mem >> ((addr_c[2:0]) * 8)});

  always_comb begin
    if(mem_rw) begin
    	b_en = {{4'd0, maskb(dw)} << (addr % 8)};
    end else begin
      b_en = 0;
    end
    case(dw_c)
      DB:  memory_buffer = 32'(signed'({sign_ex_c & rdata_e[8-1], rdata_e[8-1:0]}));
      DH:  memory_buffer = 32'(signed'({sign_ex_c & rdata_e[16-1], rdata_e[16-1:0]}));
      DW:  memory_buffer = rdata_e[32-1:0];
    default: memory_buffer = 'x;
    endcase
  end

  // assign instr_ready = 1;
  dual_port_ram dpr (
    .*,
    .clka(clk) /* synthesis syn_isclock = 1 */,
    .ena(read_instr),
    .addra(14'(pc_addr/8)),
    .douta(instr_buffer),

    .clkb(clk) /* synthesis syn_isclock = 1 */,
    .enb(mem_en),
    .renb(!mem_rw),
    .web(b_en),
    .addrb(14'(addr/8)),
    .dinb(wdata_e),

    .doutb(read_mem)
  );


  always @(posedge clk) begin
    if(readyb[0]) begin
      $display("[MEM %t] Read %h from %h raw %h", $time(), memory_buffer, addr_c, read_mem);
    end else if(mem_en && mem_rw) begin
      $display("[MEM %t] Write %h to %h", $time(), wdata, addr);
    end
  end

endmodule
