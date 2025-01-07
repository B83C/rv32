`timescale 1ns / 1ps

module instr_w (
    output reg [31:0] addr,
    output reg [31:0] instr_data,
    input [7:0] data_in,
    input rx_data_valid,
    output reg w_ready,
    output reg state,

    input pos_instr_w,
    input neg_instr_w,



    input clk,
    input rst

);


    //reg state;

    reg[2:0] rx_cnt;
    reg rx_data_valid_d0;
    wire rx_data_valid_pos;




    always @(posedge clk or posedge rst) begin
        if(rst) begin
            state <= 1'b0;
        end
        else begin
            if(pos_instr_w)
                state <= 1'b1;
            else if(neg_instr_w)
                state <= 1'b0;
            else
                state <= state;
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            rx_data_valid_d0 <= 1'b0;
        end
        else
            rx_data_valid_d0 <= rx_data_valid;
    end

    assign rx_data_valid_pos = (rx_data_valid & ~rx_data_valid_d0);


    always @(posedge clk or posedge rst) begin
        if(rst) begin
            instr_data <= 32'b0;
        end
        else begin
            if(state) begin
                if(rx_data_valid_pos) begin
                    //instr_data[rx_cnt*8+7:rx_cnt*8] <= data_in;
                    case(rx_cnt)
                        3'd0: instr_data[7:0] <= data_in;
                        3'd1: instr_data[15:8] <= data_in;
                        3'd2: instr_data[23:16] <= data_in;
                        3'd3: instr_data[31:24] <= data_in;
                        default: instr_data[31:0] <= 32'b0;
                    endcase
                end

            end
        end

    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            rx_cnt <= 3'b0;
            w_ready <= 1'b0;
        end
        else if(pos_instr_w)begin
            rx_cnt <= 3'b0;
            w_ready <= 1'b0;
        end
        else begin
            if(state) begin
                if(rx_cnt == 3'd4) begin
                    rx_cnt <= 3'b0;
                    w_ready <= 1'b1;
                end

                else if(rx_data_valid_pos) begin
                    rx_cnt <= rx_cnt + 3'b1;
                    w_ready <= 1'b0;
                end
                else begin
                    rx_cnt <= rx_cnt;
                    w_ready <= 1'b0;
                end
            end
        end
    end



    always @(posedge clk or posedge rst) begin
        if(rst) begin
            addr <= 32'b0;
        end
        else if(pos_instr_w) begin
            addr <= 32'b0;
        end
        else begin
            if(state) begin
                if(w_ready == 1'b1) begin
                    addr<=addr+32'd1;
                end
                else begin
                    addr<=addr;
                end
            end
        end
    end


endmodule