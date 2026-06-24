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
end 
endmodule 