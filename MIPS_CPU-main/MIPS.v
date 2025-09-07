`timescale 1ns / 1ps

module MIPS_32;
reg [1:0] J ;
reg perHault ;
wire clk ;
reg clk1 ;
assign clk = clk1 ;
wire [7:0] PCin , PCout,PCout_p1 ;
wire PCc , BC ; // PCc is program counter control and BC is branch control to select condition for PC be updated
wire BranchC ; // to select between Aout and PCout_p1
wire cond ; // to control condition for BEQZ and BNEQZ 
wire [7:0] A ,B,Aout,Bout ; // inputs to ALU and outputs of ALU
wire [31:0] instruction ;
wire insc ;// chip select for Ins
reg inscr ;
assign insc=inscr ;
REG PC (PCin,clk,PCc,PCout);
one_add oa (PCout,PCout_p1);
assign BranchC = 0 ;
MUX2_1 PC_feedback (PCout_p1,Aout,BC,PCin);
Ins Instructions (clk,insc,PCout,instruction); // ROM
reg hault ;
assign PCc=~hault ;
wire [4:0] RA1,RA2,RA3,RA4 ;
assign RA4 = 5'b11111 ;
reg WriteR ;
wire RW  ; // write to registers ;
assign RW = WriteR ;
wire cs ; // to activate eqz ;
wire [7:0] RD1 , RD2 ,RO1 , RO2 ; // data in and out from registers
reg condr,csr ;
assign cond = condr ;
assign cs = csr ;
eqz condition (RO1,cond,cs,BC);
register RB (RW,clk,RD1,RD2,RA1,RA2,RA3,RA4,RO1,RO2);
wire muxA , muxB ; // controls for mux A and mux B
reg muxa , muxb ;
assign muxA=muxa;
assign muxB=muxb;
wire[7:0] IMED ; // to be taken from instruction
reg [7:0] IMEDr ;
assign IMED=IMEDr ;
MUX2_1 MA (RO1,PCout_p1,muxA,A);
MUX2_1 MB (RO2,IMED,muxB,B);
wire Data_write ;
reg DWr ; // to control data write 
assign Data_write = DWr ;
wire [7:0] Data_in,Data_out ; //data into memory 
assign Data_in = RO2 ; 
wire MF ;// to decide what is going back into registers memory or ALU output 
reg MFr ;// for controlling MF 
reg [4:0] temrd ;
assign MF=MFr ;
register_8bit Datamem (Data_write,clk,Data_in,Aout,Data_out);
MUX2_1 memory (Data_out,Aout,MF,RD1);
wire cin , cout ;
wire [2:0] mode ;
reg [2:0] alum ;
reg [4:0] rd ;
assign cin=0 ;
assign RA3 = rd ;
assign mode = alum ;
reg [4:0] Ai,Bi ;
assign RA1=Ai ;
assign RA2=Bi ;
ALU alu (A,B,cin,mode,cout,Aout,Bout);
assign RD2 = Bout ;
reg [5:0] pipe1,pipe2 ;
always @(instruction ) begin
Ai <= instruction[25:21];
Bi <= instruction[15:11]; 
if (pipe1==6'b001000) begin 
case (instruction[31:26])
6'b000000 : begin
hault <= 1 ;
inscr <= 0 ; 
end
6'b000001 : begin
hault <= 1 ;
inscr <= 0 ; 
end
6'b000010 : begin
hault <= 1 ;
inscr <= 0 ; 
end
6'b000011 : begin
hault <= 1 ;
inscr <= 0 ; 
end
6'b000100 : begin
hault <= 1 ;
inscr <= 0 ; 
end
6'b000101 : begin
hault <= 1 ;
inscr <= 0 ; 
end
6'b001001 : begin
hault <= 1 ;
inscr <= 0 ; 
end
6'b001010 : begin
hault <= 1 ;
inscr <= 0 ; 
end
6'b001011 : begin
hault <= 1 ;
inscr <= 0 ; 
end
6'b001100 : begin
hault <= 1 ;
inscr <= 0 ; 
end
endcase
end
end

// counter

wire [7:0] PSW ;
wire [15:0] Timer ;
assign Timer = {RB.regg[28],RB.regg[29]} ;
assign PSW = RB.regg[30] ;
wire [3:0] modex;
always @(cout) begin
RB.regg[30][7] <= cout ;
end
assign modex = PSW[3:0] ;
reg [3:0] modenx ;
wire TA ; 
wire [3:0] com ;
assign com = modenx^modex ;
wire rst ;
assign rst = ~(com[0]|com[1]|com[2]|com[3]);
assign TA=PSW[6] ;
always @(posedge clk) begin 
if (TA) begin
if (rst )begin
 modenx <= 4'b0 ;
end 
else begin 
modenx <= modenx + 1 ; 
end
if (rst) begin 
if ({RB.regg[28],RB.regg[29]}== 16'b0 )begin
RB.regg[30][5]<= 1 ;
RB.regg[30][6] <= 0 ;
end
else begin
{RB.regg[28],RB.regg[29]}<= {RB.regg[28],RB.regg[29]} -1 ; 
end
end

end
end 

// counter

always @(posedge clk) begin 
pipe2=pipe1 ;
// new
if (BC | (J>0)) begin 
pipe1 = 6'b000111 ;
J=J-1 ;
end
else begin 
pipe1 = instruction[31:26] ;
end
if(BC) begin 
J= 2'b01 ;
end
// new
//pipe1 = (BC) ? 6'b000111 : instruction[31:26] ;
WriteR = 1'b0 ;
DWr = 0 ;
csr = 0 ;

if (~hault) begin

case (pipe1)
6'b000000 : begin
 alum <= 3'b000 ;
 rd <= instruction[20:16];
 WriteR <= 1'b1 ;
 hault<=0 ;
 MFr<=1;
 muxa<=0 ;
 muxb<=0 ;
 DWr <= 0 ;
 end
 6'b001110 : begin 
 alum <= 3'b000 ;
 muxa <= 1 ;
 muxb <= 1 ;
 csr <= 1 ;
 condr <= 1 ;
 rd <= instruction[20:16];
 IMEDr <= instruction[10:3];
 end
  6'b001101 : begin 
 alum <= 3'b000 ;
 muxa <= 1 ;
 muxb <= 1 ;
 csr <= 1 ;
 condr <= 0 ;
 IMEDr <= instruction[10:3];
 end
 6'b001010 : begin
 alum <= 3'b000 ;
 IMEDr<= instruction[10:3];
 rd <= instruction[20:16];
 WriteR <= 1'b1 ;
 hault<=0 ;
 MFr<=1;
 muxa<=0 ;
 muxb<=1 ;
 DWr <= 0 ;
 end
6'b000001 : begin 
alum <= 3'b001 ;
rd <= instruction[20:16];
 WriteR <= 1'b1 ;
hault<=0 ;
MFr<=1;
 muxa<=0 ;
 muxb<=0 ;
 DWr <= 0 ;
end
6'b001011 : begin 
alum <= 3'b001 ;
rd <= instruction[20:16];
IMEDr <= instruction[10:3];
 WriteR <= 1'b1 ;
hault<=0 ;
MFr<=1;
 muxa<=0 ;
 muxb<=1 ;
 DWr <= 0 ;
end
6'b000010 : begin 
alum <= 3'b010 ;
rd <= instruction[20:16];
 WriteR <= 1'b1 ;
hault<=0 ;
MFr<=1;
 muxa<=0 ;
 muxb<=0 ;
 DWr <= 0 ;
  pipe2 <= pipe1 ;
end
6'b000011 : begin
 alum <= 3'b011 ;
 rd <= instruction[20:16];
  WriteR <= 1'b1 ;
 hault<=0 ;
 MFr<=1;
  muxa<=0 ;
 muxb<=0 ;
 DWr <= 0 ;
end
6'b000100 : begin 
 alum <= 3'b110 ;
 rd <= instruction[20:16];
  WriteR <= 1'b1 ;
 hault<=0 ;
  muxa<=0 ;
 muxb<=0 ;
 DWr <= 0 ;
end
6'b001100 : begin 
 alum <= 3'b110 ;
 IMEDr <= instruction[10:3];
  WriteR <= 1'b1 ;
 hault<=0 ;
  muxa<=0 ;
 muxb<=1 ;
 DWr <= 0 ;
end
6'b000101 : begin// to be changed later
 alum <= 3'b100 ;
 rd <= instruction[20:16];
  WriteR <= 1'b1 ;
 hault<=0 ;
 MFr<=1;
  muxa<=0 ;
 muxb<=0 ;
 DWr <= 0 ;
 end 
 6'b001001 : begin 
  alum <= 3'b000 ;
 rd <= instruction[20:16];
  WriteR <= 1'b0 ;
 hault<=0 ;
  muxa<=0 ;
 muxb<=1 ;
 DWr <= 1 ;
  IMEDr<= instruction[10:3] ;
 end
 6'b001000 : begin
 alum <= 3'b000 ;
   muxa<=0 ;
 muxb<=1 ;
 temrd <= instruction[20:16];
 IMEDr<= instruction[10:3] ;
  DWr <= 0 ;
  end
 6'b111111 : begin 
  perHault <= 1;
  hault <= 1 ;
  inscr <= 0 ;
  end 
 default : begin
 hault<=0 ;
 WriteR <= 1'b0 ;
 DWr <= 0 ;
 end
endcase
end

if ((hault)&(~perHault)) begin 
hault <=0 ;
inscr <=1 ;
end

case (pipe2)
6'b001000 : begin
WriteR <=  1 ;
MFr <=0 ;
rd <= temrd;
end
endcase
end

wire [7:0] port1 , port2 , port3 , port4 ;
assign port1 = RB.regg[3];
assign port2 = RB.regg[8];
assign port3 = RB.regg[5];
assign port4 = Datamem.regg[11];
always #1 clk1=~clk1 ;
initial begin 
modenx= 0 ;
J=2'b00 ;
csr=0 ;
perHault = 0 ;
inscr = 1 ;
clk1=0 ;
hault = 0 ;
RB.regg[0]=0 ;
RB.regg[1]=2;
RB.regg[2]=1;
RB.regg[4]=10;
RB.regg[5]=4;
RB.regg[3]=8;
RB.regg[7]=7;
RB.regg[6]=5;
PC.Q=8'b0 ;
Datamem.regg[20]=8 ;
end

endmodule
