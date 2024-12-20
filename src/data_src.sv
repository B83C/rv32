`timescale 1ns / 1ps
`include "defs.svh"

module data_src (
    input clk,
    input [31:0] pc_addr,
    input read_instr,
    output logic [31:0] instr,
    output reg instr_ready,

    input mem_en,
    input [31:0] addr,
    input [31:0] wdata,
    input control_signals_t cs,
    output reg [31:0] memory
);

  logic [63:0] read_mem;
  logic [7:0] b_en;
  logic [63:0] wdata_e; 
  wire [31:0] rdata_e; 

  logic instr_sel;
  logic [63:0] ram_instr;

  always @(negedge clk) begin
    instr_sel <= !pc_addr[2];
  end

  assign instr = le(ram_instr[instr_sel*32 +: 32]);
  assign b_en = {<<1{{4'd0, maskb(data_width'(cs.dw))} << (addr % 8)}};
  assign wdata_e = {<<8{64'(wdata) << ((addr % 8) * 8)}};
  assign rdata_e = 32'({<<8{read_mem << ((addr % 8) * 8)}});
  assign memory = 32'((rdata_e)) & mask(data_width'(cs.dw)) | {{32{cs.sign_ex & get_msb(data_width'(cs.dw), 32'((rdata_e)))}} & ~mask(data_width'(cs.dw))};

  // ram dpr(
  //   .clka(~clk) /* synthesis syn_isclock = 1 */,
  //   .ena(1),
  //   .wea(0),
  //   .addra(pc_addr/4),
  //   .dina(0),
  //   .douta(instr),

  //   .clkb(~clk) /* synthesis syn_isclock = 1 */,
  //   .enb(mem_en),
  //   .web({15{cs.s}} & b_en),
  //   .addrb(addr),
  //   .dinb(wdata_e),
  //   .doutb(read_mem)
  // );

  // assign instr_ready = 1;
  dual_port_ram dpr (
    .clka(clk) /* synthesis syn_isclock = 1 */,
    .ena(read_instr),
    .addra(14'(pc_addr/8)),
    .douta(ram_instr),
    .readya(instr_ready),

    .clkb(clk) /* synthesis syn_isclock = 1 */,
    .enb(mem_en),
    .web({8{cs.s}} & b_en),
    .renb(cs.l),
    .addrb(14'(addr/8)),
    .dinb(wdata_e),
    .doutb(read_mem)
  );

endmodule
