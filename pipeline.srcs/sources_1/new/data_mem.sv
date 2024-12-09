`timescale 1ns / 1ps
`include "defs.svh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/08 15:03:57
// Design Name: 
// Module Name: data_mem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//数据存储器
module data_mem (
    input clk,
    input [31:0] addr,
    input [31:0] data2,
    input control_signals_t cs,
    output reg [31:0] memory
);

  function [31:0] mask(data_width dw);
    case(dw) 
      DB: return {24'd0, {8{1'b1}}};
      DH: return {16'd0, {16{1'b1}}};
      DW: return {32{1'b1}};
      default: return 0;
    endcase
  endfunction

  reg [255:0][7:0] data;

  always @(posedge clk) begin
    if(cs.l) begin
      memory <= {data[addr +:4]}& mask(data_width'(cs.dw)); //TODO
    end   
  end

  //Little endian
  always @(negedge clk) begin
    if (cs.s) begin
      data[addr +:4] <= {>>8{data2 & mask(data_width'(cs.dw))}};
    end
  end
  //上升沿写入
  // always @(posedge clk) begin
  //   if (lw_en) begin
  //     data_mem[7:0]   <= data[addr+3];
  //     data_mem[15:8]  <= data[addr+2];
  //     data_mem[23:16] <= data[addr+1];
  //     data_mem[31:24] <= data[addr];
  //   end else if (lh_en) begin
  //     data_mem[7:0]   <= data[addr+3];
  //     data_mem[15:8]  <= data[addr+2];
  //     data_mem[23:16] <= 8'b0;
  //     data_mem[31:24] <= 8'b0;
  //   end else if (lb_en) begin
  //     data_mem[7:0]   <= data[addr+3];
  //     data_mem[15:8]  <= 8'b0;
  //     data_mem[23:16] <= 8'b0;
  //     data_mem[31:24] <= 8'b0;
  //   end else begin
  //     data_mem[7:0]   <= 8'b0;
  //     data_mem[15:8]  <= 8'b0;
  //     data_mem[23:16] <= 8'b0;
  //     data_mem[31:24] <= 8'b0;
  //   end
  // end
  // //下降沿读取
  // always @(negedge clk) begin
  //   if (sw_en) begin
  //     data[addr+3] <= data2[7:0];
  //     data[addr+2] <= data2[15:8];
  //     data[addr+1] <= data2[23:16];
  //     data[addr]   <= data2[31:24];
  //   end else if (sh_en) begin
  //     data[addr+3] <= data2[7:0];
  //     data[addr+2] <= data2[15:8];
  //     data[addr+1] <= 8'b0;
  //     data[addr]   <= 8'b0;
  //   end else if (sb_en) begin
  //     data[addr+3] <= data2[7:0];
  //     data[addr+2] <= 8'b0;
  //     data[addr+1] <= 8'b0;
  //     data[addr]   <= 8'b0;
  //   end else begin
  //     data[addr+3] <= 8'b0;
  //     data[addr+2] <= 8'b0;
  //     data[addr+1] <= 8'b0;
  //     data[addr]   <= 8'b0;
  //   end
  // end
endmodule
