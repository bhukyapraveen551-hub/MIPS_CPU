//`timescale 1ns / 1ps

module Ins(input clk,input cs, 
input [7:0] Add ,
output [31:0] Data );
reg [31:0] Data_1 ;
reg [31:0] mem [255:0] ;
initial begin
//mem[0]=32'hffaf ;
$readmemh ("data.dat",mem,0,100);
end
assign Data= Data_1 ;
always @(posedge clk) begin
if (cs) Data_1<=mem[Add];
end
endmodule

module Mem(input R ,W, clk, 
input [7:0] Add ,
inout [7:0] Data );
reg [7:0] Data_1 ;
assign Data= (R && ~W) ? Data_1 : 8'bz ;
reg [7:0] mem [255:0] ;
always @(posedge clk) begin
if (R && ~W) begin
Data_1<=mem[Add];
end
else if (~R && W) begin 
mem[Add] <= Data ;
end
end
endmodule

module registers(input R ,W, clk, 
input [4:0] Add ,
inout [7:0] Data );
reg [7:0] Data_1 ;
assign Data= (R && ~W) ? Data_1 : 8'bz ;
reg [7:0] mem [31:0] ;
always @(posedge clk) begin
if (R && ~W) begin
Data_1<=mem[Add];
end
else if (~R && W) begin 
mem[Add] <= Data ;
end
end
endmodule

module register (input W,clk,
input [7:0] data1, data2, 
input [4:0] add1 ,add2 , add3, add4,
output [7:0] out1 , out2);
reg [7:0] outt1, outt2 ;
reg [7:0] regg [31:0] ;
assign out1=outt1 ;
assign out2=outt2 ;
always @(posedge clk) begin
if (W) begin 
regg[add3]<=data1;
regg[add4]<=data2;
end
if(add1==1'b0) begin
outt1<= 8'b0;
outt2<= regg[add2];
end
else begin
outt1 <= regg[add1];
outt2 <= regg[add2];
end
end
endmodule

module register_8bit (input W,clk,
input [7:0] data1,
input [7:0] add1 ,
output [7:0] out1);
reg [7:0] outt1 ;
reg [7:0] regg [255:0] ;
assign out1=outt1 ;
always @(posedge clk) begin
if (W) begin 
regg[add1]=data1;
end
outt1 = regg[add1];
end
endmodule
