`timescale 1ns / 1ps

module registers (
    input clk,
    input rst,
    input w_en,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] w_data,
    output [31:0] rd_data1,
    output [31:0] rd_data2
);
  logic [31:0][31:0]regs;

  //Synched writes
  always @(posedge clk or posedge rst) begin
    if (rst) regs <= 0;
    else if (w_en & (rd != 0)) begin
      $display("Writing to register: %h, Data: %h", rd, w_data);
    	regs[rd] <= w_data;
    end
  end

  //Async reads
  assign rd_data1 = (rs1 == 5'd0) ? 32'b0 : regs[rs1];
  assign rd_data2 = (rs2 == 5'd0) ? 32'b0 : regs[rs2];
endmodule
