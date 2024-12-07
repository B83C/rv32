`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/04 23:29:17
// Design Name: 
// Module Name: instr_register
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


module instr_register(
    input [7:0] addr,
    output [31:0] instr
    );
    reg [31:0] rom[255:0];
    initial 
    begin
    $readmemb("./data.txt",rom);
    end
    assign instr=rom[addr];
endmodule
