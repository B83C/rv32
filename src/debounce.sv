`timescale 1ns / 1ps

module debounce#(
    parameter   CYCLES = 100_000,
    parameter   EDGE = 1//1POS,0NEG
)(
    output reg edgebut,

    input button,
    input clk,
    input rst

);


reg [16:0] count;
reg state;
reg nextstate;
reg shift;

always@(posedge clk or posedge rst)begin
    if(rst)
        state<=1'b0;
    else
        state<=nextstate;
end

always@(posedge clk or posedge rst)begin
    if(rst)begin
        count<=17'b0;
    end
    else if(count==CYCLES)begin
        count<=17'b0;
    end
    else if(button==state)begin
        count<=17'b0;
    end
    else begin
        count<=count+17'b1;
    end

end

always@(*)begin
    if(rst) 
        nextstate<=1'b0;
    else if(count==CYCLES)
        nextstate<=~state;
    else 
        nextstate<=state;
end

always@(posedge clk or posedge rst)begin
    if(rst)
        edgebut<=1'b0;
    else if(nextstate!=state && nextstate==EDGE)
        edgebut<=1'b1;
    else
        edgebut<=1'b0;
end

endmodule
