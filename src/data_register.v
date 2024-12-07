`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/04 23:44:35
// Design Name: 
// Module Name: data_register
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


module data_register #(
    parameter DATA_WIDTH = 32,  // 数据宽度
    parameter ADDR_WIDTH = 8   // 地址宽度（对应深度为 2^ADDR_WIDTH）
)(
    input clk,
    input rst_n,
    input W_en,
    input R_en,
    input [31:0] addr,            // 全局地址（32 位）
    input [2:0] RW_type,          // 读写类型：{符号扩展, 半字/字节/字选择}
    input [DATA_WIDTH-1:0] din,   // 写入数据
    output [DATA_WIDTH-1:0] dout, // 读取数据
    output error_flag             // 错误标志
);
    integer i;
    // 内存深度和寄存器
    localparam DEPTH = 1 << ADDR_WIDTH; // 存储器深度
    reg [DATA_WIDTH-1:0] ram [0:DEPTH-1];
    
    // 数据基准
    wire [DATA_WIDTH-1:0] Rd_data;
    assign Rd_data = ram[addr[ADDR_WIDTH+1:2]]; // 按 32 位对齐读取基准

    // 错误检测逻辑
    assign error_flag = (addr[31:ADDR_WIDTH+2] != 0) || (W_en && R_en);

    // 写数据拼接逻辑
    function [DATA_WIDTH-1:0] generate_wr_data(
        input [DATA_WIDTH-1:0] Rd_data,
        input [DATA_WIDTH-1:0] din,
        input [2:0] RW_type,
        input [1:0] offset
    );
        reg [DATA_WIDTH-1:0] Wr_data_B, Wr_data_H;
        begin
            // 字节写入拼接
            case (offset)
                2'b00: Wr_data_B = {Rd_data[31:8], din[7:0]};
                2'b01: Wr_data_B = {Rd_data[31:16], din[7:0], Rd_data[7:0]};
                2'b10: Wr_data_B = {Rd_data[31:24], din[7:0], Rd_data[15:0]};
                2'b11: Wr_data_B = {din[7:0], Rd_data[23:0]};
            endcase

            // 半字写入拼接
            Wr_data_H = offset[1] ? {din[15:0], Rd_data[15:0]} : {Rd_data[31:16], din[15:0]};

            // 根据写类型选择最终数据
            generate_wr_data = (RW_type[1:0] == 2'b00) ? Wr_data_B :
                               (RW_type[1:0] == 2'b01) ? Wr_data_H : din;
        end
    endfunction

    // 写操作：复位或正常写入
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < DEPTH; i = i + 1) begin
                ram[i] <= {DATA_WIDTH{1'b0}}; // 清零
            end
        end else if (W_en && !error_flag) begin
            ram[addr[ADDR_WIDTH+1:2]] <= generate_wr_data(Rd_data, din, RW_type, addr[1:0]);
        end
    end

    // 读数据提取逻辑
    function [DATA_WIDTH-1:0] extract_data(
        input [DATA_WIDTH-1:0] Rd_data,
        input [1:0] offset,
        input [2:0] RW_type
    );
        reg [7:0] byte;
        reg [15:0] halfword;
        begin
            // 按偏移量提取字节
            case (offset)
                2'b00: byte = Rd_data[7:0];
                2'b01: byte = Rd_data[15:8];
                2'b10: byte = Rd_data[23:16];
                2'b11: byte = Rd_data[31:24];
            endcase

            // 按偏移量提取半字
            halfword = offset[1] ? Rd_data[31:16] : Rd_data[15:0];

            // 扩展或直接返回
            extract_data = (RW_type[1:0] == 2'b00) ? 
                            (RW_type[2] ? {24'd0, byte} : {{24{byte[7]}}, byte}) :
                            (RW_type[1:0] == 2'b01) ?
                            (RW_type[2] ? {16'd0, halfword} : {{16{halfword[15]}}, halfword}) :
                            Rd_data;
        end
    endfunction

    // 读取数据输出
    assign dout = (R_en && !error_flag) ? extract_data(Rd_data, addr[1:0], RW_type) : {DATA_WIDTH{1'b0}};

endmodule
   
