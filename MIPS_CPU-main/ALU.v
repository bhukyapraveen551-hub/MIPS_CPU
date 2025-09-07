`timescale 1ns / 1ps

module eqz (input [7:0] in , 
input cond ,cs,
output out);
assign out = (in==8'b0) ? cond&cs : ~cond&cs ;
endmodule

module adder (input [7:0] IN ,
input add , output [7:0] out);
assign out = (add) ? IN+1 : IN ;
endmodule

module one_add (input [7:0] In , output [7:0] out);
assign out = In + 8'b00000001 ;
endmodule

module REG (input [7:0] D , 
input clk , in ,
output reg [7:0] Q );
always @(posedge clk) begin
if(in) Q<=D ;
end
endmodule

module REG16 (input [15:0] D , 
input clk , in ,
output reg [15:0] Q );
always @(posedge clk) begin
if(in) Q<=D ;
end
endmodule

module MUX2_1 (input [7:0] A1,A2, 
input S , 
output reg [7:0] O);
always @(*) begin
if(S) O<=A2 ;
else if (~S) O<=A1 ;
end
endmodule

module MUX2_1_16 (input [15:0] A1,A2, 
input S , 
output reg [15:0] O);
always @(*) begin
if(S) O<=A2 ;
else if (~S) O<=A1 ;
end
endmodule

module ALU(input [7:0] A,
 input [7:0] B ,
 input Cin ,
 input [2:0] mode ,
 output reg Cout ,
 output reg [7:0] Ao , Bo);
 wire [7:0] b_not ;
 assign b_not = ~B ;
 always @(*) begin
 case(mode)
  3'b000 :  {Cout,Ao}= A+B+Cin ; 
  3'b001 :  {Cout,Ao}= A+b_not+Cin+1 ;
  3'b010 :  Ao=A&B ;
  3'b011 :  Ao=A|B ;
  3'b100 : {Bo,Ao}=A*B;
  3'b101 : {Bo,Ao}={A%B,A/B} ;
  3'b110 : Ao= (A<B)? 8'b00000001 : 8'b0 ;
 endcase
 end
endmodule