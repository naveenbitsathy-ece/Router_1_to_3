`timescale 1ns/1ps

	module router_fsm(
  input clk,rst_n,
  input pkt_valid,
  input parity_done,
  input [1:0]data_in,
  input soft_rst_0,
  input soft_rst_1,
  input soft_rst_2,
  input fifo_full,
  input fifo_empty_0,
  input fifo_empty_1,
  input fifo_empty_2,
  input low_pkt_valid,
   
  output detect_add,
  output busy,
  output ld_state,
  output laf_state,
  output full_state,
  output write_en_reg,
  output rst_int_reg,
  output lfd_state
);
parameter  DECODE_ADDRESS=3'b000 ; 
parameter  LOAD_FIRST_DATA = 3'b001 ;
parameter  LOAD_DATA = 3'b010 ;
parameter  WAIT_TILL_EMPTY = 3'b011 ;
parameter  FIFO_FULL_STATE = 3'b100;
parameter  LOAD_PARITY = 3'b101;
parameter  CHECK_PARITY_ERROR = 3'b110;
parameter  LOAD_AFTER_FULL = 3'b111;


reg [2:0] state,next_state;
reg [1:0] addr;          //Temp reg to store address 


//Present state sequential logic  -- Middle block 

always@(posedge clk)
begin 
  addr=data_in; 
  if(!rst_n)
    state <= DECODE_ADDRESS;
  else if(soft_rst_0 || soft_rst_1 || soft_rst_2)
    state <= DECODE_ADDRESS;
  else
    state<=next_state;
end

// Next state combinational logic 
always@(*)
begin

 next_state = DECODE_ADDRESS;
 case(state)
 DECODE_ADDRESS:begin            //DECODE_ADDRESS

  

  if((pkt_valid && (data_in[1:0]==2'b00) && fifo_empty_0) ||
   (pkt_valid && (data_in[1:0]==2'b01) && fifo_empty_1) ||
   (pkt_valid && (data_in[1:0]==2'b10) && fifo_empty_2))
	
       next_state=LOAD_FIRST_DATA;

  else if((pkt_valid & (data_in[1:0] == 2'b00) & !fifo_empty_0)||
  (pkt_valid & (data_in[1:0] == 2'b01) & !fifo_empty_1)||
  (pkt_valid & (data_in[1:0] == 2'b10) & !fifo_empty_2) )

       next_state = WAIT_TILL_EMPTY;

   else 
      next_state = DECODE_ADDRESS;     

end 
 LOAD_FIRST_DATA:begin             //LOAD_FIRST_DATA
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
  if((fifo_empty_0 && (addr == 0)) || (fifo_empty_1 && (addr == 1)) ||
  (fifo_empty_2 && (addr == 2)))

       next_state = LOAD_FIRST_DATA;

  else 
 next_state = WAIT_TILL_EMPTY;
 end 

 FIFO_FULL_STATE:begin                //FIFO_FULL_STATE
  if(fifo_full)
  next_state = FIFO_FULL_STATE;
  else  // !fifo_full
  next_state = LOAD_AFTER_FULL;
 end 

 LOAD_PARITY: begin
 next_state = CHECK_PARITY_ERROR ;     //LOAD_PARITY
 
end 
 CHECK_PARITY_ERROR:begin                // CHECK_PARITY_ERROR
  if(!fifo_full)
  next_state = DECODE_ADDRESS;
  else 
  next_state = FIFO_FULL_STATE;

 end 

 LOAD_AFTER_FULL:begin               //LOAD_AFTER_FULL

   if(parity_done)
      next_state = DECODE_ADDRESS;
  else if(!parity_done && !low_pkt_valid)
      next_state = LOAD_DATA;
  else if(!parity_done && low_pkt_valid)
      next_state = LOAD_PARITY;
 end 
 endcase 
end 

// Output logic -- combinational 
assign detect_add = (state == DECODE_ADDRESS);

assign lfd_state = (state == LOAD_FIRST_DATA);

assign  busy = (state == LOAD_FIRST_DATA) || (state == LOAD_PARITY)||
(state == LOAD_AFTER_FULL)||(state == FIFO_FULL_STATE)||(state == LOAD_AFTER_FULL)
|| (state == WAIT_TILL_EMPTY)||(state == CHECK_PARITY_ERROR);

assign ld_state = (state == LOAD_DATA);

assign write_en_reg = (state == LOAD_DATA) || (state == LOAD_PARITY)||
(state == LOAD_AFTER_FULL);

assign full_state = ( state == FIFO_FULL_STATE);

assign laf_state = (state == LOAD_AFTER_FULL);

assign low_pkt_valid = (state == LOAD_AFTER_FULL);

assign rst_int_reg = (state == CHECK_PARITY_ERROR);

endmodule 