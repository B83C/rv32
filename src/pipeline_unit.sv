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
    // data_width dw,
    output control_signals_t cs_oe
);
  pipeline_i p (clk);

  assign p.flush_f = 0;
  assign p.flush_d = (p.cs_e.j | (p.cs_e.b & p.branch_hit));
  // assign p.flush_e = p.flush_d;

  assign p.stall_d = !instr_ready | (p.cs_e.j | (p.cs_e.b & p.branch_hit)) | (p.cs.a && p.cs_e.l && (p.rd_e == p.rs2 | p.rd_e == p.rs1) && p.rd_e != 0);
  assign p.stall_f = 0;

  logic [31:0] u;
  parameter N_STREAMS = 14;
  parameter integer start_pos[N_STREAMS- 1:0] = '{0: 4, 10: 0, 11: 3, 12: 3, 13: 1, default: 2};
  // logic [N_STREAMS-1:0][6-2:0][XLEN-1:0] stream = ;
  rbuffer_p #(
      .MRLen (6),
      .Nitems(N_STREAMS),
      .start (start_pos)
  ) buffer_stream (
      .clk(clk),
      .grst_n(rst_n),
      .stall('{0: p.stall_f, 1: p.stall_d, 2: p.stall_e, default: 1'b0}),
      .flush('{0: p.flush_f, 1: p.flush_d, 2: p.flush_e, default: 1'b0}),
      .in({
        32'(instr),
        32'(p.r2_e_mux),
        32'(p.alu_res),
        32'(p.pc),
        32'(p.rs1),
        32'(p.rs2),
        32'(p.rd),
        32'(p.cs),
        32'(p.r1),
        32'(p.r2),
        32'(p.imm),
        32'(p.func3),
        32'(p.alu_src_sel),
        32'(mem_read_data)
      }),
      .stream({
    {u, 32'(p.instr_d), u, u, u},
    {u, u, u, 32'(p.r2_e_mux_m), u},
    {u, u, u, 32'(p.alu_res_m), u},
    {32'(p.pc_f), 32'(p.pc_d), 32'(p.pc_e), 32'(p.pc_m), 32'(p.pc_w)},
    {u, u, 32'(p.rs1_e), u, u},
    {u, u, 32'(p.rs2_e), u, u},
    {u, u, 32'(p.rd_e), 32'(p.rd_m), u},
    {u, u, 32'(p.cs_e), 32'(p.cs_m), 32'(p.cs_w)},
    {u, u, 32'(p.r1_e), u, u},
    {u, u, 32'(p.r2_e), u, u},
    {u, u, 32'(p.imm_e), u, u},
    {u, u, 32'(p.func3_e), u, u},
    {u, u, 32'(p.alu_src_sel_e), u, u},
    {u, u, u, u, 32'(p.mem_read_data_w)}
  })
  );

  wire [31:0] write_back;

  //Stage 1

  assign pc_addr = p.pc;
  assign p.pc = (p.cs_e.j)? p.alu_res: (p.cs_e.b && p.branch_hit)? p.jmp_addr : instr_ready? p.pc_f + 4:PC_START_ADDR;

  //Stage 2

  ir_dec_ctrl ir_dec (p.ir_dec);

  registers reg_file (
      .clk(clk),
      .rst_n(rst_n),
      .w_en(p.cs_m.w),
      .rs1(p.rs1),
      .rs2(p.rs2),
      .rd(p.rd_m),
      .w_data(write_back),
      .rd_data1(p.r1),
      .rd_data2(p.r2)
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
    return (p.cs_e.w && (rs == p.rd_e))?
     p.alu_res: (p.cs_m.w && (rs == p.rd_m))?
     write_back: passthrough;
  endfunction

  assign p.r1_e_mux = dedm_mux(p.rs1, p.r1);
  assign p.r2_e_mux = dedm_mux(p.rs2, p.r2);

  assign p.alu_mux_input_1 = (p.cs.ignore_first_operand)? 0: p.alu_src_sel[0]? p.pc_d: p.r1_e_mux;
  assign p.alu_mux_input_2 = p.alu_src_sel[1] ? p.imm : p.r2_e_mux;

  alu alu_e (
      .clk(clk),
      .func3(p.func3),
      .cs(p.cs),
      .alu_a(p.alu_mux_input_1),
      .alu_b(p.alu_mux_input_2),
      .overflow(p.overflow),
      .zero(p.zero),
      .alu_result(p.alu_res)
  );

  assign p.jmp_addr = p.pc_e + p.imm_e;
  assign p.branch_hit = p.cs_e.b & (
      (p.zero && p.func3_e == EQ) |
      (!p.zero && p.func3_e == NE) |
      ((p.overflow && p.alu_res[31]) && p.func3_e == LT) | //对于有符号的比较，当p.R1 < p.R2时，OF == SF
      (!(p.overflow && p.alu_res[31]) && p.func3_e == GE) |
      ((p.alu_res[31]) && p.func3_e == LTU) |
      (!(p.alu_res[31]) && p.func3_e == GEU) 
  );

  // multiplier m_e (
  //   .clk_n(clk),
  //   .en(p.cs_e.m),
  //   .r1(p.r1_e),
  //   // .busy(m_busy),
  //   .r2(p.r2_e),
  //   .op(mul_op_t'(p.func3_e)),
  //   .rd(p.mul_res)
  // );

  //Stage 4

  assign cs_oe = p.cs_e;
  assign mem_write_addr = p.alu_res;

  assign mem_write_data = (p.cs_m.l && (p.rd_m == p.rs2_e)) ? mem_read_data : p.r2_e_mux_m;

  //Stage 5

  assign write_back = (p.cs_m.j | p.cs_m.b) ? p.pc_w + 4 : p.cs_m.l ? mem_read_data : p.alu_res_m;

  //Misc


  // hazard hz(p.hazard, instr_ready);

  always_comb begin
    if (p.cs_e.j | p.branch_hit) begin
      $display("[time=%0t j=0x%0h b=0x%0h addr=0x%0h(b) 0x%0h(j)", $time, p.cs_e.j, p.branch_hit,
               p.jmp_addr, p.alu_res);
    end
  end
  initial begin
  end
endmodule

