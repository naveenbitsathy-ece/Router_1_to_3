module router_sync(
input clk,rst_n,
input detect_addr,
input [1:0]data_in,
input write_en_reg,
input read_en_0,
input read_en_1,
input read_en_2,
input empty_0,
input empty_1,
input empty_2,
input full_0,
input full_1,
input full_2,

output [2:0]write_en,
output soft_rst_0,
output soft_rst_1,
output soft_rst_2,
output valid_out_0,
output valid_out_1,
output valid_out_2,
output reg fifo_full
);
reg [1:0]temp_reg;
reg [4:0]count_0,count_1,count_2;

//Logic for temporary version of data in 
always@(posedge clk)
begin
    if(!rst_n) 
    temp_reg<=0;
    else if(detect_addr)
      temp_reg<=data_in;
end 

//write enable logic 
always@(*)
begin 
   if(!write_en_reg)
    write_en =0;
else 
case (temp_reg)
       2'b00 : write_en = 3'b001;
       2'b01 : write_en = 3'b010;
       2'b10 : write_en = 3'b100;
       default: write_en = 3'b000;
endcase 
end

//Empty logic
assign valid_out_0 = ~empty_0;
assign valid_out_1 = ~empty_1;
assign valid_out_2 = ~empty_2;

//fifo full
always@(*)
case (temp_reg)
       2'b00 : fifo_full = full_0;
       2'b00 : fifo_full = full_1;
       2'b00 : fifo_full = full_2;
       default: fifo_full = full_0;
endcase 

//Logic for soft reset 0
always@(posedge clk)
begin
    if(!rst_n) 
    begin 
    count_0<=1;
    soft_rst_0<=0;
    end 
    else if(!valid_out_0)
    begin 
    count_0<=1;
    soft_rst_0<=0;
    end 
    else if(read_en_0)
    begin 
    count_0<=1;
    soft_rst_0<=0;
    end 
    else if(count_0 == 30)
    begin 
     count_0<=1
     soft_rst_0<=1;
    end 
   else 
   begin 
   count_0<=count_0 + 1'b1;
   soft_rst_0 <= 0;
   end 
end 

//Logic for soft reset 1
always@(posedge clk)
begin
    if(!rst_n) 
    begin 
    count_1<=1;
    soft_rst_1<=0;
    end 
    else if(!valid_out_1)
    begin 
    count_1<=1;
    soft_rst_1<=0;
    end 
    else if(read_en_1)
    begin 
    count_1<=1;
    soft_rst_1<=0;
    end 
    else if(count_1 == 30)
    begin 
     count_1<=1
     soft_rst_1<=1;
    end 
   else 
   begin 
   count_1<=count_1 + 1'b1;
   soft_rst_1 <= 0;
   end 
end 

//Logic for soft reset 2

always@(posedge clk)
begin
    if(!rst_n) 
    begin 
    count_2<=1;
    soft_rst_2<=0;
    end 
    else if(!valid_out_2)
    begin 
    count_2<=1;
    soft_rst_2<=0;
    end 
    else if(read_en_2)
    begin 
    count_2<=1;
    soft_rst_2<=0;
    end 
    else if(count_2 == 30)
    begin 
     count_2<=1
     soft_rst_2<=1;
    end 
   else 
   begin 
   count_2<=count_2 + 1'b1;
   soft_rst_2 <= 0;
   end 
end 

endmodule 