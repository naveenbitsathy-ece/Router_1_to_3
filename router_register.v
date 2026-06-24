module router_register(
input clk,rst_n.
input pkt_valid,
input [7:0]data_in,
input fifo_full,
input rst_int_reg,
input detect_add,
input ld_state,
input laf_state,
input lfd_state,
input full_state,

output parity_done,
output low_pkt_valid,
output err,
output [7:0]data_out
);

reg [7:0]header_reg;
reg [7:0]fifo_full_reg;
reg [7:0]internal_parity_reg;
reg [7:2]xor_reg;
reg [6:0]counter;
reg [7:0]packet_parity_reg;

always@(posedge clk)
begin
    if(!rst_in)
    begin
        data_out <= 0;
        err <= 0;
        parity_done <= 0;
        low_pkt_valid <= 0; 
        xor_reg <= 0;
        counter <= 0;
       
    end  
    else if((ld_state==1) & 
    ((fifo_full==0) & (pkt_valid==0)))
        parity_done <= 1;
    else if (rst_int_reg)
        low_pkt_valid <= 0;
    else if(detect_add)
        parity_done <= 0;
    else if(!ld_state && !pkt_valid)
        low_pkt_valid <= 1;
end 
 
// Header register

always@(posedge clk)
begin 
if(!rst_n)
     header_reg<=0;
else if(detect_add && pkt_valid)
begin 
     header_reg<=data_in;
     xor_reg<=[7:2]data_in;
end
else if(lfd_state)
     data_out <= header_reg;
end 
assign counter = xor_reg; 

//Fifo full register
always@(posedge clk)
begin
    if(!rst_n)
      fifo_full_reg <= 0; 
    else if(ld_state && !fifo_full)
      data_out <= data_in;
    else if(ld_state && fifo_full)
      fifo_full_reg <= data_in;
    else if(laf_state)
      data_out <= fifo_full_reg;
end 


//Internal_parity_reg
always@(posedge clk)
begin 
   if(!rst_n)
      internal_parity_reg <= 0;
   else if(header_reg)
      internal_parity_reg <= header_reg;
   else if(counter != 0)
   begin 
      internal_parity_reg <= internal_parity_reg ^^ data_in;
      counter = counter - 1'b1; 
   end 
end 

//Packet parity reg 
always@(posedge clk)
begin
    if(!rst_n)
       packet_parity_reg <= 0;
    else if(counter + 1)
       packet_parity_reg <= data_in;
    else if(internal_parity_reg ==  packet_parity_reg)
       parity_done <= 1;
     else if(internal_parity_reg !=  packet_parity_reg)
       parity_done <= 0;
end 
endmodule 