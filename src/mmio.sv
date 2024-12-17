`timescale 1ns / 1ps
`include "defs.svh"

module mmio(
    input clk,
    input [31:0]addr,
    input [31:0] wdata,
    input control_signals_t cs,
    output reg [31:0] out_bus,
    output mem_en,

    input [31:0] memory,

    output reg [15:0] segment_data,//0

    input [7:0] uart_r_data,//1
    input uart_r_state,//2
    output reg [1:0] uart_r_ctrl,//3

    output reg [7:0]uart_t_data,//4
    input uart_t_state,//5
    output reg uart_t_ctrl,//6

    output reg h_sync,//7
    output reg v_sync,//8
    output reg [15:0] x,//9
    output reg [15:0] y,//10
    output reg  video_active//11
);


localparam IO_START = 31'b10000000_0000000000;//128*1024
assign mem_en = (addr[17]==1'b0);

reg [31:0]  io_data;

always @(posedge clk) begin
    if(cs.l)begin
            case(addr[16:0])
                17'd0:io_data <= {{16{1'b0}},segment_data};
                17'd1:io_data <= {{24{1'b0}},uart_r_data};
                17'd2:io_data <= {{24{1'b0}},{8{uart_r_state}}};//copy 8 times
                17'd3:io_data <= {{30{1'b0}},uart_r_ctrl};
                17'd4:io_data <= {{24{1'b0}},uart_t_data};
                17'd5:io_data <= {{24{1'b0}},{8{uart_t_state}}};//copy 8 times
                17'd6:io_data <= {{24{1'b0}},{8{uart_t_ctrl}}};//copy 8 times
                17'd7:io_data <= {{24{1'b0}},{8{h_sync}}};//copy 8 times
                17'd8:io_data <= {{24{1'b0}},{8{v_sync}}};//copy 8 times
                17'd9:io_data <= {{16{1'b0}},x};
                17'd10:io_data <= {{16{1'b0}},y};
                17'd11:io_data <= {{24{1'b0}},{8{video_active}}};//copy 8 times
                default:io_data <= 32'd0;
            endcase
        end
end

always @(*) begin
    if(mem_en) 
        out_bus <= memory;
    else
        out_bus <= io_data;
end

always @(negedge clk) begin
    if(!mem_en&&cs.l) begin
        case(addr[16:0])
            17'd0:segment_data <= wdata[15:0];


            17'd3:uart_r_ctrl <= wdata[1:0];
            17'd4:uart_t_data <= wdata[7:0];

            17'd6:uart_t_ctrl <= wdata[0];
            17'd7:h_sync <= wdata[0];
            17'd8:v_sync <= wdata[0];
            17'd9:x <= wdata[15:0];
            17'd10:y <= wdata[15:0];
            17'd11:video_active <= wdata[0];
            
            default:;
        endcase
    end    

end

endmodule
