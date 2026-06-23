`timescale 1ns/1ps
module FIFO(
    input clk,rst_n,
    input soft_rst,
    input wr_en,rd_en,
    input lfd_state,
    input [8:0]data_in,
    output reg [8:0]data_out,
    output reg full,empty
);

reg [8:0]mem[0:15];  // Depth 16 bit and 9 bit width
reg [3:0]wr_ptr;
reg [3:0]rd_ptr;
reg [3:0]counter;    // count 0 to 16
integer i;

always@(posedge clk or negedge rst_n)
begin

    if(rst_n)
    begin 
    data_out<=9'b0;
    counter1<=0;
     for(i=0;i<16;i=i+1)      // Whole FIFO is 0 and data_out is 0
     mem[i]<=0; 
    
    end

    if(soft_rst)
    begin 
    data_out<=9'b0;
     counter<=0;
    for(i=0;i<16;i=i+1)       // Whole FIFO is 0 and data_out is 0
    mem[i]<=0; 
   
    end

end

always@(posedge clk)
begin 
if(wr_en && !full)
     counter<=counter+1'b1;    // if write happens counter increments 

if(rd_en && !empty)
    counter<=counter-1'b1;     // if read happens counter decrements 

if((wr_en && !full) && (rd_en && !empty))
    counter<=counter;      // If read and write happens counter stays same 

else
    counter<=counter;      // Condition to prevent latch formation
end 

// condition for full and empty
always@(*)
begin

    assign full=(counter==15)?1'b1 : 1'b0;
    assign empty=(counter==0)?1'b1 : 1'b0;

    
// if (counter==4'd16)  
//     full=1'b1;               // writes data from 0 to 15 totally 16 so Full
// if (counter==4'd0)
//     empty=1'b1;              //If counter is zero then no write happens so empty
end 

//Data write and data read 
always@(posedge clk)
begin 

if(wr_en && !full)
begin 
 mem[wr_ptr]<={lfd_state,data_in[7:0]};
 wr_ptr<=wr_ptr+1'b1;
end 

 if(rd_en && !empty)
 begin 
 data_out <= mem[rd_ptr][7:0];
 rd_ptr<=rd_ptr+1'b1;
 end

 if((wr_en && !full) && (rd_en && !empty))
 begin
     mem[wr_ptr]<={lfd_state,data_in};
     data_out <= mem[rd_ptr][7:0];       
     rd_ptr<=rd_ptr;                // If write and read happens together then
     wr_ptr<=wr_ptr;                 // read pointer and write pointer stays at same 
 end

end 

//  if(data_in[8]==1'b1)
//      Header;
//  else 
//  Not Header;

 endmodule 