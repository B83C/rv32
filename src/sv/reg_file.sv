`timescale 1ns/1ps

module reg_file #(
)(
  input clk,
  input [4:0] rs1, rs2, rd,
  input [31:0] lr, 
  input write,
  output [31:0] rg1, rg2
);

logic [31:0] regs[31:0];

always @(negedge clk) begin
  if (write) begin
    regs[rd] <= lr;
  end 
end

assign rg1 = regs[rs1];
assign rg2 = regs[rs2];

endmodule
