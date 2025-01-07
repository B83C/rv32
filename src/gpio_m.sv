module gpio_m (
  inout [7:0]p1,
  inout [7:0]p2,
  output [7:0]p1_o,
  output [7:0]p2_o
);

assign p1_o = p1;
assign p2_o = p2;

endmodule
