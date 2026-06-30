`timescale 1ns/1ps

module router_sync_tb;

reg clk;
reg rst_n;
reg detect_add;
reg [1:0] data_in;
reg write_en_reg;
reg read_en_0;
reg read_en_1;
reg read_en_2;
reg empty_0;
reg empty_1;
reg empty_2;
reg full_0;
reg full_1;
reg full_2;

wire valid_out_0;
wire valid_out_1;
wire valid_out_2;
wire [2:0] write_en;
wire fifo_full;
wire soft_rst_0;
wire soft_rst_1;
wire soft_rst_2;

//-----------------------------------------
// DUT
//-----------------------------------------

router_sync DUT(
    .clk(clk),
    .rst_n(rst_n),
    .detect_add(detect_add),
    .data_in(data_in),
    .write_en_reg(write_en_reg),
    .read_en_0(read_en_0),
    .read_en_1(read_en_1),
    .read_en_2(read_en_2),
    .empty_0(empty_0),
    .empty_1(empty_1),
    .empty_2(empty_2),
    .full_0(full_0),
    .full_1(full_1),
    .full_2(full_2),
    .valid_out_0(valid_out_0),
    .valid_out_1(valid_out_1),
    .valid_out_2(valid_out_2),
    .write_en(write_en),
    .fifo_full(fifo_full),
    .soft_rst_0(soft_rst_0),
    .soft_rst_1(soft_rst_1),
    .soft_rst_2(soft_rst_2)
);

//-----------------------------------------
// Clock
//-----------------------------------------

always #10 clk = ~clk;

//-----------------------------------------
// Reset Task
//-----------------------------------------

task reset_dut;
begin
    rst_n = 0;
    @(posedge clk);
    @(posedge clk);
    rst_n = 1;
end
endtask

//-----------------------------------------
// Initialize
//-----------------------------------------

task initialize;
begin
    detect_add = 0;
    data_in = 0;
    write_en_reg = 0;

    read_en_0 = 0;
    read_en_1 = 0;
    read_en_2 = 0;

    empty_0 = 1;
    empty_1 = 1;
    empty_2 = 1;

    full_0 = 0;
    full_1 = 0;
    full_2 = 0;
end
endtask

//-----------------------------------------
// Monitor
//-----------------------------------------

initial
begin
$monitor("T=%0t Addr=%b Temp_Write=%b fifo_full=%b valid0=%b valid1=%b valid2=%b SR0=%b SR1=%b SR2=%b",
$time,
data_in,
write_en,
fifo_full,
valid_out_0,
valid_out_1,
valid_out_2,
soft_rst_0,
soft_rst_1,
soft_rst_2);
end

//-----------------------------------------
// Test
//-----------------------------------------

initial
begin

clk = 0;

initialize();
reset_dut();


//-----------------------------------------
// Test FIFO0
//-----------------------------------------

@(posedge clk);
detect_add = 1;
data_in = 2'b00;
write_en_reg = 1;

@(posedge clk);
detect_add = 0;

full_0 = 1;

#40;

full_0 = 0;


//-----------------------------------------
// Test FIFO1
//-----------------------------------------

@(posedge clk);
detect_add = 1;
data_in = 2'b01;

@(posedge clk);
detect_add = 0;

full_1 = 1;

#40;

full_1 = 0;


//-----------------------------------------
// Test FIFO2
//-----------------------------------------

@(posedge clk);
detect_add = 1;
data_in = 2'b10;

@(posedge clk);
detect_add = 0;

full_2 = 1;

#40;

full_2 = 0;


//-----------------------------------------
// Test valid_out signals
//-----------------------------------------

empty_0 = 0;
empty_1 = 0;
empty_2 = 0;

#40;

empty_0 = 1;
empty_1 = 1;
empty_2 = 1;


//-----------------------------------------
// Soft Reset Test FIFO0
//-----------------------------------------

empty_0 = 0;

repeat(31)
@(posedge clk);

empty_0 = 1;


//-----------------------------------------
// Soft Reset Test FIFO1
//-----------------------------------------

empty_1 = 0;

repeat(31)
@(posedge clk);

empty_1 = 1;


//-----------------------------------------
// Soft Reset Test FIFO2
//-----------------------------------------

empty_2 = 0;

repeat(31)
@(posedge clk);

empty_2 = 1;


//-----------------------------------------
// Counter Reset by Read Enable
//-----------------------------------------

empty_0 = 0;

repeat(10)
@(posedge clk);

read_en_0 = 1;

@(posedge clk);

read_en_0 = 0;

repeat(10)
@(posedge clk);

#100;

$finish;

end

endmodule