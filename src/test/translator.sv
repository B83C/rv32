`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:16:15 08/17/2024 
// Design Name: 
// Module Name:    translator 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module translator(
    output  [7:0] dig,
    output  [5:0] sel,
    input [15:0] data,

    input clk,
	input rst_n
    );

parameter scan=32'd99_99;


wire [3:0] d0;
wire [3:0] d1;
wire [3:0] d2;
wire [3:0] d3;

parameter ten=14'd10;

assign d0=data%ten;
assign d1=(data/ten)%ten;
assign d2=(data/14'd100)%ten;
assign d3=data/14'd1000;

wire [3:0] d;

reg[1:0] scanner;
reg[31:0] counter;



always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0)begin
        counter<=32'b0;
        scanner<=2'b0;
    end
    else if(counter==scan)begin
        counter<=32'b0;
        if(scanner==2'd3)
            scanner<=2'd0;
        else
            scanner<=scanner+2'b1;
    end
    else
        counter<=counter+32'b1;
end




assign d=({4{scanner==2'd0}}&d0)|({4{scanner==2'd1}}&d1)|({4{scanner==2'd2}}&d2)|({4{scanner==2'd3}}&d3);

parameter ther=scan-50;//提前放电

assign sel[3]=~(scanner==2'd3);
assign sel[2]=~(scanner==2'd2);
assign sel[1]=~(scanner==2'd1);
assign sel[0]=~(scanner==2'd0);

assign dig[7]=1'b1;
assign dig[6]= ~(d==4'd2||d==4'd3||d==4'd4||d==4'd5||d==4'd6||d==4'd8||d==4'd9);
assign dig[5]= ~(d==4'd4||d==4'd5||d==4'd6||d==4'd8||d==4'd9||d==4'd0);
assign dig[4]= ~(d==4'd2||d==4'd6||d==4'd8||d==4'd0);
assign dig[3]= ~(d==4'd2||d==4'd3||d==4'd5||d==4'd6||d==4'd8||d==4'd9||d==4'd0);
assign dig[2]= ~(d==4'd1||d==4'd3||d==4'd4||d==4'd5||d==4'd6||d==4'd7||d==4'd8||d==4'd9||d==4'd0);
assign dig[1]= ~(d==4'd1||d==4'd2||d==4'd3||d==4'd4||d==4'd7||d==4'd8||d==4'd9||d==4'd0);
assign dig[0]= ~(d==4'd2||d==4'd3||d==4'd5||d==4'd6||d==4'd7||d==4'd8||d==4'd9||d==4'd0);


endmodule
