`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/05 23:29:08
// Design Name: 
// Module Name: IF_stage
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


module IF_stage(
    input clk,
    input rst_n,
    input [31:0] pc_IF_I,
    output [31:0] pc_IF_O,
    output [7:0] rom_addr
    );
    
    PC_addr U1(.clk(clk),.rst_n(rst_n),.pc_new(pc_IF_I),.pc_out(pc_IF_O));
    
    assign rom_addr=pc_IF_O[9:2];
endmodule
