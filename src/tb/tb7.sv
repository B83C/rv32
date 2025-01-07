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
  logic [12:0]addra;
  logic [128-1:0]douta;
  logic instr_ready;
  logic clkb /* synthesis syn_isclock = 1 */;
  logic enb;
  logic renb;
  logic [7:0]web;
  logic [12:0]addrb;
  logic [128-1:0]dinb;
  logic [128-1:0]doutb;
  logic data_ready;

  assign clka = clk;
  assign clkb = clk;

  assign addrb = cpu_req_addr[16:4]; 
  assign renb = 1;
  assign enb = mem_req_valid | cpu_req_valid;
  assign web = {8{mem_req_wr}};
  assign dinb = mem_wr_data;
  assign mem_rd_data = doutb;
  assign mem_req_ready = 1;
  dual_port_ram #(128,128 * 1024) dpr(.*);
  cache c(.*);

  always #1 clk <= ~clk;

  `define TEST(x) \
    $size(x)

  initial begin
    $dumpfile("waveform.fst");
    $dumpvars(0, tb);
    // $display("Size : %h", `TEST({32'b0, 32'b0}));

    clk = 0;
    cpu_req_addr = 17'hA;
    cpu_req_valid = 1;
    cpu_req_wr = 0; 

    #12;
    cpu_req_addr = 17'hDAFE;
    cpu_req_valid = 1;
    cpu_req_wr = 1; 
    cpu_wr_data = {32'hDEDEDADA};

    #2cpu_req_valid = 1;

    #4cpu_wr_data = {32'hDADEDADB};

    #4 
    cpu_req_addr =  0;
    cpu_req_valid = 0;
    cpu_req_wr = 0; 
    cpu_wr_data = 0;

    #2cpu_req_valid = 0;

    #4;
    cpu_req_addr = 17'hDAFE;
    cpu_req_valid = 1;
    cpu_req_wr = 0; 
    // cpu_wr_data = {32'hFEEDDEAD};
    #2cpu_req_valid = 0;

    #4;
    ena = 1;
    addra = 0;
    #2 addra = 1;
     
    

    #100 $finish();
  end

endmodule 
