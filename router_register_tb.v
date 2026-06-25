module router_register_tb();
reg clk,rst_n;
reg pkt_valid;
reg [7:0]data_in;
reg fifo_full;
reg rst_int_reg;
reg detect_add;
reg ld_state;
reg laf_state;
reg lfd_state;
reg full_state;

wire parity_done;
wire low_pkt_valid;
wire err;
wire [7:0]data_out;

reg [7:0]header_reg;
reg [7:0]fifo_full_reg;
reg [7:0]internal_parity_reg;
reg [7:2]xor_reg;
reg [6:0]counter;
reg [7:0]packet_parity_reg;

router_register DUT(
clk,rst_n,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,ld_state,
laf_state,lfd_state,full_state,parity_done,low_pkt_valid,err,data_out
);

initial 
clk=0;
always #5
clk=~clk;

initial 
begin 
     @(negedge clk)
     rst_n=0; 
     #5;
     rst_n=1;
end 

initial 
begin
    detect_add=1;
    pkt_valid=1;
    data_in=8'b00011001; 
    data_in=8'b11011001; 
    data_in=8'b01011001; 
    data_in=8'b10111001; 
    data_in=8'b11011001; 
    data_in=8'b11011001; 
    data_in=8'b11011001; 
    data_in=8'b11011001; 
    
    lfd_state=1;
end 

initial 
begin
    ld_state=1;
    fifo_full=1;
    #5;
  
    laf_state=1; 
end 

initial 
begin
    $dumpfile("naveen.vcd");
    $dumpvars(0,router_register_tb); 
end 
initial
begin
   $monitor("Time =%0t rst_n=%b detect_addr=%b pkt_valid=%b lfd_state=%b counter=%b ld_state=%b fifo_full=%b laf_state=%b fifo_full_reg=%b data_in=%b",
             $time,rsr_n,detect_add,pkt_valid,lfd_state,counter,ld_state,fifo_full,laf_state,fifo_full_reg,data_in);

end 
endmodule 