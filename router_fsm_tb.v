`timescale 1ns/1ps

module tb_router_fsm;

reg clk;
reg rst_n;

reg pkt_valid;
reg parity_done;
reg [1:0] data_in;

reg soft_rst_0;
reg soft_rst_1;
reg soft_rst_2;

reg fifo_full;
reg fifo_empty_0;
reg fifo_empty_1;
reg fifo_empty_2;

wire low_pkt_valid;
wire detect_add;
wire busy;
wire ld_state;
wire laf_state;
wire full_state;
wire write_en_reg;
wire rst_int_reg;
wire lfd_state;

// DUT

router_fsm DUT(
.clk(clk),
.rst_n(rst_n),
.pkt_valid(pkt_valid),
.parity_done(parity_done),
.data_in(data_in),
.soft_rst_0(soft_rst_0),
.soft_rst_1(soft_rst_1),
.soft_rst_2(soft_rst_2),
.fifo_full(fifo_full),
.fifo_empty_0(fifo_empty_0),
.fifo_empty_1(fifo_empty_1),
.fifo_empty_2(fifo_empty_2),

.low_pkt_valid(low_pkt_valid),
.detect_add(detect_add),
.busy(busy),
.ld_state(ld_state),
.laf_state(laf_state),
.full_state(full_state),
.write_en_reg(write_en_reg),
.rst_int_reg(rst_int_reg),
.lfd_state(lfd_state)
);

/////////////////////////////////////////////////////////
// Clock
/////////////////////////////////////////////////////////

initial
begin
 clk = 0;
 forever #5 clk = ~clk;
end

/////////////////////////////////////////////////////////
// Monitor
/////////////////////////////////////////////////////////

initial
begin
 $monitor(
 "T=%0t State=%0d Next=%0d pkt_valid=%b fifo_full=%b detect=%b lfd=%b ld=%b laf=%b full=%b busy=%b",
 $time,
 DUT.state,
 DUT.next_state,
 pkt_valid,
 fifo_full,
 detect_add,
 lfd_state,
 ld_state,
 laf_state,
 full_state,
 busy
 );
end

/////////////////////////////////////////////////////////
// Stimulus
/////////////////////////////////////////////////////////

initial
begin

//------------------------------------------------------
// Initial Values
//------------------------------------------------------

rst_n = 0;

pkt_valid = 0;
parity_done = 0;

data_in = 2'b00;

fifo_full = 0;

fifo_empty_0 = 1;
fifo_empty_1 = 1;
fifo_empty_2 = 1;

soft_rst_0 = 0;
soft_rst_1 = 0;
soft_rst_2 = 0;

#20;
rst_n = 1;

/////////////////////////////////////////////////////////
// TEST-1
// Normal Packet Flow
//
// DECODE_ADDRESS
// LOAD_FIRST_DATA
// LOAD_DATA
// LOAD_PARITY
// CHECK_PARITY_ERROR
// DECODE_ADDRESS
/////////////////////////////////////////////////////////

$display("\nTEST1 NORMAL FLOW");

data_in = 2'b00;
pkt_valid = 1;

#20;

pkt_valid = 0;

#30;

/////////////////////////////////////////////////////////
// TEST-2
// WAIT_TILL_EMPTY
/////////////////////////////////////////////////////////

$display("\nTEST2 WAIT_TILL_EMPTY");

data_in = 2'b01;

fifo_empty_1 = 0;

pkt_valid = 1;

#20;

fifo_empty_1 = 1;

#20;

pkt_valid = 0;

#20;

/////////////////////////////////////////////////////////
// TEST-3
// FIFO_FULL_STATE
/////////////////////////////////////////////////////////

$display("\nTEST3 FIFO FULL");

data_in = 2'b10;

fifo_empty_2 = 1;

pkt_valid = 1;

#20;

fifo_full = 1;

#30;

fifo_full = 0;

#20;

/////////////////////////////////////////////////////////
// TEST-4
// LOAD_AFTER_FULL -> LOAD_DATA
/////////////////////////////////////////////////////////

$display("\nTEST4 LOAD_AFTER_FULL TO LOAD_DATA");

parity_done = 0;

force DUT.low_pkt_valid = 0;

#20;

release DUT.low_pkt_valid;

/////////////////////////////////////////////////////////
// TEST-5
// LOAD_AFTER_FULL -> LOAD_PARITY
/////////////////////////////////////////////////////////

$display("\nTEST5 LOAD_AFTER_FULL TO LOAD_PARITY");

fifo_full = 1;

#20;

fifo_full = 0;

#20;

force DUT.low_pkt_valid = 1;

parity_done = 0;

#20;

release DUT.low_pkt_valid;

/////////////////////////////////////////////////////////
// TEST-6
// LOAD_AFTER_FULL -> DECODE_ADDRESS
/////////////////////////////////////////////////////////

$display("\nTEST6 PARITY DONE");

fifo_full = 1;

#20;

fifo_full = 0;

#20;

parity_done = 1;

#20;

parity_done = 0;

/////////////////////////////////////////////////////////
// TEST-7
// Soft Reset
/////////////////////////////////////////////////////////

$display("\nTEST7 SOFT RESET");

soft_rst_0 = 1;

#10;

soft_rst_0 = 0;

#20;

/////////////////////////////////////////////////////////

#100;

$finish;

end

/////////////////////////////////////////////////////////
// Dump
/////////////////////////////////////////////////////////

initial
begin
 $dumpfile("naveen.vcd");
 $dumpvars(0,tb_router_fsm);
end

endmodule