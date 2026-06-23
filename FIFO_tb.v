`timescale 1ns/1ps

module fifo_tb;

reg clk;
reg rst_n;
reg soft_rst;
reg rd_en;
reg wr_en;
reg lfd_state;
reg [7:0] data_in;

wire [7:0] data_out;
wire full;
wire empty;

fifo DUT (
    .clk(clk),
    .rst_n(rst_n),
    .soft_rst(soft_rst),
    .rd_en(rd_en),
    .wr_en(wr_en),
    .data_in(data_in),
    .lfd_state(lfd_state),
    .data_out(data_out),
    .empty(empty),
    .full(full)
);


//---------------------------------------------------
// Clock Generation
//---------------------------------------------------

initial
begin
    clk = 0;
    forever #5 clk = ~clk;
end


//---------------------------------------------------
// Random Packet Write Task
//---------------------------------------------------

task write_packet;

integer payload_len;
integer i;

begin

    payload_len = $urandom_range(1,10);

    // Header
    @(posedge clk);

    wr_en     = 1;
    lfd_state = 1;

    data_in = {payload_len[5:0],2'b01};

    $display("\nHEADER WRITTEN = %h Payload Length=%0d",
              data_in,payload_len);

    //------------------------------------------------
    // Payload
    //------------------------------------------------

    for(i=0;i<payload_len;i=i+1)
    begin
        @(posedge clk);

        lfd_state = 0;
        data_in   = $random;

        $display("Payload[%0d] = %h",
                  i,data_in);
    end

    //------------------------------------------------
    // Parity
    //------------------------------------------------

    @(posedge clk);

    data_in = $random;

    $display("Parity = %h",data_in);

    @(posedge clk);

    wr_en = 0;

end
endtask


//---------------------------------------------------
// Read Packet Task
//---------------------------------------------------

task read_fifo;

integer i;

begin

    rd_en = 1;

    for(i=0;i<20;i=i+1)
    begin
        @(posedge clk);

        $display("Time=%0t DATA_OUT=%h EMPTY=%b FULL=%b COUNTER=%0d",
        $time,
        data_out,
        empty,
        full,
        DUT.counter);

        if(empty)
            disable read_fifo;
    end

    rd_en = 0;

end
endtask


//---------------------------------------------------
// Monitor
//---------------------------------------------------

initial
begin
    $monitor(
    "T=%0t WR_PTR=%0d RD_PTR=%0d FULL=%b EMPTY=%b CNT=%0d DATA_OUT=%h",
    $time,
    DUT.wr_ptr,
    DUT.rd_ptr,
    full,
    empty,
    DUT.counter,
    data_out);
end


//---------------------------------------------------
// Stimulus
//---------------------------------------------------

initial
begin

    rst_n     = 0;
    soft_rst  = 0;
    rd_en     = 0;
    wr_en     = 0;
    lfd_state = 0;
    data_in   = 0;

    //------------------------------------------------
    // Reset
    //------------------------------------------------

    #20;
    rst_n = 1;

    //------------------------------------------------
    // Write 3 random packets
    //------------------------------------------------

    repeat(3)
        write_packet();

    //------------------------------------------------
    // Read everything
    //------------------------------------------------

    #20;
    read_fifo();

    //------------------------------------------------
    // Fill FIFO completely
    //------------------------------------------------

    $display("\n========== FILL FIFO ==========");

    wr_en = 1;
    lfd_state = 0;

    repeat(20)
    begin
        @(posedge clk);
        data_in = $random;
    end

    wr_en = 0;

    #50;

    //------------------------------------------------
    // Soft Reset
    //------------------------------------------------

    $display("\n========== SOFT RESET ==========");

    soft_rst = 1;
    @(posedge clk);
    soft_rst = 0;

    #50;

    //------------------------------------------------
    // Simultaneous Read Write
    //------------------------------------------------

    $display("\n========== READ + WRITE ==========");

    fork

        begin
            repeat(10)
            begin
                @(posedge clk);
                wr_en = 1;
                data_in = $random;
            end
            wr_en = 0;
        end

        begin
            repeat(10)
            begin
                @(posedge clk);
                rd_en = 1;
            end
            rd_en = 0;
        end

    join

    #100;

    $finish;

end


//---------------------------------------------------
// Dump File
//---------------------------------------------------

initial
begin
    $dumpfile("fifo.vcd");
    $dumpvars(0,fifo_tb.v);
end

endmodule