`timescale 1ns / 1ps
`include "defs.svh"

module pipeline_unit (
    input clk,
    input rst_n,
    input [31:0] instr,
    input instr_ready,
    input [31:0] mem_read_data,
    output [31:0] mem_write_addr,
    output [31:0] mem_write_data,
    output [31:0] pc_addr,
    output control_signals_t cs_oe
);
  pipeline_i p (clk);

  assign p.flushes[F] = 0;
  assign p.flushes[D] = (p.cs[E].j | (p.cs[E].b & p.branch_hit));
  // assign p.flushes[E] = p.flushes[D];

  assign p.stalls[D] = !instr_ready | (p.cs[E].j | (p.cs[E].b & p.branch_hit)) | (p.cs[IN].a && p.cs[E].l && (p.rd[E] == p.rs2[IN] | p.rd[E] == p.rs1[IN]) && p.rd[E] != 0);
  assign p.stalls[F] = 0;

  pbuffer #(7, word_t, {
        {F, W},
        {D, D},
        {M, M},
        {E, E},
        {E, M},
        {E, E},
        {W, W}
  }) rp ( clk, rst_n, p.stalls, p.flushes, '{
        pc_addr,
        instr,
        alu_res,
        p.r1[IN],
        p.r2[IN],
        p.imm[IN],
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
  }) rp1 ( clk, rst_n, p.stalls, p.flushes, '{
        p.rs1[IN],
        p.rs2[IN],
        p.rd[IN]
      }, '{
        p.rs1,
        p.rs2,
        p.rd
  });

  `define SB(x, t, y, z, w) \
  pbuffer #( 1, t, { \
    y \
  }) x ( clk, rst_n, p.stalls, p.flushes, \
      '{ z }, \
      '{ w } \
  );
  `SB(rp2, logic[2:0], {E, E}, p.func3[IN], p.func3);
  `SB(rp3, logic[1:0], {E, E}, p.alu_src_sel[IN], p.alu_src_sel);
  `SB(rp4, control_signals_t, {E, W}, p.cs[IN], p.cs);

  wire [31:0] write_back;
  word_t alu_res;

  //Stage 1

  assign pc_addr = (p.cs[E].j)? alu_res: (p.cs[E].b && p.branch_hit)? p.jmp_addr : instr_ready? p.pc[F] + 4:PC_START_ADDR;

  //Stage 2

  ir_dec_ctrl ir_dec (p.ir_dec);

  registers reg_file (
      .clk(clk),
      .rst_n(rst_n),
      .w_en(p.cs[M].w),
      .rs1(p.rs1[IN]),
      .rs2(p.rs2[IN]),
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
     alu_res: (p.cs[M].w && (rs == p.rd[M]))?
     write_back: passthrough;
  endfunction

  assign p.r1[IN] = dedm_mux(p.rs1[IN], p.r1_temp);
  assign p.r2[IN] = dedm_mux(p.rs2[IN], p.r2_temp);

  assign p.alu_mux_input_1 = (p.cs[IN].ignore_first_operand)? 0: p.alu_src_sel[IN][0]? p.pc[D]: p.r1[IN];
  assign p.alu_mux_input_2 = p.alu_src_sel[IN][1] ? p.imm[IN] : p.r2[IN];

  alu alu_e (
      .clk(clk),
      .func3(p.func3[IN]),
      .cs(p.cs[IN]),
      .alu_a(p.alu_mux_input_1),
      .alu_b(p.alu_mux_input_2),
      .overflow(p.overflow),
      .zero(p.zero),
      .alu_result(alu_res)
  );

  assign p.jmp_addr = p.pc[E] + p.imm[E];
  assign p.branch_hit = p.cs[E].b & (
      (p.zero && p.func3[E] == EQ) |
      (!p.zero && p.func3[E] == NE) |
      ((p.overflow && alu_res[31]) && p.func3[E] == LT) | //对于有符号的比较，当p.R1 < p.R2时，OF == SF
      (!(p.overflow && alu_res[31]) && p.func3[E] == GE) |
      ((alu_res[31]) && p.func3[E] == LTU) |
      (!(alu_res[31]) && p.func3[E] == GEU) 
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

  assign cs_oe = p.cs[E];
  assign mem_write_addr = alu_res;

  assign mem_write_data = (p.cs[M].l && (p.rd[M] == p.rs2[E])) ? mem_read_data : p.r2[M];

  //Stage 5

  assign write_back = (p.cs[M].j | p.cs[M].b) ? p.pc[W] + 4 : p.cs[M].l ? mem_read_data : p.alu_res[M];

  //Misc


  // hazard hz(p.hazard, instr_ready);

  always_comb begin
    if (p.cs[E].j | p.branch_hit) begin
      $display("[time=%0t j=0x%0h b=0x%0h addr=0x%0h(b) 0x%0h(j)", $time, p.cs[E].j, p.branch_hit,
               p.jmp_addr, alu_res);
    end
  end
  initial begin
  end
endmodule

