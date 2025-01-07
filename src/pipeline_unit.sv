 `timescale 1ns / 1ps
`include "defs.svh"

module pipeline_unit (
    input clk,
    input rst,
    input [31:0] instr,
    input instr_ready,
    input data_ready,
    output logic read_instr,
    input [31:0] mem_read_data, io_read,
    output [31:0] mem_write_addr,
    output [31:0] mem_write_data,
    output logic [31:0] pc_addr,
    output logic mem_en, io_en,
    output data_width dw,
    output logic mem_rw
);

  pipeline_i p (clk);
  pl_state_t state;

  wire control_hazard = (p.cs[E].j | (p.cs[E].b & p.branch_hit));
  wire mem_load_hazard =  (p.cs[E].l && (p.rd[E] == p.rs2[D] | p.rd[E] == p.rs1[D]) && p.rd[E] != 0);

  assign p.flushes[F] = 0;
  assign p.flushes[D] = control_hazard;
  assign p.flushes[E] = control_hazard;

  assign p.stalls[PF] = 0; 

  wire mem_wait = !data_ready && (!p.io_en_i[E] && p.cs[E].l);
  wire mem_wait_m = !data_ready && (!p.io_en_i_in[M] && (p.cs[M].l));
  assign p.stalls[M] = mem_wait_m;
  assign p.stalls[E] = mem_wait_m;
  assign p.stalls[D] = mem_wait_m | mem_wait | mem_load_hazard;
  assign p.stalls[F] = mem_wait_m | mem_wait | mem_load_hazard;

  logic start = 1;
  assign read_instr = state == RUNNING & !p.stalls[F];

 `define S(start_stage, end_stage, var) \
  generate \
    for (genvar i = int'(start_stage) + 1; i <= int'(end_stage); i++) begin : var``_blk \
      always @(posedge clk, posedge rst) begin \
        if (rst | p.flushes[i]) begin \
          p.``var``_in[i] <= 0; \
        end else if (!p.stalls[i]) begin \
          p.``var``_in[i] <= (!p.stalls[(i-1)])? p.``var[i-1] : 0; \
        end \
      end \
    end \
  endgenerate 

  `S(PF, W, pc)
  `S(F, D, instr)
  `S(E, W, alu_res)
  `S(D, E, r1)
  `S(D, M, r2)
  `S(D, E, imm)
  `S(M, W, mem_read_data)  
  `S(D, E, rs1)
  `S(D, E, rs2)
  `S(D, W, rd)
  `S(D, E, func3)
  `S(D, E, alu_src_sel)
  `S(D, W, cs)
  `S(M, W, write_back)
  `S(E, M, io_en_i)
  `S(E, M, mem_en_i)

  //Stage 1

  // initial p.pc_in[F] = -4;
  assign pc_addr = p.pc[PF];
  // always @(posedge clk) begin
  //   pc_addr <= (pc_temp < 'h1d4)? pc_temp : 0;
  // end
  // assign pc_addr = (pc_temp < 'h1d4)? pc_temp : 0;
  always_comb begin
    case(state) 
      RESET: p.pc[PF] = 0;
      RUNNING: begin
        if(instr_ready) begin
          p.pc[PF] = (p.cs[E].j)? p.alu_res[E]: (p.cs[E].b && p.branch_hit)? p.jmp_addr : p.pc_in[F]+4;
        end 
      end
    endcase
  end
  assign p.pc[F] = p.pc_in[F];
  assign p.instr[F] = instr;

  //Stage 2

  ir_dec_ctrl ir_dec (
    .ir(p.instr_in[D]),
    .rs1(p.rs1[D]),
    .rs2(p.rs2[D]),
    .rd(p.rd[D]),
    .func3(p.func3[D]),
    .cs(p.cs[D]),
    .imm(p.imm[D]),
    .alu_src_sel(p.alu_src_sel[D])
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

  //Stage 3

  function logic [31:0] dedm_mux(logic [4:0] rs, logic [31:0] passthrough);
    return (p.cs_in[M].w && (rs == p.rd_in[M]))?
    p.alu_res_in[M]: (p.cs_in[W].w && (rs == p.rd_in[W]))?
     p.write_back_in[W]: passthrough;
  endfunction

  word_t r1_mux, r2_mux;
  assign r1_mux = dedm_mux(p.rs1_in[E], p.r1_in[E]);
  assign r2_mux = dedm_mux(p.rs2_in[E], p.r2_in[E]);

  assign p.alu_mux_input_1 = (p.cs_in[E].ignore_first_operand)? 0: p.alu_src_sel_in[E][0]? p.pc_in[E]: r1_mux;
  assign p.alu_mux_input_2 = p.alu_src_sel_in[E][1] ? p.imm_in[E] : r2_mux;

  alu alu_e (
      .*,
      .func3(p.func3_in[E]),
      .cs(p.cs_in[E]),
      .alu_a(p.alu_mux_input_1),
      .alu_b(p.alu_mux_input_2),
      .overflow(p.overflow),
      .zero(p.zero),
      .alu_result(p.alu_res[E])
  );

  assign p.jmp_addr = p.pc_in[E] + p.imm_in[E];
  assign p.branch_hit = p.cs_in[E].b & (
      (p.zero && p.func3_in[E] == EQ) |
      (!p.zero && p.func3_in[E] == NE) |
      ((p.overflow && p.alu_res[E][31]) && p.func3_in[E] == LT) | //对于有符号的比较，当p.R1 < p.R2时，OF == SF
      (!(p.overflow && p.alu_res[E][31]) && p.func3_in[E] == GE) |
      ((p.alu_res[E][31]) && p.func3_in[E] == LTU) |
      (!(p.alu_res[E][31]) && p.func3_in[E] == GEU) 
  ); //TODO LTU for 32bit integer might not work

  // multiplier m_e (
  //   .clk_n(clk),
  //   .en(p.cs[E].m),
  //   .r1(p.r1[E]),
  //   // .busy(m_busy),
  //   .r2(p.r2[E]),
  //   .op(mul_op_t'(p.func3[E])),
  //   .rd(p.mul_res)
  // );
  assign p.pc[E] = p.pc_in[E];
  assign p.cs[E] = p.cs_in[E];
  assign p.rd[E] = p.rd_in[E];
  assign p.r2[E] = p.r2_in[E];

  //Stage 4

  assign dw = data_width'(p.cs[E].dw);
  assign mem_rw = p.cs[E].s;

  assign io_en = p.io_en_i[E];
  assign mem_en = p.mem_en_i[E];
  assign p.mem_en_i[E] = (!p.io_en_i[E] && (p.cs[E].s | p.cs[E].l));
  assign p.io_en_i[E] = (p.alu_res[E] >= IO_START) && (p.cs[E].s | p.cs[E].l);
  // assign cs_oe = p.cs[E];
  assign mem_write_addr = p.alu_res[E];

  assign mem_write_data = (p.cs[M].l && (p.rd[M] == p.rs2_in[E])) ? !p.io_en_i[E]? mem_read_data : io_read: (p.cs[M].w && (p.rd[M] == p.rs2_in[E])) ? p.alu_res[M] : p.r2[E];

  assign p.mem_read_data[M] = p.mem_en_i_in[M]? mem_read_data: p.io_en_i_in[M]? io_read: 0;
  // assign p.mem_read_data[M] = mem_read_data;
  assign p.pc[M] = p.pc_in[M];
  assign p.cs[M] = p.cs_in[M];
  assign p.rd[M] = p.rd_in[M];
  assign p.alu_res[M] = p.alu_res_in[M];

  //Stage 5

  assign p.write_back[M] = (p.cs[M].j | p.cs[M].b) ? p.pc[M] + 4 : p.cs[M].l ? p.mem_read_data[M] : p.alu_res[M];

  //Misc
  always_comb begin
    if (p.cs[E].j | p.branch_hit) begin
      $display("[time=%0t j=0x%0h b=0x%0h addr=0x%0h(b) 0x%0h(j)", $time, p.cs[E].j, p.branch_hit,
               p.jmp_addr, p.alu_res[E]);
    end
  end

  logic [5:0] cntr;
  always @(posedge clk) begin
    if(cntr == 0 || (p.pc[PF] >= 'h1d4)) begin
      start <= 0;
      cntr <= 1;
    end else if (cntr <= 20) begin
      cntr <= cntr +  1;
    end else if (cntr > 20) begin
      start <= 1;
    end
  end

  always @(posedge clk) begin
    if(rst) begin
      state <= RESET;
    end else if (start) begin
      state <= RUNNING;
    end 
  end

  initial begin
    state = RESET;
    start = 1;
    // #10 start = 1;
  end


  wire word_t pca, istr, p2;
  wire word_t p3, p4;
  assign pca = pc_addr;
  assign istr = instr;
  assign p2 ={rst, p.cs[D], instr_ready};  
  assign p3 = p.imm[D];
  assign p4 = {<<{p.stalls}};
  
  ila_0 debug_probe (
  	.clk(clk), // input wire clk
    .trig_in(pca == 0),
  	.probe0(pca), // input wire [31:0]  probe0  
  	.probe1(istr), // input wire [31:0]  probe1 
  	.probe2(p2), // input wire [31:0]  probe2
    .probe3(p3),
    .probe4(p4)
  );
endmodule

