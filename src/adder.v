`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/03 09:25:54
// Design Name: 
// Module Name: adder
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


module CL_adder_4(
     input [3:0] p,
     input [3:0] g,
     input c_in,
     output [3:0] c,
     output cp,cg
    );
    assign c[0]=g[0]|(p[0]&c_in);
    assign c[1]=g[1]|(p[1]&g[0])|(p[1]&p[0]&c_in);
    assign c[2]=g[2]|(p[2]&g[1])|(p[2]&p[1]&g[0])|(p[2]&p[1]&p[0]&c_in);
    assign c[3]=cg|(cp&c_in);
    
    assign cg=g[3]|(p[3]&g[2])|(p[3]&p[2]&g[1])|(p[3]&p[2]&p[1]&g[0]);
    assign cp=p[3]&p[2]&p[1]&p[0];
endmodule

module CL_adder_32(
     input [31:0] A,
     input [31:0] B,
     input c_in,
     output [31:0] C,
     output c_out
);
wire [31:0] TG,TP;
wire [31:0] TC;
wire [7:0] IG,IP;
wire [7:0] TC_1;
wire [3:0] TG_1,TP_1;
wire [3:0] TC_2;
assign TP=A|B;
assign TG=A&B;

CL_adder_4 cla_0_0(.p(TP[3:0]),.g(TG[3:0]),.c_in(c_in),.c(TC[3:0]),.cp(IP[0]),.cg(IG[0]));
CL_adder_4 cla_0_1(.p(TP[7:4]),.g(TG[7:4]),.c_in(TC_1[0]),.c(TC[7:4]),.cp(IP[1]),.cg(IG[1]));
CL_adder_4 cla_0_2(.p(TP[11:8]),.g(TG[11:8]),.c_in(TC_1[1]),.c(TC[11:8]),.cp(IP[2]),.cg(IG[2]));
CL_adder_4 cla_0_3(.p(TP[15:12]),.g(TG[15:12]),.c_in(TC_1[2]),.c(TC[15:12]),.cp(IP[3]),.cg(IG[3]));
CL_adder_4 cla_0_4(.p(TP[19:16]),.g(TG[19:16]),.c_in(TC_1[3]),.c(TC[19:16]),.cp(IP[4]),.cg(IG[4]));
CL_adder_4 cla_0_5(.p(TP[23:20]),.g(TG[23:20]),.c_in(TC_1[4]),.c(TC[23:20]),.cp(IP[5]),.cg(IG[5]));
CL_adder_4 cla_0_6(.p(TP[27:24]),.g(TG[27:24]),.c_in(TC_1[5]),.c(TC[27:24]),.cp(IP[6]),.cg(IG[6]));
CL_adder_4 cla_0_7(.p(TP[31:28]),.g(TG[31:28]),.c_in(TC_1[6]),.c(TC[31:28]),.cp(IP[7]),.cg(IG[7]));

CL_adder_4 cla_1_0(.p(IP[3:0]),.g(IG[3:0]),.c_in(c_in),.c(TC_1[3:0]),.cp(TP_1[0]),.cg(TG_1[0]));
CL_adder_4 cla_1_1(.p(IP[7:4]),.g(IG[7:4]),.c_in(TC_1[3]),.c(TC_1[7:4]),.cp(TP_1[1]),.cg(TG_1[1]));

assign TG_1[3:2]=2'b00;
assign TP_1[3:2]=2'b00;
CL_adder_4 cla_2_0(.p(TP_1[3:0]),.g(TG_1[3:0]),.c_in(1'b0),.c(TC_2[3:0]),.cp(),.cg());
assign c_out=TC_2[1];
assign C=A^B^{TC[30:0],c_in};
endmodule
