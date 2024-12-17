module sys(
    input clk,
    input rst_n,

    output [3:0] sel,
    output [7:0] dig,

    input uart_rx,
    output rx_ready,
    output uart_tx
);

    localparam CLK_FREQ = 100_000_000;

    wire [15:0] segment_data;
    wire [7:0] uart_r_data;
    wire uart_r_state;
    wire [7:0] uart_r_ctrl;
    wire [7:0] uart_t_data;
    wire uart_t_state;
    wire [7:0] uart_t_ctrl;


    risc_v risc_v1(
        .clk(clk),
        .rst_n(rst_n),

        .segment_data(segment_data),

        .uart_r_data(uart_r_data),
        .uart_r_state(uart_r_state),
        .uart_r_ctrl(uart_r_ctrl),

        .uart_t_data(uart_t_data),
        .uart_t_state(uart_t_state),
        .uart_t_ctrl(uart_t_ctrl)
    );

    translator translator1(
        .clk(clk),
        .rst_n(rst_n),

        .data(segment_data),
        .sel(sel), 
        .dig(dig)
    );

    uart_rx  #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(115200)
    )uart_rx_1 (
        .clk(clk),
        .rst_n(rst_n),
        .rx_data(uart_r_data),
        .rx_data_valid(uart_r_state),
        .rx_ctrl(uart_r_ctrl),
        .rx_ready(rx_ready),
        .rx(uart_rx)
    );

    uart_tx  #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(115200)
    ) uart_tx_1(
        .clk(clk),
        .rst(rst),
        .tx_data(uart_t_data),
        .tx_ready(uart_t_state),
        .tx_data_valid(uart_t_ctrl),
        .tx(uart_tx)
     );


endmodule
