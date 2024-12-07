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
    parameter DATA_WIDTH = 32,  // ���ݿ��
    parameter ADDR_WIDTH = 8   // ��ַ��ȣ���Ӧ���Ϊ 2^ADDR_WIDTH��
)(
    input clk,
    input rst_n,
    input W_en,
    input R_en,
    input [31:0] addr,            // ȫ�ֵ�ַ��32 λ��
    input [2:0] RW_type,          // ��д���ͣ�{������չ, ����/�ֽ�/��ѡ��}
    input [DATA_WIDTH-1:0] din,   // д������
    output [DATA_WIDTH-1:0] dout, // ��ȡ����
    output error_flag             // �����־
);
    integer i;
    // �ڴ���ȺͼĴ���
    localparam DEPTH = 1 << ADDR_WIDTH; // �洢�����
    reg [DATA_WIDTH-1:0] ram [0:DEPTH-1];
    
    // ���ݻ�׼
    wire [DATA_WIDTH-1:0] Rd_data;
    assign Rd_data = ram[addr[ADDR_WIDTH+1:2]]; // �� 32 λ�����ȡ��׼

    // �������߼�
    assign error_flag = (addr[31:ADDR_WIDTH+2] != 0) || (W_en && R_en);

    // д����ƴ���߼�
    function [DATA_WIDTH-1:0] generate_wr_data(
        input [DATA_WIDTH-1:0] Rd_data,
        input [DATA_WIDTH-1:0] din,
        input [2:0] RW_type,
        input [1:0] offset
    );
        reg [DATA_WIDTH-1:0] Wr_data_B, Wr_data_H;
        begin
            // �ֽ�д��ƴ��
            case (offset)
                2'b00: Wr_data_B = {Rd_data[31:8], din[7:0]};
                2'b01: Wr_data_B = {Rd_data[31:16], din[7:0], Rd_data[7:0]};
                2'b10: Wr_data_B = {Rd_data[31:24], din[7:0], Rd_data[15:0]};
                2'b11: Wr_data_B = {din[7:0], Rd_data[23:0]};
            endcase

            // ����д��ƴ��
            Wr_data_H = offset[1] ? {din[15:0], Rd_data[15:0]} : {Rd_data[31:16], din[15:0]};

            // ����д����ѡ����������
            generate_wr_data = (RW_type[1:0] == 2'b00) ? Wr_data_B :
                               (RW_type[1:0] == 2'b01) ? Wr_data_H : din;
        end
    endfunction

    // д��������λ������д��
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < DEPTH; i = i + 1) begin
                ram[i] <= {DATA_WIDTH{1'b0}}; // ����
            end
        end else if (W_en && !error_flag) begin
            ram[addr[ADDR_WIDTH+1:2]] <= generate_wr_data(Rd_data, din, RW_type, addr[1:0]);
        end
    end

    // ��������ȡ�߼�
    function [DATA_WIDTH-1:0] extract_data(
        input [DATA_WIDTH-1:0] Rd_data,
        input [1:0] offset,
        input [2:0] RW_type
    );
        reg [7:0] byte;
        reg [15:0] halfword;
        begin
            // ��ƫ������ȡ�ֽ�
            case (offset)
                2'b00: byte = Rd_data[7:0];
                2'b01: byte = Rd_data[15:8];
                2'b10: byte = Rd_data[23:16];
                2'b11: byte = Rd_data[31:24];
            endcase

            // ��ƫ������ȡ����
            halfword = offset[1] ? Rd_data[31:16] : Rd_data[15:0];

            // ��չ��ֱ�ӷ���
            extract_data = (RW_type[1:0] == 2'b00) ? 
                            (RW_type[2] ? {24'd0, byte} : {{24{byte[7]}}, byte}) :
                            (RW_type[1:0] == 2'b01) ?
                            (RW_type[2] ? {16'd0, halfword} : {{16{halfword[15]}}, halfword}) :
                            Rd_data;
        end
    endfunction

    // ��ȡ�������
    assign dout = (R_en && !error_flag) ? extract_data(Rd_data, addr[1:0], RW_type) : {DATA_WIDTH{1'b0}};

endmodule
   
