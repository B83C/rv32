`timescale 1ns / 1ps

module instr_w_rx (
    output reg [31:0] addr_rx,
    output reg [31:0] instr_data_rx,
    input [7:0] data_in_rx,
    input rx_data_valid,
    output reg w_ready_rx,
    output reg direct_rx,

    input pos_instr_w,
    input neg_instr_w,



    input clk,
    input rst

);


    //reg direct_rx;

    reg[3:0] rx_cnt;
    reg rx_data_valid_d0;
    wire rx_data_valid_pos;




    always @(posedge clk or posedge rst) begin
        if(rst) begin
            direct_rx <= 1'b0;
        end
        else begin
            if(pos_instr_w)
                direct_rx <= 1'b1;
            else if(neg_instr_w)
                direct_rx <= 1'b0;
            else
                direct_rx <= direct_rx;
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
            instr_data_rx <= 32'b0;
            addr_rx <= 32'b0;
        end
        else begin
            if(direct_rx) begin
                if(rx_data_valid_pos) begin
                    //instr_data_rx[rx_cnt*8+7:rx_cnt*8] <= data_in_rx;
                    case(rx_cnt)
                        4'd0: instr_data_rx[7:0] <= data_in_rx;
                        4'd1: instr_data_rx[15:8] <= data_in_rx;
                        4'd2: instr_data_rx[23:16] <= data_in_rx;
                        4'd3: instr_data_rx[31:24] <= data_in_rx;
                        4'd4: addr_rx[7:0] <=data_in_rx;
                        4'd5: addr_rx[15:8] <=data_in_rx;
                        4'd6: addr_rx[23:16] <=data_in_rx;
                        4'd7: addr_rx[31:24] <=data_in_rx;
                        default: begin
                            instr_data_rx[31:0] <= 32'b0;
                            addr_rx[31:0] <= 32'b0;
                        end
                    endcase
                end

            end
        end

    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            rx_cnt <= 4'b0;
            w_ready_rx <= 1'b0;
        end
        else if(pos_instr_w)begin
            rx_cnt <= 4'b0;
            w_ready_rx <= 1'b0;
        end
        else begin
            if(direct_rx) begin
                if(rx_cnt == 4'd8) begin//8 as output direct_rx
                    rx_cnt <= 4'b0;
                    w_ready_rx <= 1'b1;
                end

                else if(rx_data_valid_pos) begin
                    rx_cnt <= rx_cnt + 4'b1;
                    w_ready_rx <= 1'b0;
                end
                else begin
                    rx_cnt <= rx_cnt;
                    w_ready_rx <= 1'b0;
                end
            end
        end
    end



    // always @(posedge clk or posedge rst) begin
    //     if(rst) begin
    //         addr_rx <= 32'b0;
    //     end
    //     else if(pos_instr_w) begin
    //         addr_rx <= 32'b0;
    //     end
    //     else begin
    //         if(direct_rx) begin
    //             if(w_ready_rx == 1'b1) begin
    //                 addr_rx<=addr_rx+32'd1;
    //             end
    //             else begin
    //                 addr_rx<=addr_rx;
    //             end
    //         end
    //     end
    // end


endmodule