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
    output reg uart_t_ctrl//6
);


localparam IO_START = 31'b10000000_0000000000;//128*1024
assign mem_en = (addr[17]==1'b0);

always @(posedge clk) begin
    if(cs.l)begin
        if(!mem_en) begin
            case(addr[16:0])
                17'd0:out_bus <= {{16{1'b0}},segment_data};
                17'd1:out_bus <= {{24{1'b0}},uart_r_data};
                17'd2:out_bus <= {{24{1'b0}},{8{uart_r_state}}};
                17'd3:out_bus <= {{30{1'b0}},uart_r_ctrl};
                17'd4:out_bus <= {{24{1'b0}},uart_t_data};
                17'd5:out_bus <= {{24{1'b0}},{8{uart_t_state}}};
                17'd6:out_bus <= {{24{1'b0}},{8{uart_t_ctrl}}};//¸´ÖÆ8Î»
                default:out_bus <= 32'd0;
            endcase
        end
        else
            out_bus <= memory;
    end
end

always @(negedge clk) begin
    if(!mem_en&&cs.l) begin
        case(addr[16:0])
            17'd0:segment_data <= wdata[15:0];


            17'd3:uart_r_ctrl <= wdata[1:0];
            17'd4:uart_t_data <= wdata[7:0];

            17'd6:uart_t_ctrl <= wdata[0];
            default:;
        endcase
    end    

end

endmodule
