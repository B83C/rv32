`timescale 1ns / 1ps
`include "defs.svh"

module pipeline_unit (
    input clk,
    input rst,
    input [31:0] instr,
    input instr_ready,
    output read_instr,
    input [31:0] mem_read_data,
    output [31:0] mem_write_addr,
    output [31:0] mem_write_data,
    output logic [31:0] pc_addr,
    output control_signals_t cs_o[N_STAGES-1:0]
);
  pipeline_i p (clk);

  assign cs_o = p.cs;

  assign p.flushes[F] = 0;
  assign p.flushes[D] = (p.cs[E].j | (p.cs[E].b & p.branch_hit));
  assign p.flushes[E] = (p.cs[E].j | (p.cs[E].b & p.branch_hit));

  assign p.stalls[D] = (p.cs[E].l && (p.rd[E] == p.rs2_in | p.rd[E] == p.rs1_in) && p.rd[E] != 0);
  assign p.stalls[F] = (p.cs[E].l && (p.rd[E] == p.rs2_in | p.rd[E] == p.rs1_in) && p.rd[E] != 0);
  assign read_instr = !p.stalls[F];
  assign p.instr_in = instr;

  pbuffer #(7, word_t, {
        {F, W},
        {D, D},
        {M, M},
        {E, E},
        {E, M},
        {E, E},
        {W, W}
  }) rp ( clk, rst, p.stalls, p.flushes, '{
        pc_addr,
        instr,
        p.alu_res_in,
        p.r1_in,
        p.r2_in,
        p.imm_in,
        mem_read_data
    }, '{
        p.pc,
        p.instr,
        p.alu_res,
        p.r1,
        p.r2,
        p.imm,
        p.mem_read_data
  });
  pbuffer #( 3, reg_ind_t, {
        {E, E},
        {E, E},
        {E, M}
  }) rp1 ( clk, rst, p.stalls, p.flushes, '{
        p.rs1_in,
        p.rs2_in,
        p.rd_in
      }, '{
        p.rs1,
        p.rs2,
        p.rd
  });

  `define SB(x, t, y, z, w) \
  pbuffer #( 1, t, { \
    y \
  }) x ( clk, rst, p.stalls, p.flushes, \
      '{ z }, \
      '{ w } \
  );
  `SB(rp2, logic[2:0], {E, E}, p.func3_in, p.func3);
  `SB(rp3, logic[1:0], {E, E}, p.alu_src_sel_in, p.alu_src_sel);
  `SB(rp4, control_signals_t, {E, W}, p.cs_in, p.cs);

  wire [31:0] write_back;

  //Stage 1

  always_latch begin
    if(instr_ready) begin
      pc_addr = (p.cs[E].j)? p.alu_res_in: (p.cs[E].b && p.branch_hit)? p.jmp_addr : p.pc[F]+4;
    end
  	
  end

  //Stage 2

  ir_dec_ctrl ir_dec (p.ir_dec);

  registers reg_file (
      .clk(clk),
      .rst(rst),
      .w_en(p.cs[M].w),
      .rs1(p.rs1_in),
      .rs2(p.rs2_in),
      .rd(p.rd[M]),
      .w_data(write_back),
      .rd_data1(p.r1_temp),
      .rd_data2(p.r2_temp)
  );

  // function logic[31:0] reg_mux(logic[31:0] rg, register_data_sel sel);
  //   case(sel)
  //     RAW: return rg;
  //     ALU: return p.alu_res; //TODO Overlapped with reg_e_mux
  //     default: return write_back; //Imply WB
  //   endcase
  // endfunction

  // assign p.r1_mux = reg_mux(p.r1, p.r1_sel);
  // assign p.r2_mux = reg_mux(p.r2, p.r2_sel);

  //Stage 3

  function logic [31:0] dedm_mux(logic [4:0] rs, logic [31:0] passthrough);
    return (p.cs[E].w && (rs == p.rd[E]))?
    p.alu_res_in: (p.cs[M].w && (rs == p.rd[M]))?
     write_back: passthrough;
  endfunction

  assign p.r1_in = dedm_mux(p.rs1_in, p.r1_temp);
  assign p.r2_in = dedm_mux(p.rs2_in, p.r2_temp);

  assign p.alu_mux_input_1 = (p.cs_in.ignore_first_operand)? 0: p.alu_src_sel_in[0]? p.pc[D]: p.r1_in;
  assign p.alu_mux_input_2 = p.alu_src_sel_in[1] ? p.imm_in : p.r2_in;

  alu alu_e (
      .clk(clk),
      .en(!p.flushes[E]),
      .func3(p.func3_in),
      .cs(p.cs_in),
      .alu_a(p.alu_mux_input_1),
      .alu_b(p.alu_mux_input_2),
      .overflow(p.overflow),
      .zero(p.zero),
      .alu_result(p.alu_res_in)
  );

  assign p.jmp_addr = p.pc[E] + p.imm[E];
  assign p.branch_hit = p.cs[E].b & (
      (p.zero && p.func3[E] == EQ) |
      (!p.zero && p.func3[E] == NE) |
      ((p.overflow && p.alu_res_in[31]) && p.func3[E] == LT) | //对于有符号的比较，当p.R1 < p.R2时，OF == SF
      (!(p.overflow && p.alu_res_in[31]) && p.func3[E] == GE) |
      ((p.alu_res_in[31]) && p.func3[E] == LTU) |
      (!(p.alu_res_in[31]) && p.func3[E] == GEU) 
  );

  // multiplier m_e (
  //   .clk_n(clk),
  //   .en(p.cs[E].m),
  //   .r1(p.r1[E]),
  //   // .busy(m_busy),
  //   .r2(p.r2[E]),
  //   .op(mul_op_t'(p.func3[E])),
  //   .rd(p.mul_res)
  // );

  //Stage 4

  // assign cs_oe = p.cs[E];
  assign mem_write_addr = p.alu_res_in;

  assign mem_write_data = (p.cs[M].l && (p.rd[M] == p.rs2[E])) ? mem_read_data : p.r2[E];

  //Stage 5

  assign write_back = (p.cs[M].j | p.cs[M].b) ? p.pc[M] + 4 : p.cs[M].l ? mem_read_data : p.alu_res[M];

  //Misc


  // hazard hz(p.hazard, instr_ready);

  always_comb begin
    if (p.cs[E].j | p.branch_hit) begin
      $display("[time=%0t j=0x%0h b=0x%0h addr=0x%0h(b) 0x%0h(j)", $time, p.cs[E].j, p.branch_hit,
               p.jmp_addr, p.alu_res_in);
    end
  end

  initial begin
    $display("type of p.mem_data_read %s", $typename(type(p.func3_in)));
  end
endmodule

