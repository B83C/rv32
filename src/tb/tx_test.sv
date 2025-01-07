`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/05 21:58:56
// Design Name: 
// Module Name: tx_test
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


module tx_test(

    );

    wire tx_ready;
    wire tx;

    reg [7:0] tx_data;
    reg tx_data_valid;

    reg clk;
    reg rst;

    uart_tx#(
        .CLK_FREQ(100_000_000),
        .BODE_RATE(10_000_000)
    ) r1(
    .tx_data_valid(tx_data_valid),
    .tx_data(tx_data),
    .tx(tx),

    .tx_ready(tx_ready),

    .clk(clk),
    .rst(rst)
    );
    localparam period = 100;

initial fork
    $dumpfile("waveform.fst");
    $dumpvars(0, tb);

    clk = 1;
    rst = 1;
    tx_data_valid=0;

    #10 rst = 0;

    #20 tx_data =8'b1010_0101;
    #40 tx_data_valid=1;

    #200 tx_data_valid=0;
    #220 tx_data_valid=1;


    #1000 tx_data =8'b1101_1101;
    #1120 tx_data_valid=0;
    #1140 tx_data_valid=1;

    #2000 $finish();
join


always #5 clk=~clk;    



endmodule
