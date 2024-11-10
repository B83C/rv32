module ov7670(
  input clk, plk,
  input [7:0] D,
  input vsync, hsync,
  inout sda, scl,
  output reg xclk,
  output reg pwdn, rst
);

reg i2c_reset_n, i2c_enable, i2c_rw;
reg [7:0] i2c_mosi;
reg [7:0] i2c_register_addr;
reg [6:0] i2c_device_addr;
reg [15:0] i2c_divider_cnt;

i2c_master i2c_m (.clk(clk), .sda(sda), .scl(scl), .reset_n(i2c_reset_n), .en(i2c_enable), .rw(i2c_rw), .mosi(i2c_mosi), .register_addr(i2c_register_addr), .device_addr(i2c_device_addr), .divider(i2c_divider_cnt));

assign xclk = clk;

endmodule
