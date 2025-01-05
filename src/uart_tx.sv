`timescale 1ns/1ps

module uart_tx#(
        CLK_FREQ=100_000_000,
        BODE_RATE=115_200
    )(
        output reg tx,
        output reg tx_ready,
        input tx_data_valid,
        input [7:0] tx_data,

        input clk,
        input rst

    );

    localparam CYCLE = CLK_FREQ/BODE_RATE;
    localparam IDLE=0,START=1,SEND=2,STOP=3;

    reg [2:0] state;
    reg [2:0] next_state;

    reg [10:0] cycle_cnt;
    reg [2:0] bit_cnt;

    reg tx_data_valid_r0;//������ָ��ʱ��ͬ��
    reg tx_data_valid_r1;//����ָ����ʱһ����
    wire tx_data_valid_posedge=~tx_data_valid_r1&tx_data_valid_r0;//�����ط�������

    reg [7:0] tx_data_latch;

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst)begin
            tx_data_valid_r0 <= 1'b0;
            tx_data_valid_r1 <= 1'b0;
        end
        else begin
            tx_data_valid_r0 <= tx_data_valid;
            tx_data_valid_r1 <= tx_data_valid_r0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst) 
            cycle_cnt <= 11'b0;
        else if(next_state!=state||cycle_cnt==11'(CYCLE-1)&&state==SEND)
            cycle_cnt <= 11'b0;
        else 
            cycle_cnt <= cycle_cnt + 11'b1;
    end

    always@(posedge clk or posedge rst) begin
        if(rst) 
            bit_cnt <= 3'b0;
        else if(next_state==SEND&&next_state!=state)
            bit_cnt <= 3'b0;
        else if(cycle_cnt==11'(CYCLE-1)&&state==SEND)
            bit_cnt <= bit_cnt + 3'b1;

    end

    always@(*) begin
        case(state) 
            IDLE: begin
                if(tx_data_valid_posedge) //�½��ؿ�ʼͨ��
                    next_state = START;
                else 
                    next_state = IDLE;
                end
            START: begin    //��ʼ��������
                if(cycle_cnt==11'(CYCLE-1))
                    next_state = SEND;
                else 
                    next_state = START;
                end
            SEND:begin
                if(cycle_cnt==11'(CYCLE-1)&&bit_cnt==3'd7) //���ݽ������
                    next_state = STOP;
                else 
                    next_state = SEND;
                end
            STOP:begin
                if(cycle_cnt==11'(CYCLE-1))
                    next_state = IDLE;
                else
                    next_state = STOP;
                end
        default: next_state=IDLE;
        endcase
    end

    always@(posedge clk or posedge rst) begin
        if(rst)
            tx_data_latch <= 8'b0;
        else if(next_state==START)
            tx_data_latch<=tx_data;
    end

    always@(posedge clk or posedge rst)begin
       if(rst)
            tx<=1'b1;
        else begin
            case(next_state)
                IDLE: tx<=1'b1;
                START:tx<=1'b0;
                SEND:tx<=tx_data_latch[bit_cnt];
                STOP:tx<=1'b1;
                default:tx<=1'b1;
            endcase
        end

    end

    

    always@(posedge clk or posedge rst) begin
        if(rst)
            tx_ready <= 1'b0;
        else
            tx_ready <= (next_state==IDLE);
    end


    endmodule
