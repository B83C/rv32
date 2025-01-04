`timescale 1ns / 1ps
`include "defs.svh"

module tb7;

  logic clk, rst_n;
  logic rst;
  logic [16:0] cpu_req_addr;
  logic cpu_req_valid;
  logic cpu_req_wr;
  logic [31:0] cpu_wr_data;
  logic [31:0] cpu_rd_data;
  logic cpu_req_ready;
  logic [16:0] mem_req_addr;
  logic mem_req_valid;
  logic mem_req_wr;
  logic [127:0] mem_wr_data;
  logic [127:0] mem_rd_data;
  logic mem_req_ready;

  logic [31:0] pc_addr;
  logic read_instr;
  logic [31:0] instr;

  logic mem_en;
  logic [31:0] addr;
  logic [31:0] wdata;
  control_signals_t cs, cs_o [N_STAGES - 1:0];
  logic [31:0] memory; 
  pipeline_i po (clk);

  logic clka /* synthesis syn_isclock = 1 */;
  logic ena;
  logic [13:0]addra;
  logic [63:0]douta;
  logic instr_ready;
  logic clkb /* synthesis syn_isclock = 1 */;
  logic enb;
  logic renb;
  logic [7:0]web;
  logic [13:0]addrb;
  logic [63:0]dinb;
  logic [63:0]doutb;
  logic data_ready;

  assign clka = clk;
  assign clkb = clk;

  dual_port_ram dpr(.*);
  cache c(.*);

`define HANDLE_DATA_VARS(prefix, list) \
    for (int i = 0; i < list.len(); i++) begin \
        prefix``_``list[i] <= some_value; \
    end  

  `define GEN(prefix, list) \
  generate \
      genvar i; \
      for (i = 0; i < 4; i++) begin : gen_vars \
          logic [31:0] prefix``_``list[i];   \
      end \
  endgenerate

`define DECLARE_STAGE_VARS(prefix, suffix_list) \
    `foreach(suffix_list, suffix) logic [31:0] prefix``_``suffix;

  `DECLARE_STAGE_VARS(tet, ({A, B, C, D}))

  always #1 clk <= ~clk;

  `define TEST(x) \
    $size(x)

  initial begin
    $dumpfile("waveform.fst");
    $dumpvars(0, tb);
    // $display("Size : %h", `TEST({32'b0, 32'b0}));

    clk = 0;
    cpu_req_addr = 17'hFADE;
    cpu_req_valid = 1;
    cpu_req_wr = 0; 
    mem_req_ready = 1;
    mem_rd_data = {4{32'hDEADBEEF}};

    #5;
    cpu_req_addr = 17'hDAFE;
    cpu_req_valid = 1;
    cpu_req_wr = 1; 
    cpu_wr_data = {32'hFEEDDEAD};
    mem_req_ready = 1;

    #1 
    cpu_req_addr =  0;
    cpu_req_valid = 0;
    cpu_req_wr = 0; 
    cpu_wr_data = 0;
    mem_req_ready = 0;

    #5;
    cpu_req_addr = 17'hDAFE;
    cpu_req_valid = 1;
    cpu_req_wr = 0; 
    // cpu_wr_data = {32'hFEEDDEAD};
    mem_req_ready = 1;

    #5;
    ena = 1;
    addra = 0;
    #2 addra = 1;
     
    

    #100 $finish();
  end

endmodule 
