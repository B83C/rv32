`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/08 15:03:57
// Design Name: 
// Module Name: data_mem
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

//���ݴ洢��
module data_mem (
    input clk,
    input [31:0] addr,
    input [31:0] data2,
    input lw_en,
    input sw_en,
    input lh_en,
    input sh_en,
    input lb_en,
    input sb_en,
    output reg [31:0] data_mem,

    output [15:0] segment,
    input [7:0] uart_r_data,
    output [7:0] uart_t_data,
    input uart_r_vaild,
    input uart_t_ready,
    output uart_t_data_valid,
    output uart_r_finished
);
  localparam IO_REG_COUNT = 6;
  localparam REAL_MEM = 255-IO_REG_COUNT;
  reg [7:0] data[0:REAL_MEM];//ֻ��256-6=250�������ڴ��ֽ�

  reg [7:0] data_in[0:255];//��cpu�ṩ256λ��ַ����д��

  always @(*)begin
    for (integer i = 0; i < 255; i=i+1) begin//IO�Ĵ����е���IO��Ԫ��ֵ��cpuֻ�����е���cpu��ֵ�����߼���˵cpuֻ��Ҫд��������ȻҲ���Զ�
       case(255-i)
        0:data[i]=data_in[i];
        1:data[i]=data_in[i];//����ܿ��Զ�д
        2:data[i]=uart_r_data;//���ڽ���ֻ��
        3:data[i]=data_in[i];//���ڷ��Ϳ��Զ�д
        4:data[i]={6'b0,uart_t_ready,uart_r_vaild};//����״ֻ̬��
        5:data[i]=data_in[i];//����������Զ�д
        default:data[i]=data_in[i];//�ڴ���
      endcase
    end
  end

assign segment = {data[254],data[255]};
assign uart_t_data_valid=data[250][1];
assign uart_r_finished=data[250][0];
assign uart_t_data = data[252];


  //������д��
  always @(posedge clk) begin
    if (lw_en) begin
      data_mem[7:0]   <= data[addr+3];
      data_mem[15:8]  <= data[addr+2];
      data_mem[23:16] <= data[addr+1];
      data_mem[31:24] <= data[addr];
    end else if (lh_en) begin
      data_mem[7:0]   <= data[addr+3];
      data_mem[15:8]  <= data[addr+2];
      data_mem[23:16] <= 8'b0;
      data_mem[31:24] <= 8'b0;
    end else if (lb_en) begin
      data_mem[7:0]   <= data[addr+3];
      data_mem[15:8]  <= 8'b0;
      data_mem[23:16] <= 8'b0;
      data_mem[31:24] <= 8'b0;
    end else begin
      data_mem[7:0]   <= 8'b0;
      data_mem[15:8]  <= 8'b0;
      data_mem[23:16] <= 8'b0;
      data_mem[31:24] <= 8'b0;
    end
  end
  //�½��ض�ȡ
  always @(negedge clk) begin
    if (sw_en) begin
      data_in[addr+3] <= data2[7:0];
      data_in[addr+2] <= data2[15:8];
      data_in[addr+1] <= data2[23:16];
      data_in[addr]   <= data2[31:24];
    end else if (sh_en) begin
      data_in[addr+3] <= data2[7:0];
      data_in[addr+2] <= data2[15:8];
      data_in[addr+1] <= 8'b0;
      data_in[addr]   <= 8'b0;
    end else if (sb_en) begin
      data_in[addr+3] <= data2[7:0];
      data_in[addr+2] <= 8'b0;
      data_in[addr+1] <= 8'b0;
      data_in[addr]   <= 8'b0;
    end else begin
      data_in[addr+3] <= 8'b0;
      data_in[addr+2] <= 8'b0;
      data_in[addr+1] <= 8'b0;
      data_in[addr]   <= 8'b0;
    end
  end


endmodule
