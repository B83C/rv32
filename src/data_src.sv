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

  reg ['h4096:0][7:0] data;
  reg [7:0] unpacked_data ['h4096:0];

  always @(posedge clk) begin
    if(cs.l) begin
      memory <= {data[addr +:4]}& mask(data_width'(cs.dw)) | {{32{cs.sign_ex & get_msb(data_width'(cs.dw), data[addr +:4])}} & ~mask(data_width'(cs.dw))}; //TODO: Clean up
      $display("Loading from memory at %h, data: %h", addr, {data[addr +:4]}& mask(data_width'(cs.dw)) | {{32{cs.sign_ex & get_msb(data_width'(cs.dw), data[addr +:4])}} & ~mask(data_width'(cs.dw))});
    end   
  end

  //Little endian
  always @(negedge clk) begin
    if (cs.s) begin
      $display("Storing to memory at %h, data: %h", addr, {>>8{wdata & mask(data_width'(cs.dw))}});
      data[addr +:4] <= {>>8{wdata & mask(data_width'(cs.dw))}};
    end
  end

  integer file, r;
  initial begin
    file = $fopen("../zig-out/bin/rv32_fpga.bin", "rb");
    if (file != 0) begin
      r = $fread(unpacked_data, file, 0, 'h2048);  // Read raw binary data into memory
      data = {<<8{unpacked_data}};
      $fclose(file);
    end else begin
      $fatal("Failed to open binary file.");
    end
    // instr_mem[(0*4) +:4] = 32'h17110000;
    // instr_mem[(1*4) +:4] = 32'h13010106;
    // instr_mem[(2*4) +:4] = 32'h37050080;
    // instr_mem[(3*4) +:4] = 32'h13050505;
    // instr_mem[(4*4) +:4] = 32'h9305d000;
    // instr_mem[(5*4) +:4] = 32'h37060010;
    // instr_mem[(6*4) +:4] = 32'h638c0500;
    // instr_mem[(7*4) +:4] = 32'h83460500;
    // instr_mem[(8*4) +:4] = 32'h2320d600;
  end
endmodule
