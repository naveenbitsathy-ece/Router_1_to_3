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

integer i;
router_register uut(
 clk,rst_n,pkt_valid,data_in,fifo_full,rst_int_reg,
 detect_add, ld_state,laf_state,lfd_state,full_state,
 parity_done,low_pkt_valid,err,data_out
);

initial 
clk=0;
always 
#5 clk =~ clk;

task reset_uut();
begin 
    @(negedge clk)
    rst_n = 1'b0;
    @(negedge clk)
    rst_n = 1'b1;
end 
endtask

task initialize();
begin 
  pkt_valid = 0;
  data_in = 0;
  fifo_full = 0;
  rst_int_reg = 0;
  detect_add = 0;
  ld_state = 0;
  laf_state = 0;
  lfd_state = 0;
  full_state = 0;
end 
endtask 

task packet_generation_good();
reg [7:0]payload_data,parity,header;
reg [5:0]payload_length;
reg [1:0]addr;
begin
    @(negedge clk)
    payload_length = 6'd3;
    addr = 2'b10;
    pkt_valid = 1'b1;
    detect_add = 1'b1;
    header = {payload_length,addr};
    parity = 8'd0 ^ header;
    data_in = header; 

     @(negedge clk)
     detect_add = 1'b0;
     lfd_state = 1'b1;
     full_state = 1'b0;
     fifo_full = 1'b0;
     laf_state = 1'b0;
     for(i=0;i<payload_length;i=i+1)
     begin
        lfd_state = 0;
        ld_state = 1;
        payload_data = {$random}%256;
        data_in = payload_data;
        parity = parity ^ data_in; 
     end 

     @(negedge clk)
     pkt_valid = 0;
     data_in = parity;

     @(negedge clk)
     ld_state = 0;
end 
endtask

task packet_generation_bad();
reg [7:0]payload_data,parity,header;
reg [5:0]payload_length;
reg [1:0]addr;
begin
    @(negedge clk)
    payload_length = 6'd4;
    addr = 2'b10;
    pkt_valid = 1'b1;
    detect_add = 1'b1;
    header = {payload_length,addr};
    parity = 8'd0 ^ header;
    data_in = header; 

     @(negedge clk)
     detect_add = 1'b0;
     lfd_state = 1'b1;
     full_state = 1'b0;
     fifo_full = 1'b0;
     laf_state = 1'b0;
     for(i=0;i<payload_length;i=i+1)
     begin
        lfd_state = 0;
        ld_state = 1;
        payload_data = {$random}%256;
        data_in = payload_data;
        parity = parity ^ data_in; 
     end 

     @(negedge clk)
     pkt_valid = 0;
     data_in = parity;

     @(negedge clk)
     ld_state = 0;
end 
endtask

initial 
begin
    initialize();
    reset_uut();
    packet_generation_good();
    packet_generation_bad();

    #3000;
    $finish; 
end 
endmodule 