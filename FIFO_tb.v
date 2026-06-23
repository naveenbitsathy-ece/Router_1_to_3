module FIFO_tb();
    reg clk,rst_n;
    reg soft_rst;
    reg wr_en,rd_en;
    reg lfd_state;
    reg data_in[8:0];
    wire data_out[8:0];
    wire full,empty;

reg [8:0]FIFO[15:0];  // Depth 16 bit and 9 bit width
reg [3:0]wr_ptr;
reg [3:0]rd_ptr;
reg [3:0]counter;    // count 0 to 16

FIFO DUT(
     clk,rst_n,
     soft_rst,
     wr_en,rd_en,
     lfd_state,
     data_in,
     data_out,
     full,empty
);
initial 
clk=0;
always 
#5
clk=~clk;

initial 
begin
   
    rst_n=0;
    #10;
    rst_n=1;
#5;
   soft_rst=1;
   #10;
   soft_rst=0;
end 

task stimula(
    input a,b,
    input [8:0]c);
    begin
        a=wr_en;
        b=rd_en;
        c=data_in; 
        #10;
    end 
endtask;

initial 
begin
    stimula(1,0,9'd4);
    stimula(1,0,9'd4);   //Write 
    stimula(1,0,9'd4);
    stimula(1,0,9'd4); 


    stimula(0,1,9'd4);
    stimula(0,1,9'd5);   //read
    stimula(0,1,9'd4);
    stimula(0,1,9'd5); 

    stimula(1,1,9'd4);
    stimula(1,1,9'd5);   // write and read 

    #200;
$finish ;
end 
initial
begin
    $dumpfile("FIFO.vcd");
    $dumpvars(0, FIFO_tb.v); 
end 

initial 
begin
    $monitor("Time=$0t rst_n=%b soft_rst=%b wr_en=%b rd_en=%b full=%b empty=%b data_in=%b data_out=%b",
    $time,rst_n,soft_rst,wr_en.rd_en,full,empty,data_in,data_out); 
end 
endmodule