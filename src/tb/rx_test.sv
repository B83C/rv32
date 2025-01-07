`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/05 20:05:49
// Design Name: 
// Module Name: rt_test
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


module rx_test(
    
    );

    wire rx_data_valid;
    wire [7:0] rx_data;
    wire rx_ready;

    reg rx;
    reg [1:0] rx_ctrl;
    reg clk;
    reg rst;


    uart_rx#(
        .CLK_FREQ(100_000_000),
        .BODE_RATE(10_000_000)
    ) r1(
    .rx_data_valid(rx_data_valid),
    .rx_data(rx_data),
    .rx(rx),
    .rx_ctrl(rx_ctrl),
    .rx_ready(rx_ready),

    .clk(clk),
    .rst(rst)
    );
    localparam period = 100;
initial fork
    $dumpfile("waveform.fst");
    $dumpvars(0, tb);

    clk = 1;
    rst = 1;
    rx=1;
    #10 rst = 0;

    rx_ctrl = 2'b00;

    #40 begin
        rx= 0;
        #period rx= 1;
        #period rx= 0;
        #period rx= 1;
        #period rx= 0;
        #period rx= 1;
        #period rx= 0;
        #period rx= 1;
        #period rx= 0;

        #period rx= 1;
    end

    #2000 fork
        rx_ctrl = 2'b01;
        #10 begin
        rx= 0;
        #period rx= 1;
        #period rx= 0;
        #period rx= 1;
        #period rx= 0;
        #period rx= 1;
        #period rx= 0;
        #period rx= 1;
        #period rx= 0;

        #period rx= 1;
    end
    join

    #4000 fork
        rx_ctrl = 2'b01;
        #10 begin
        rx= 0;
        #period rx= 0;
        #period rx= 1;
        #period rx= 1;
        #period rx= 0;
        #period rx= 0;
        #period rx= 1;
        #period rx= 1;
        #period rx= 0;

        #period rx= 1;
    end
    join

        #6000 fork
        rx_ctrl = 2'b11;
        #10 begin
        rx= 0;
        #period rx= 0;
        #period rx= 0;
        #period rx= 0;
        #period rx= 0;
        #period rx= 1;
        #period rx= 1;
        #period rx= 1;
        #period rx= 1;

        #period rx= 1;
    end
    join

        #8000 fork
        rx_ctrl = 2'b10;
        #10 begin
        rx= 0;
        #period rx= 1;
        #period rx= 1;
        #period rx= 0;
        #period rx= 0;
        #period rx= 1;
        #period rx= 1;
        #period rx= 0;
        #period rx= 0;

        #period rx= 1;
    end
    join

        #10000 fork
        rx_ctrl = 2'b11;
        #10 begin
        rx= 0;
        #period rx= 0;
        #period rx= 1;
        #period rx= 0;
        #period rx= 0;
        #period rx= 0;
        #period rx= 1;
        #period rx= 0;
        #period rx= 0;

        #period rx= 1;
        #200 rx_ctrl = 2'b01;
    end
    
    join    

    #4000 $finish();

join


always #5 clk=~clk;
    

endmodule
