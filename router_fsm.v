`timescale 1ns/1ps
module router_fsm(
  input clk,rst_n,
  input pkt_valid,
  input parity_done,
  input [1:0]data_in;
  input soft_rst_0,
  input soft_rst_1,
  input soft_rst_2,
  input fifo_full,
  input low_pkt_valid,
  input fifo_empty_0,
  input fifo_empty_1,
  input fifo_empty_2,

  output detect_add,
  output busy,
  output ld_state,
  output laf_state,
  output full_state,
  output write_en_reg,
  output rst_int_reg,
  output lfd_state
);
parameter 3'b000 = DECODE_ADDRESS ;
parameter 3'b001 = LOAD_FIRST_DATA;
parameter 3'b010 = LOAD_DATA;
parameter 3'b011 = WAIT_TILL_EMPTY;
parameter 3'b100 = FIFO_FULL_STATE;
parameter 3'b101 = LOAD_PARITY;
parameter 3'b110 = CHECK_PARITY_ERROR;
parameter 3'b111 = LOAD_AFTER_FULL;


reg [2:0] state,next_state;
reg [1:0] addr;
//Present state sequential logic  -- Middle block 

always@(posedge clk)
begin 
  if(!rst_n)
  begin
    
    state<=DECODE_ADDRESS;
  end 
  else
    state<=next_state;
end

// Next state combinational logic 
always@(*)
begin
 next_state = DECODE_ADDRESS;
 case(state)
 DECODE_ADDRESS:begin            //DECODE_ADDRESS

  addr=data_in; 

  if((pkt_valid & (data_in[1:0] = 0) & fifo_empty_0)|
  (pkt_valid & (data_in[1:0] = 0) & fifo_empty_1)|
  (pkt_valid & (data_in[1:0] = 0) & fifo_empty_1) )
   
       next_state=LOAD_FIRST_DATA;

  else if((pkt_valid & (data_in[1:0] = 0) & !fifo_empty_0)|
  (pkt_valid & (data_in[1:0] = 0) & !fifo_empty_1)|
  (pkt_valid & (data_in[1:0] = 0) & !fifo_empty_1) )

       next_state = WAIT_TILL_EMPTY;

   else 
      next_state = DECODE_ADDRESS;     
 end 

 LOAD_FIRST_DATA:begin 
  next_state = LOAD_DATA;
 end 

 LOAD_DATA:begin                  // LOAD DATA
  if(fifo_full)
  next_state = FIFO_FULL_STATE; 

  else if(!fifo_full && !pkt_valid)
   next_state = LOAD_PARITY;
   else 
   next_state = LOAD_DATA;
 end 

 WAIT_TILL_EMPTY:begin            // WAIT_TILL_EMPTY
  if((fifo_empty_0 && (addr == 0)) || (fifo_empty_0 && (addr == 1))
  (fifo_empty_0 && (addr == 2)))

       next_state = LOAD_FIRST_DATA;

  else 
 next_state = WAIT_TILL_EMPTY;
 end 

 FIFO_FULL_STATE:begin               //FIFO_FULL_STATE
  if(fifo_full)
  next_state = FIFO_FULL_STATE;
  else  // !fifo_full
  next_state = LOAD_AFTER_FULL;
 end 

 LOAD_PARITY: next_state = CHECK_PARITY_ERROR ;     //LOAD_PARITY
 

 CHECK_PARITY_ERROR:begin             // CHECK_PARITY_ERROR
  if(!fifo_full)
  next_state = DECODE_ADDRESS;
  else 
  next_state = FIFO_FULL_STATE;

 end 

 LOAD_AFTER_FULL:begin            //LOAD_AFTER_FULL

   if(parity_done)
      next_state = DECODE_ADDRESS;
  else if(!parity_done && !low_pkt_valid)
      next_state = LOAD_DATA;
  else(!parity_done && low_pkt_valid)
      next_state = LOAD_PARITY;
  
 end 

 endcase 
end 

// Output 

endmodule 