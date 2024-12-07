`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/05 21:00:48
// Design Name: 
// Module Name: branch
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


module branch(
     input beq,
     input bne,
     input blt,
     input bge,
     input bltu,
     input bgeu,
     input jal,
     input jalr,
     output jump_flag
    );
    assign jump_flag=beq|bne|blt|bge|bltu|bgeu|jal|jalr;
endmodule
