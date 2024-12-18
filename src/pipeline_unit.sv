`timescale 1ns / 1ps
`include "defs.svh"

module pipeline_unit (
    input clk,
    input rst_n,
    input [31:0] instr,
    input [31:0] mem_read_data,
    output [31:0] mem_write_addr,
    output [31:0] mem_write_data,
    output [31:0] pc_addr,
    // data_width dw,
    output control_signals_t cs_om
);
  wire stall_f, stall_d;
  wire flush_f, flush_d, flush_e;
  wire branch_hit;
  wire [31:0] jmp_addr;
 
  wire [31:0] instr_d, pc, pc_f, pc_d, pc_e, pc_m, pc_w;
  rbuffer #($size(instr)) instr_bd (clk, !stall_d, flush_d & rst_n, instr, instr_d);
  rbuffer #($size(pc), 5) pc_bfdemw (clk, {!stall_f, !stall_d, {3{1'b1}}}, {flush_f, flush_d, flush_e, {2{1'b1}}} & {5{rst_n}}, pc, {pc_f, pc_d, pc_e, pc_m, pc_w});

  register_data_sel r1_sel, r2_sel, r1_e_sel, r2_e_sel;
  wire [4:0] rs1, rs1_e;
  wire [4:0] rs2, rs2_e;
  rbuffer #($size(rs1)) rs1_be (clk, 1, rst_n, rs1, rs1_e);
  rbuffer #($size(rs2)) rs2_be (clk, 1, rst_n, rs2, rs2_e);

  wire [4:0] rd, rd_e, rd_m, rd_w;
  rbuffer #($size(rd), 3) rd_b (clk, 3'b111, {flush_e, {2{1'b1}}} & {3{rst_n}}, rd, {rd_e, rd_m, rd_w});

  wire [31:0] r1, r1_e;
  rbuffer #($size(r1)) r1_be (clk, 1, rst_n, r1_mux, r1_e);
  wire [31:0] r2, r2_e;
  rbuffer #($size(r2)) r2_be (clk, 1, rst_n, r2_mux, r2_e);

  wire [31:0] r1_mux, r2_mux, r1_e_mux, r2_e_mux, r2_e_mux_m;
  rbuffer #($size(r2_e_mux)) r2_e_mux_bm (clk, 1, rst_n, r2_e_mux, r2_e_mux_m);

  wire [31:0] imm, imm_e;
  rbuffer #($size(imm)) imm_be (clk, 1, 1 & rst_n, imm, imm_e);

  wire [2:0] func3, func3_e;
  rbuffer #($size(func3)) func3_be (clk, 1,1 & rst_n, func3, func3_e);
  wire [1:0] alu_src_sel, alu_src_sel_e;
  rbuffer #($size(alu_src_sel)) alu_src_sel_be (clk, 1, 1 & rst_n, alu_src_sel, alu_src_sel_e);

  control_signals_t cs, cs_e, cs_m, cs_w;
  rbuffer #($size(control_signals_t), 3) cs_b (clk, 3'b111, {flush_e, {2{1'b1}}} & {3{rst_n}}, cs, {cs_e, cs_m, cs_w});

  wire [31:0] alu_mux_input_1;
  wire [31:0] alu_mux_input_2;
  wire [31:0] alu_res, alu_res_m, alu_res_w;
  rbuffer #($size(alu_res), 2) alu_res_bm (clk, 2'b11, {2{rst_n}}, cs_e.m? mul_res :alu_res, {alu_res_m, alu_res_w});

  wire overflow, zero;
  // rbuffer #($size(alu_res)) alu_res_bw (clk, 1, rst_n, alu_res_m, alu_res_w);

  wire [31:0] mul_res, mul_res_m;
  // rbuffer #($size(mul_res)) mul_res_bw (clk, 1, rst_n, mul_res, mul_res_m);
  // rbuffer #($size(alu_res_w)) alu_res_w_b (clk, 1, rst_n, (cs_m.m)? mul_res_m: alu_res_m, alu_res_w);

  wire [31:0] mem_read_data_w;
  rbuffer #($size(mem_read_data)) mem_read_data_bw (clk, 1, rst_n, mem_read_data, mem_read_data_w);

  wire [31:0] write_back;

  //Stage 1
  
  assign pc_addr = pc_f;
  assign pc = (cs_e.j)? alu_res: (cs_e.b && branch_hit)? jmp_addr : pc_f + 4;

  //Stage 2


  ir_dec_ctrl ir_dec (.ir(instr_d), .cs(cs), .rs1(rs1), .rs2(rs2), .rd(rd), .imm(imm),.func3(func3), .alu_src_sel(alu_src_sel));

  registers reg_file (
      .clk(clk),
      .rst_n(rst_n),
      .w_en(cs_w.w),
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd_w),
      .w_data(write_back),
      .rd_data1(r1),
      .rd_data2(r2)
  ); 

  function logic[31:0] reg_mux(logic[31:0] rg, register_data_sel sel);
    case(sel)
      RAW: return rg;
      ALU: return alu_res; //TODO Overlapped with reg_e_mux
      default: return write_back; //Imply WB
    endcase
  endfunction

  assign r1_mux = reg_mux(r1, r1_sel);
  assign r2_mux = reg_mux(r2, r2_sel);
  // assign r1_mux = reg_mux(r1, r1_sel);
  // assign r2_mux = reg_mux(r2, r2_sel);

  //Stage 3

  function logic[31:0] reg_e_mux(logic[31:0] rg, register_data_sel sel);
    case(sel)
      RAW: return rg;
      ALU: return alu_res_m;
      MEM: return mem_read_data_w;
      default: return write_back; //Imply WB
    endcase
  endfunction

  assign r1_e_mux = reg_e_mux(r1_e, r1_e_sel);
  assign r2_e_mux = reg_e_mux(r2_e, r2_e_sel);

  assign alu_mux_input_1 = (cs_e.ignore_first_operand)? 0: alu_src_sel_e[0]? pc_e: r1_e_mux;
  assign alu_mux_input_2 = alu_src_sel_e[1]? imm_e: r2_e_mux;

  alu alu_e (
      .func3(func3_e),
      .cs(cs_e),
      .alu_a(alu_mux_input_1),
      .alu_b(alu_mux_input_2),
      // .overwrite_add(alu_src_sel_e[1] & alu_src_sel_e[0] | cs_e.s), //TODO clarify more, when both bits are set, it means its either U or J type. However, we only want to detect U type, and calculate the data to be written, esp in the case of lui and auipc
      .overflow(overflow),
      .zero(zero),
      .alu_result(alu_res)
  );

  assign jmp_addr = pc_e + imm_e;
  assign branch_hit = cs_e.b & (
      (zero && func3_e == EQ) |
      (!zero && func3_e == NE) |
      ((overflow && alu_res[31]) && func3_e == LT) | //对于有符号的比较，当R1 < R2时，OF == SF
      (!(overflow && alu_res[31]) && func3_e == GE) |
      ((alu_res[31]) && func3_e == LTU) |
      (!(alu_res[31]) && func3_e == GEU) 
  );

  multiplier m_e (
    .en(cs_e.m),
    .r1(r1_e_mux),
    .r2(r2_e),
    .op(mul_op_t'(func3_e)),
    .rd(mul_res)
  );

  //Stage 4

  assign cs_om = cs_m;
  assign mem_write_addr = alu_res_m;
  assign mem_write_data = r2_e_mux_m;

  //Stage 5

  assign write_back = (cs_w.j | cs_w.b)? pc_w + 4: cs_w.l? mem_read_data_w : alu_res_w;

 //Misc

  hazard hz(rs1, rs2, rs1_e, rs2_e, rd_e, rd_m, rd_w, cs_e, cs_m, cs_w, branch_hit, r1_sel, r2_sel, r1_e_sel, r2_e_sel, stall_f, stall_d, flush_f, flush_d, flush_e);

  always_comb begin
    if(cs_e.j | branch_hit) begin
      $display("[time=%0t j=0x%0h b=0x%0h addr=0x%0h(b) 0x%0h(j)", $time, cs_e.j, branch_hit, jmp_addr, alu_res);
    end
  end
  initial begin
  end
endmodule
