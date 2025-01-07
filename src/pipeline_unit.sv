`timescale 1ns / 1ps
`include "defs.svh"

module pipeline_unit #(
    VIRT = 0, 
    ILA = 0
) (
    input clk,
    input rst,
    input [31:0] instr,
    input instr_ready,
    input data_ready,
    output logic read_instr,
    sign_ex,
    input [31:0] mem_read_data,
    io_read,
    output [31:0] mem_write_addr,
    output [31:0] mem_write_data,
    output logic [31:0] pc_addr,
    output logic mem_en,
    io_en,
    output data_width dw,
    output logic mem_rw
);

  pipeline_i p (clk);
  pl_state_t state, next_state;

  wire control_hazard = (p.cs[E].b & p.branch_hit);
  wire mem_load_hazard = (p.cs[E].l && (p.rd[E] == p.rs2[D] | p.rd[E] == p.rs1[D]) && p.rd[E] != 0);

  assign p.flushes[F] = state != RUNNING | 0;
  assign p.flushes[D] = state != RUNNING | control_hazard;
  assign p.flushes[E] = state != RUNNING | control_hazard;

  assign p.stalls[PF] = 0;

  wire mem_wait = (!data_ready) & (p.mem_en_i[E] & p.cs[E].l) & state == RUNNING;
  wire mem_wait_m = (!data_ready) & (p.mem_en_i_in[M] & (p.cs[M].l)) & state == RUNNING;

  always_ff @(posedge clk) begin
    p.stalls[M] <= mem_wait;
    p.stalls[E] <= p.cs[E].m | mem_wait;
    p.stalls[D] <= p.cs[E].m | p.mul_busy | mem_wait | mem_load_hazard;
    p.stalls[F] <= p.cs[E].m | p.mul_busy | mem_wait | mem_load_hazard;
  end

  `define S(start_stage, end_stage, var) \
  generate \
    for (genvar i = int'(start_stage) + 1; i <= int'(end_stage); i++) begin : var``_blk \
      assign p.``var``_in[i] = p.stalls[i]?'0:p.``var``_buf[i]; \
      always @(posedge clk, posedge rst) begin \
        if (rst | p.flushes[i]) begin \
          p.``var``_buf[i] <= '0; \
        end else if (!p.stalls[i]) begin \
          p.``var``_buf[i] <= (!p.stalls[(i-1)])? p.``var[i-1] : '0; \
        end \
      end \
    end \
  endgenerate 

  `S(PF, W, pc)
  `S(F, D, instr)
  `S(E, W, alu_res)
  `S(E, W, mul_res)
  `S(D, E, r1)
  `S(D, M, r2)
  `S(D, E, imm)
  `S(M, W, mem_read_data)
  `S(D, E, rs1)
  `S(D, E, rs2)
  `S(D, W, rd)
  `S(D, E, alu_op)
  `S(D, E, func3)
  `S(D, E, op)
  `S(D, E, reg_src_1)
  `S(D, E, reg_src_2)
  `S(D, E, agu_sel)
  `S(D, E, alu_sel_1)
  `S(D, E, alu_sel_2)
  `S(D, W, cs)
  `S(M, W, write_back)
  `S(E, M, io_en_i)
  `S(E, M, mem_en_i)

  //Stage 1

  assign pc_addr = p.pc[PF];

  always_comb begin
    case (state)
      RESET: begin
        p.pc[PF]   = 0;  //Reset PC ADDR
        next_state = WAIT;
        read_instr = 0;
      end
      WAIT: begin
        next_state = RUNNING;
        read_instr = 1;
      end
      RUNNING: begin
        next_state = RUNNING;
        read_instr = !p.stalls[F];
        if (instr_ready) begin
          p.pc[PF] = (p.cs_in[E].b && p.branch_hit) ? p.jmp_addr : p.pc_buf[F] + 4;
        end
      end
      default: begin
        next_state = RESET;
      end
    endcase
  end

  assign p.pc[F] = p.pc_in[F];
  assign p.instr[F] = (state != RUNNING & !instr_ready) ? 0 : instr;

  //Stage 2

  ir_dec_ctrl ir_dec (
      .ir(p.instr_in[D]),
      .rs1(p.rs1[D]),
      .rs2(p.rs2[D]),
      .rd(p.rd[D]),
      .alu_op(p.alu_op[D]),
      .func3(p.func3[D]),
      .op(p.op[D]),
      .cs(p.cs[D]),
      .imm(p.imm[D]),
      .agu_sel(p.agu_sel[D]),
      .alu_sel_1(p.alu_sel_1[D]),
      .alu_sel_2(p.alu_sel_2[D])
  );

  registers reg_file (
      .*,
      .w_en(!p.stalls[M] && p.cs[M].w),
      .rd(p.rd[M]),
      .w_data(p.write_back[M]),
      .rs1(p.rs1[D]),
      .rs2(p.rs2[D]),
      .rd_data1(p.r1[D]),
      .rd_data2(p.r2[D])
  );

  assign p.pc[D] = p.pc_in[D];
  assign p.instr[D] = p.instr_in[D];

  function alu_reg_src_t src_sel(logic [4:0] rs);
    return (p.cs_in[E].w && (rs == p.rd_in[E]))?
        p.cs_in[E].m ? WB_MUL_RES: WB_M
        : (p.cs_in[M].w && (rs == p.rd_in[M]))?
           WB_W: WB_PASSTHROUGH;
  endfunction

  alu_reg_src_t reg_src_1;
  alu_reg_src_t reg_src_2;
  assign p.reg_src_1[D] = src_sel(p.rs1[D]);
  assign p.reg_src_2[D] = src_sel(p.rs2[D]);

  //Stage 3

  always @(posedge clk) begin
    if(!p.stalls[D]) begin
      reg_src_1 <= src_sel(p.rs1[D]);
      reg_src_2 <= src_sel(p.rs2[D]);
    end
  end

  function logic [31:0] reg_mux(logic[1:0] src, logic [31:0] passthrough);
    case(alu_reg_src_t'(src)) 
      WB_MUL_RES:   reg_mux = p.mul_res[E];
      WB_M:   reg_mux = p.write_back[M];
      WB_W:         reg_mux = p.write_back_in[W];
      WB_PASSTHROUGH: reg_mux = passthrough;
    endcase
  endfunction

  word_t r1_mux, r2_mux;
  assign r1_mux = reg_mux(p.reg_src_1_in[E], p.r1_in[E]);
  assign r2_mux = reg_mux(p.reg_src_2_in[E], p.r2_in[E]);

  always_comb begin
    case ((p.alu_sel_1_in[E]))
      ALU_S1_0:  p.alu_mux_input_1 = 0;
      ALU_S1_PC: p.alu_mux_input_1 = p.pc_in[E];
      ALU_S1_R1: p.alu_mux_input_1 = r1_mux;
      default:   p.alu_mux_input_1 = 'x;
    endcase

    case (p.alu_sel_2_in[E])
      ALU_S2_4: p.alu_mux_input_2 = 4;
      ALU_S2_IMM: p.alu_mux_input_2 = p.imm_in[E];
      ALU_S2_R2: p.alu_mux_input_2 = r2_mux;
      default: p.alu_mux_input_2 = 'x;
    endcase
  end

  alu alu_e (
      .*,
      .alu_op(p.alu_op_in[E]),
      .cs(p.cs_in[E]),
      .alu_a(p.alu_mux_input_1),
      .alu_b(p.alu_mux_input_2),
      .overflow(p.overflow),
      .zero(p.zero),
      .alu_result(p.alu_res[E])
  );

  word_t agu_s1;
  always_comb begin
    case (p.agu_sel_in[E])
      AGU_S1_R1: agu_s1 = r1_mux;
      AGU_S1_PC: agu_s1 = p.pc_in[E];
    endcase
  end

  assign p.jmp_addr = agu_s1 + p.imm_in[E];

  always_comb begin
    if (p.op_in[E][2]) begin
      p.branch_hit = 1;
    end else begin
      case (p.func3_in[E])
        EQ: p.branch_hit = p.zero;
        NE: p.branch_hit = !p.zero;
        LT, LTU: p.branch_hit = p.overflow;
        GE, GEU: p.branch_hit = !p.overflow;
        default: p.branch_hit = 'x;
      endcase
    end
  end

  multiplier m_e (
      .*,
      .clk(p.clk),
      .en(p.cs_in[E].m),
      .r1(r1_mux),
      .r2(r2_mux),
      .mul_busy(p.mul_busy),
      .op(mul_op_t'(p.func3[E])),
      .rd(p.mul_res[E])
  );

  assign p.pc[E] = p.pc_in[E];
  assign p.cs[E] = p.cs_in[E];
  assign p.rd[E] = p.rd_in[E];
  assign p.r2[E] = p.r2_in[E];

  //Stage 4

  assign sign_ex = p.cs[E].sign_ex;
  assign dw = data_width'(p.cs[E].dw);
  assign mem_rw = p.cs[E].s;

  assign io_en = p.io_en_i[E];
  assign mem_en = p.mem_en_i[E];
  assign p.mem_en_i[E] = (p.jmp_addr < IO_START && (p.cs_in[E].s | p.cs_in[E].l));
  assign p.io_en_i[E] = (p.jmp_addr >= IO_START) && (p.cs_in[E].s | p.cs_in[E].l);
  // assign cs_oe = p.cs[E];
  assign mem_write_addr = p.jmp_addr;

  assign mem_write_data = r2_mux;
  // assign mem_write_data = (p.cs_in[M].l && (p.rd_in[M] == p.rs2_in[E])) ? p.mem_en_i[E]? mem_read_data : io_read: (p.cs[M].w && (p.rd[M] == p.rs2_in[E])) ? p.cs_in[M].m ? p.mul_res_in[M] : p.alu_res_in[M] : r2_mux;

  assign p.mem_read_data[M] = p.mem_en_i_in[M] ? mem_read_data : p.io_en_i_in[M] ? io_read : 0;
  // assign p.mem_read_data[M] = mem_read_data;
  assign p.pc[M] = p.pc_in[M];
  assign p.cs[M] = p.cs_in[M];
  assign p.rd[M] = p.rd_in[M];
  assign p.alu_res[M] = p.alu_res_in[M];

  //Stage 5

  assign p.write_back[M] = p.cs[M].l ? p.mem_read_data[M] : p.cs_in[M].m ? p.mul_res_in[M] : p.alu_res_in[M];

  //Misc
  always_comb begin
    if (p.cs[E].b) begin
      $display("[time=%0t j=0x%0h b=0x%0h addr=0x%0h", $time, p.op_in[E][2],
               !p.op_in[E][2] & p.branch_hit, p.jmp_addr);
    end
  end

  always @(posedge clk, posedge rst) begin
    if (rst) begin
      state <= RESET;
    end else begin
      state <= next_state;
    end
  end

  initial begin
    state = RESET;
  end

  generate
    if (ILA) begin
      wire word_t pca, istr, p2;
      wire word_t p3, p4;
      assign pca = pc_addr;

      wire reset = rst;
      wire mwait = mem_wait;
      wire mwait_m = mem_wait_m;
      wire c_haz = control_hazard;
      wire l_haz = mem_load_hazard;
      wire mem_en = p.mem_en_i[E];
      wire control_signals_t cs1, cs2;

      assign cs1 = p.cs[D];
      assign cs2 = p.cs_in[E];

      ila_0 debug_probe (
          .clk(clk),  // input wire clk
          .trig_in(pca == 0),
          .probe0(pc_addr),  // input wire [31:0]  probe0  
          .probe1(p.instr_in[D]),  // input wire [31:0]  probe1 
          .probe2({cs1, p.rs1[D], p.rs2[D], p.rd[D], p.func3[D]}),  // input wire [31:0]  probe2
          .probe3(p.alu_mux_input_2),
          .probe4(mem_write_data),
          .probe5({
            instr_ready, read_instr, reset, state, c_haz, l_haz, mwait, mwait_m, mem_en, cs2
          }),
          .probe6(p.alu_mux_input_1),
          .probe7(p.alu_res[E])
      );
    end
  endgenerate

endmodule

