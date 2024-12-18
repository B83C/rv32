module gpio (
  inout [7:0]JB,
  inout [7:0]JC,
  output [7:0]JB_o,
  output [7:0]JC_o
);

assign JB_o = JB;
assign JC_o = JC;
endmodule
