module uart_rx#(
        CLK_FREQ=100_000_000,
        BODE_RATE=115_200
    )(
        output reg rx_data_valid,
        output reg [7:0] rx_data,
        input rx,
        input rx_finished,


        input clk,
        input rst

    );

    localparam CYCLE = CLK_FREQ/BODE_RATE;
    localparam IDLE=1,START=2,REC=3,STOP=4,DATA=5;

    reg [2:0] state;
    reg [2:0] next_state;

    reg [7:0] cycle_cnt;
    reg [2:0] bit_cnt;


    always@(posedge clk or posedge rst) begin
        if(rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst) 
            cycle_cnt <= 8'b0;
        else if(next_state!=state||cycle_cnt==CYCLE-1&&state==REC)
            cycle_cnt <= 8'b0;
        else 
            cycle_cnt <= cycle_cnt + 8'b1;
    end

    always@(posedge clk or posedge rst) begin
        if(rst) 
            bit_cnt <= 3'b0;
        else if(next_state==REC)
            bit_cnt <= 3'b0;
        else if(cycle_cnt==CYCLE-1&&state==REC)
            bit_cnt <= bit_cnt + 3'b1;

    end

    always@(*) begin
        case(state) 
            IDLE: begin
                if(rx==1'b0) //下降沿开始通信
                    next_state = START;
                else 
                    next_state = IDLE;
                end
            START: begin    //开始接收数据
                if(cycle_cnt==CYCLE-1)
                    next_state = REC;
                else 
                    next_state = START;
                end
            REC:begin
                if(cycle_cnt==CYCLE-1&&bit_cnt==3'd7) //数据接收完成
                    next_state = STOP;
                else 
                    next_state = REC;
                end
            STOP:begin
                if(cycle_cnt==CYCLE/2-1)
                    next_state = DATA;
                else
                    next_state = STOP;
                end
            DATA:begin
                if(rx_finished)
                    next_state = IDLE;
                else 
                    next_state = DATA;
            end
        default: next_state=IDLE;
        endcase
    end

    always@(posedge clk or posedge rst) begin
        if(rst)
            rx_data <= 8'b0;
        else if(state==REC&&cycle_cnt==CYCLE/2-1)
            rx_data[bit_cnt] <= rx;
    end

    always@(posedge clk or posedge rst) begin
        if(rst)
            rx_data_valid <= 1'b0;
        else
            rx_data_valid <= (next_state==DATA);
    end



    endmodule
