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
    input control_signals_t cs_o [N_STAGES - 1:0],
    output logic [31:0] memory
);

  logic [63:0] read_mem;
  logic [7:0] b_en;
  logic [63:0] wdata_e; 
  wire [31:0] rdata_e; 

  logic instr_sel;
  logic [31:0] addr_c;
  logic [63:0] ram_instr;

  always @(posedge clk) begin
    if(read_instr) begin
      instr_sel <= !pc_addr[2];
    end
    addr_c <= addr;
  end

  //Input
  assign wdata_e = {<<8{64'(wdata) << ((addr % 8) * 8)}};
  assign b_en = {<<1{{4'd0, maskb(data_width'(cs_o[E].dw))} << (addr % 8)}};

  //Output
  assign instr = le(ram_instr[instr_sel*32 +: 32]);
  assign rdata_e = 32'({<<8{read_mem << ((addr_c % 8) * 8)}});
  assign memory = 32'((rdata_e)) & mask(data_width'(cs_o[M].dw)) | {{32{cs_o[M].sign_ex & get_msb(data_width'(cs_o[M].dw), 32'((rdata_e)))}} & ~mask(data_width'(cs_o[M].dw))};

  // ram dpr(
  //   .clka(~clk) /* synthesis syn_isclock = 1 */,
  //   .ena(1),
  //   .wea(0),
  //   .addra(pc_addr/4),
  //   .dina(0),
  //   .douta(instr),

  //   .clkb(~clk) /* synthesis syn_isclock = 1 */,
  //   .enb(mem_en),
  //   .web({15{cs_o[E].s}} & b_en),
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
    .enb(mem_en & (cs_o[E].s | cs_o[E].l)),
    .web({8{cs_o[E].s}} & b_en),
    .renb(cs_o[E].l),
    .addrb(14'(addr/8)),
    .dinb(wdata_e),

    .doutb(read_mem)
  );


  logic mem_en_buff;
  always @(posedge clk) begin
    mem_en_buff <= mem_en;
    if(mem_en_buff && cs_o[M].l) begin
      $display("[MEM %t] Read %h from %h", $time(), memory, addr_c);
    end else if(mem_en && cs_o[E].s) begin
      $display("[MEM %t] Write %h to %h", $time(), wdata_e, addr);
    end
  end

endmodule
