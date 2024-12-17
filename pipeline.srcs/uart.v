// module uart#(
//     parameter clk_freq = 100_000_000,
//     parameter baud_rate = 115200
//     ) (
//     output tx,
//     output receive_reg,
//     output state_reg,
    
//     input rx,
//     input [1:0]order_reg,
//     input send_reg,

//     input clk,
//     input rst

// );


// reg [1:0]order_reg_d1;
// wire order_reg_posedge;

// localparam IDLE = 0,R_START=1,R_RECEIVE=2,R_STOP=3,R_DATA=4,S_START=5,S_SEND=6,S_STOP=7,ERROR=8;

// localparam IDLE_IN=0,R_IN=1,S_IN=2,RST_IN=3;

// localparam PERIOD = clk_freq/baud_rate;

// reg [4:0] state;
// reg [4:0]  next_state;

// always @(posedge clk or posedge rst) begin
//     if(rst) begin
//         state <= IDLE;
//     end else begin
//         state <= next_state;
//     end
// end

// always @(posedge clk or posedge rst) begin
//     if(rst) begin
//         order_reg_d1 <= IDLE_IN;
//     end else begin
//         order_reg_d1 <= order_reg;
//     end
// end
// assign order_reg_posedge = order_reg != order_reg_d1;



    
// endmodule