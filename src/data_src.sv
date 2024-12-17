`timescale 1ns / 1ps
`include "defs.svh"

//Named it source instead of memory so change of name is not needed when cache is implemented
module data_src (
    input clk,
    input [31:0] addr,
    input [31:0] wdata,
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

  function get_msb(data_width dw, logic[31:0] r);
    case(dw) 
      DB: return r[7];
      DH: return r[15];
      DW: return r[31];
      default: return 0;
    endcase
  endfunction

  reg [255:0][7:0] data;

  always @(posedge clk) begin
    if(cs.l) begin
      memory <= {data[addr +:4]}& mask(data_width'(cs.dw)) | {{32{cs.sign & get_msb(data_width'(cs.dw), data[addr +:4])}} & ~mask(data_width'(cs.dw))}; //TODO: Clean up
    end   
  end

  //Little endian
  always @(negedge clk) begin
    if (cs.s) begin
      data[addr +:4] <= {>>8{wdata & mask(data_width'(cs.dw))}};
    end
  end
endmodule
