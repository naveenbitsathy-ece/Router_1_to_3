module router_register(
input clk,rst_n,
input pkt_valid,
input [7:0]data_in,
input fifo_full,
input rst_int_reg,
input detect_add,
input ld_state,
input laf_state,
input lfd_state,
input full_state,

output reg parity_done,
output reg low_pkt_valid,
output reg err,
output reg [7:0]data_out
);

reg [7:0]header_reg;
reg [7:0]fifo_full_reg;
reg [7:0]internal_parity_reg;
reg [7:0]packet_parity_reg;

// Header register
always@(posedge clk)
begin 
if(!rst_n)
     header_reg<=0;
else if(detect_add && pkt_valid && data_in[1:0]!=3)
     header_reg <= data_in;
end 

//fifo full state byte register logic 
always@(posedge clk)
begin 
if(!rst_n)
     fifo_full_reg<=0;
else if(detect_add && pkt_valid) 
     fifo_full_reg <= data_in;
end 

//packet_parity_reg
always@(posedge clk)
begin
if(!rst_n)
   packet_parity_reg <= 0;
else if(detect_add)
   packet_parity_reg <= 0;
else if(ld_state && !pkt_valid)
   packet_parity_reg <= data_in;
end 

//Internal parity reg
always@(posedge clk)
begin 
if(!rst_n)
  internal_parity_reg <= 0;
else if(detect_add)
  internal_parity_reg <= 0;
else if(lfd_state)
  internal_parity_reg <= internal_parity_reg ^ header_reg;
else if(pkt_valid && ld_state && !full_state)
   internal_parity_reg <= internal_parity_reg ^ data_in;
end 

//data_out logic
always@(posedge clk)
begin 
if(!rst_n)
  data_out <= 0;
else if(detect_add && pkt_valid && data_in[1:0]!=2'd3)
  data_out <= data_out;
else if(lfd_state)
  data_out <= header_reg;
else if(ld_state && !fifo_full)
  data_out <= data_in;
else if(ld_state && fifo_full)
  data_out <= data_out; 
else if(laf_state)
  data_out <= fifo_full_reg;
end
//Logic for parity_done 
always@(posedge clk)
begin
   if(!rst_n)
     parity_done <= 0; 
   else if(detect_add)
     parity_done <= 0;
   else if((ld_state && !fifo_full && !pkt_valid) || (laf_state && low_pkt_valid && !parity_done))
     parity_done <= 1; 
end 

//Logic for low_pkt_valid
always@(posedge clk)
begin
if(!rst_n)
   low_pkt_valid <= 0;
else if(rst_int_reg)
   low_pkt_valid <= 0; 
else if(ld_state && !pkt_valid)
   low_pkt_valid <= 1;
end

//Logic for err 
always@(posedge clk)
begin
if(!rst_n)
   err <= 0;
else if(parity_done && (packet_parity_reg != internal_parity_reg))
 err <= 1;
end 
endmodule 