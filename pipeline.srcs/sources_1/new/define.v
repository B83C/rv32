`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/03 14:31:48
// Design Name: 
// Module Name: define
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
`define zero_word  32'd0
`define I_type  7'b0010011
`define R_type  7'b0110011
`define B_type  7'b1100011
`define load    7'b0000011
`define store   7'b0100011
`define jal     7'b1101111
`define jalr    7'b1100111
`define lui     7'b0110111
`define auipc   7'b0010111

//ALU function immediate ,may look this know the type of each functions
`define ADDI 3'b000
`define SLTI 3'b010
`define SLTIU 3'b011
`define XORI 3'b100
`define ORI  3'b110
`define ANDI 3'b111
`define SLLI 10'b0000000_001
`define SRLI 10'b0000000_101
`define SRAI 10'b0100000_101
//ALU function register
`define ADD 10'b0000000_000
`define SUB 10'b0100000_000
`define SLL 10'b0000000_001
`define SLT 10'b0000000_010
`define SLTU 10'b0000000_011
`define XOR 10'b0000000_100
`define SRL 10'b0000000_101
`define SRA 10'b0100000_101
`define OR 10'b0000000_110
`define AND 10'b0000000_111
