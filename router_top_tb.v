`timescale 1ns/1ps 

module router_top_tb();
//Inputs 
reg clock,resetn;
reg read_en_0;
reg read_en_1;
reg read_en_2;
reg [7:0]data_in;
reg pkt_valid;

//outputs 
wire [7:0]data_out_0;
wire [7:0]data_out_1;
wire [7:0]data_out_2;
wire valid_out_0;
wire valid_out_1;
wire valid_out_2;
wire error,busy;

integer i;

//Instantiate unit under test (UUT)
router_top uut(
 .clock(clock),
 .resetn(resetn),
 .read_en_0(read_en_0),
 .read_en_1(read_en_1),
 .read_en_2(read_en_2),
 .data_in(data_in),
 .pkt_valid(pkt_valid),
 .data_out_0(data_out_0),
 .data_out_1(data_out_1),
 .data_out_2(data_out_2),
 .valid_out_0(valid_out_0),
 .valid_out_1(valid_out_1),
 .valid_out_2(valid_out_2),
 .error(error),
 .busy(busy)    
);

initial 
clock = 0;
always 
#10 clock =~ clock;

task reset_uut();
    begin 
   @(negedge clock)
   resetn = 1'b0;
   @(negedge clock)
   resetn = 1'b1;
   end 
endtask 


task initialize();
begin 
    read_en_0 = 1'b0;
    read_en_1 = 1'b0;
    read_en_2 = 1'b0;
end 
endtask 

task packet_generation();
reg [7:0]payload_data,parity,header;
reg [5:0]payload_length;
reg [7:0]addr;

begin
    @(negedge clock)
    wait(~busy)
    @(negedge clock)
    payload_length = 6'd14;
    addr = 2'b10;
    pkt_valid = 1'b1;
    header = {payload_length,addr};
    parity = 8'd0 ^ header;
    data_in = header;

    @(negedge clock);
    wait(~busy)
    for(i=0;i<payload_length;i=i+1)
    begin
        @(negedge clock)
        wait(~busy)
        payload_data = {$random}%256; 
        data_in = payload_data;
        parity = parity ^ data_in;
    end  

    @(negedge clock)
    wait(~busy)
    pkt_valid = 1'b0;
    data_in = parity;
    end 
endtask 

initial 
begin 
    initialize();
    reset_uut();
    repeat(3)@(negedge clock);
    packet_generation();
    @(negedge clock);
    read_en_2 = 1'b1;
    wait(~valid_out_2)
    @(negedge clock);
    read_en_2 = 1'b0;
    #1000;
    $finish;
end 

initial 
begin
    // $monitor("Time=%0t |resetn=%b |read_en_0=%b |read_en_1=%b |read_en_2=%b |busy=%b |pkt_valid=%b |data_in=%b",
    // $time,resetn,read_en_0,read_en_1,read_en_2,busy,pkt_valid,data_in); 

    $monitor(
"Time=%0t State=%0d Next=%0d busy=%b pkt_valid=%b data=%h",
$time,
uut.FSM.state,
uut.FSM.next_state,
busy,
pkt_valid,
data_in
);
end 
endmodule 