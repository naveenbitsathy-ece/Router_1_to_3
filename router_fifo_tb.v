`timescale 1ns/1ps

module router_fifo_tb();

reg clk, rst_n, wr_enb, soft_rst, rd_enb, lfd_state;
reg [7:0] data_in;

wire empty, full;
wire [7:0] data_out;

integer k;

router_fifo DUT (
    clk,
    rst_n,
    soft_rst,
    rd_enb,
    wr_enb,
    data_in,
    lfd_state,
    data_out,
    empty,
    full
);



initial
clk=0;
always
 #5 clk=~clk;


task reset(); 
begin
    @(negedge clk);
    rst_n=0;
    @(negedge clk);
    rst_n=1;  
end 
endtask 

task soft_reset();
begin
    @(negedge clk);
    soft_rst=1;
    @(negedge clk);
    soft_rst=0; 
end 
endtask 

task write();
 reg [7:0]header,payload,parity;
 reg [1:0]addr;
 reg [5:0]payload_length;
 begin
    @(negedge clk)
    addr=2'b1;
    payload_length=6'd13;
    
    wr_enb=1;
    rd_enb=0;
    lfd_state=1;

    header = {payload_length,addr};
    data_in = header;
  
    for(k=0;k<payload_length;k=k+1)
    begin 
        @(negedge clk)
        lfd_state = 1'b0;
        payload = {$random}%256;
        data_in = payload;
    end 
  
        @(negedge clk)
        parity = {$random}%256;
        data_in = parity;
 end 
endtask 

task read(input r,input w);
 
begin 
       @(negedge clk)
       rd_enb=r;
       wr_enb=w;
end 
endtask 

initial 
begin
    reset ();
    soft_reset();
    write ();
    repeat(16)
    read(1,0);
    #4000;
    $finish ;
end 

initial
 begin
    $monitor("Time=%0t rst_n=%b soft_rst=%b  rd_en=%b wr_en=%b data_in=%b",
    $time,rst_n,soft_rst,rd_enb,wr_enb,data_in);
end
endmodule