`timescale 1ns / 1ps
`include "defs.svh"

module pipeline_unit (
    input clk,
    input rst_n,
    input [31:0] instr,
    input [31:0] data_mem,
    output [31:0] pc_addr,
    output [31:0] mem_write_addr,
    output [31:0] mem_write_data,
    // data_width dw,
    output control_signals_t cs_om
);

  wire branch_hit;
  wire [31:0] jmp_addr;
 
  wire [31:0] instr_d, pc, pc_f, pc_d, pc_e, pc_m, pc_w;
  rbuffer #(32) instr_b (clk, rst_n, instr, instr_d);
  rbuffer #(32) pc_bf (clk, rst_n, pc, pc_f);
  rbuffer #(32) pc_bd (clk, rst_n, pc_f, pc_d);
  rbuffer #(32) pc_be (clk, rst_n, pc_d, pc_e);
  rbuffer #(32) pc_bm (clk, rst_n, pc_e, pc_m);
  rbuffer #(32) pc_bw (clk, rst_n, pc_m, pc_w);

  wire register_data_sel r1_sel, r2_sel;
  wire [4:0] rs1, rs1_e;
  wire [4:0] rs2, rs2_e;
  rbuffer #(5) rs1_be (clk, rst_n, rs1, rs1_e);
  rbuffer #(5) rs2_be (clk, rst_n, rs2, rs2_e);
  wire [4:0] rd, rd_e, rd_m, rd_w;
  rbuffer #(5) rd_be (clk, rst_n, rd, rd_e);
  rbuffer #(5) rd_bm (clk, rst_n, rd_e, rd_m);
  rbuffer #(5) rd_bw (clk, rst_n, rd_m, rd_w);

  wire [31:0] r1, r1_e;
  rbuffer #(32) r1_be (clk, rst_n, r1, r1_e);
  wire [31:0] r2, r2_e;
  rbuffer #(32) r2_be (clk, rst_n, r2, r2_e);

  wire [31:0] r1_mux, r2_mux, r2_mux_m;
  rbuffer #(32) r2_mux_bm (clk, rst_n, r2_mux, r2_mux_m);

  wire [31:0] imm, imm_e;
  rbuffer #(32) imm_be (clk, rst_n, imm, imm_e);

  wire [2:0] func3, func3_e;
  rbuffer #(3) func3_be (clk, rst_n, func3, func3_e);
  wire [1:0] alu_src_sel;

  wire control_signals_t cs, cs_e, cs_m, cs_w;
  rbuffer #($size(control_signals_t)) cs_be (clk, rst_n, cs, cs_e);
  rbuffer #($size(control_signals_t)) cs_bm (clk, rst_n, cs_e, cs_m);
  rbuffer #($size(control_signals_t)) cs_bw (clk, rst_n, cs_m, cs_w);

  wire [31:0] alu_mux_input_1;
  wire [31:0] alu_mux_input_2;
  wire [31:0] alu_res, alu_res_m;
  rbuffer #(32) alu_res_bm (clk, rst_n, alu_res, alu_res_m);

  wire [31:0] write_back;

  //Stage 1
  
  assign pc = (cs_e.j | (cs_e.b && branch_hit))? jmp_addr : pc_f + 4;

  //Stage 2

  ir_dec_ctrl layer2 (.clk(clk), .ir(instr), .cs(cs), .rs1(rs1), .rs2(rs2), .rd(rd), .imm(imm),.func3(func3), .alu_src_sel(alu_src_sel));

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

  //Stage 3

  assign jmp_addr = pc_e + imm_e;

  branch branch_e (
    .en(cs.b),
    .opr1(r1_e),
    .opr2(r2_e),
    .func3(func3_e),
    .success(branch_hit)
    );

  function logic[31:0] reg_mux(logic[31:0] rg, register_data_sel sel);
    case(sel)
      RAW: return rg;
      ALU: return alu_res_m;
      default: return write_back; //Imply WB
    endcase
  endfunction

  assign r1_mux = reg_mux(r1_e, r1_sel);
  assign r2_mux = reg_mux(r2_e, r2_sel);

  assign alu_mux_input_1 = (cs.ignore_first_operand)? 0: alu_src_sel[0]? pc_e: r1_mux;
  assign alu_mux_input_2 = alu_src_sel[1]? imm: r2_mux;

  alu alu_e (
      .func3(func3_e),
      .cs(cs_e),
      .alu_a(alu_mux_input_1),
      .alu_b(alu_mux_input_2),
      .overwrite_add(alu_src_sel[1] & alu_src_sel[0]), //TODO clarify more, when both bits are set, it means its either U or J type. However, we only want to detect U type, and calculate the data to be written, esp in the case of lui and auipc
      .overflow(),
      .alu_result(alu_res)
  );

  //Stage 4

  assign cs_om = cs_m;
  assign mem_write_addr = alu_res_m;
  assign mem_write_data = r2_mux_m;

  //Stage 5

  assign write_back = (cs_w.j | cs_w.b)? pc_w + 4: cs_w.l? data_mem : alu_res_m;

 //Misc

  hazard hz(rs1_e, rs2_e, rd_m, rd_w, cs_m, cs_w, r1_sel, r2_sel);
endmodule
