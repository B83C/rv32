`timescale 1ns / 1ps

//Named it source instead of memory so change of name is not needed when cache is implemented
module instr_src (
    input  [31:0] addr,
    output [31:0] instr
);
  // reg [7:0] file [255:0];
  reg [7:0] instr_mem[255:0];

  integer file, r;
  initial begin
    file = $fopen("../zig-out/bin/rv32_fpga.bin", "rb");
    if (file != 0) begin
      r = $fread(instr_mem, file, 0, 'h1024);  // Read raw binary data into memory
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

  // initial $readmemb("/tmp/risc_v2.txt", instr_mem);  
  // always @(posedge clk) begin
  // assign instr = {<<8{instr_mem[addr]}};
  assign instr = {instr_mem[3+addr], instr_mem[2+addr], instr_mem[1+addr], instr_mem[0+addr]};
  // instr[7:0]   = instr_mem[addr+3];
  // instr[15:8]  = instr_mem[addr+2];
  // instr[23:16] = instr_mem[addr+1];
  // instr[31:24] = instr_mem[addr];
  // end

endmodule
