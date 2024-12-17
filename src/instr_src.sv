`timescale 1ns / 1ps

//Named it source instead of memory so change of name is not needed when cache is implemented
module instr_src(
    input [31:0] addr,
    output [31:0] instr
);
  reg [31:0] instr_mem[255:0];
  initial $readmemb("/tmp/risc_v2.txt", instr_mem);  
  // always @(posedge clk) begin
  assign instr = instr_mem[addr];
    // instr[7:0]   = instr_mem[addr+3];
    // instr[15:8]  = instr_mem[addr+2];
    // instr[23:16] = instr_mem[addr+1];
    // instr[31:24] = instr_mem[addr];
  // end

endmodule
