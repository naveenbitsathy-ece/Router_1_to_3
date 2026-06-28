module router_fsm_tb();
  reg clk,rst_n;
  reg pkt_valid;
  reg parity_done;
  reg [1:0]data_in;
  reg soft_rst_0;
  reg soft_rst_1;
  reg soft_rst_2;
  reg fifo_full;
  reg fifo_empty_0;
  reg fifo_empty_1;
  reg fifo_empty_2;
  reg low_pkt_valid;

  wire detect_add;
  wire busy;
  wire ld_state;
  wire laf_state;
  wire full_state;
  wire write_en_reg;
  wire rst_int_reg;
  wire lfd_state;

  reg [2:0] state,next_state;
  reg [1:0] addr;

router_fsm uut(clk,rst_n,pkt_valid,parity_done,data_in,soft_rst_0,soft_rst_1,soft_rst_2,fifo_full,
   fifo_empty_0,fifo_empty_1,fifo_empty_2,low_pkt_valid,detect_add,busy,ld_state,laf_state,full_state,
   write_en_reg,rst_int_reg,lfd_state
);

always @(uut.state) 
begin
    case(uut.state)
    3'b000 : state ="DECODE_ADDRESS";
    3'b001 : state ="LOAD_FIRST_DATA";
    3'b010 : state ="LOAD_DATA";
    3'b011 : state ="WAIT_TILL_EMPTY";
    3'b100 : state ="FIFO_FULL_STATE";
    3'b101 : state ="LOAD_PARITY";
    3'b110 : state ="CHECK_PARITY_ERROR";
    3'b111 : state ="LOAD_AFTER_FULL";
    default :state ="DECODE_ADDRESS";
    endcase  
end

always @(uut.next_state) 
  begin
    case(uut.next_state)
    3'b000 : next_state ="DECODE_ADDRESS";
    3'b001 : next_state ="LOAD_FIRST_DATA";
    3'b010 : next_state ="LOAD_DATA";
    3'b011 : next_state ="WAIT_TILL_EMPTY";
    3'b100 : next_state ="FIFO_FULL_STATE";
    3'b101 : next_state ="LOAD_PARITY";
    3'b110 : next_state ="CHECK_PARITY_ERROR";
    3'b111 : next_state ="LOAD_AFTER_FULL";
    default :next_state ="DECODE_ADDRESS";
    endcase  
  end

initial 
clk=0;
always
#5 clk =~ clk;

  task initialize();
  begin
    data_in = 2'b00; 
  end 
  endtask 

  task reset_uut();
  begin
    @(negedge clk)
    rst_n = 1'b0;
    @(negedge clk)
    rst_n = 1'b1; 
  end 
  endtask 

  task t1();             // LOAD_FIRST_DATA -----> LOAD_PARITY ----> LOAD_AFTER_FULL
  begin 
    @(negedge clk)
    pkt_valid = 1'b1;
    data_in = 2'b01;
    fifo_empty_1 = 1'b1;

    @(negedge clk)
    fifo_full = 1'b0;
    pkt_valid = 1'b0;

    @(negedge clk)
    fifo_full = 1'b0;
  end 
  endtask 

  task t2();    // LOAD_FIRST_DATA --->  FIFO_FULL_STATE ---> LOAD_AFTER_FULL ---> LOAD_DATA ---> LOAD_PARITY ---> LOAD_AFTER_FULL
  begin
    @(negedge clk)
    pkt_valid = 1'b1;
    data_in = 2'b01;
    fifo_empty_1 = 1'b1;

    @(negedge clk)
    fifo_full = 1'b1;

    @(negedge clk)
    fifo_full = 1'b0;

    @(negedge clk)
    parity_done = 1'b0;
    low_pkt_valid = 1'b0;

    @(negedge clk)
    fifo_full = 1'b0;
    pkt_valid = 1'b0;

    @(negedge clk)
    fifo_full = 1'b0;
  end 
  endtask 

  task t3();  //DECODE_ADDRESS ---> WAIT_TILL_EMPTY ---> LOAD_FIRST_DATA ---> LOAD_DATA ---> LOAD_PARITY ---> 
                   //  CHECK_PARITY_ERROR ---> FIFO_FULL_STATE --->  LOAD_AFTER_FULL ---> DECODE_ADDRESS[LOOP]
  begin 
    @(negedge clk)
    pkt_valid = 1'b1;
    data_in = 2'b10;
    fifo_empty_2 = 1'b0;

    @(negedge clk)
    fifo_empty_2 = 1'b1;   // Unconditionally goes to load data 
    addr = 2;

    @(negedge clk)
    fifo_full = 1'b0;
    pkt_valid = 1'b0;    //Unconditionally goes to check parity error 

   @(negedge clk)
    fifo_full = 1'b1;

    @(negedge clk)
    fifo_full = 1'b0;

    @(negedge clk)
    parity_done = 1'b0;    
  end 
  endtask 

  initial 
  begin
    reset_uut();
    //initialize();
    t1();
    t2();
    t3();
    #500;
    $finish;
  end 

endmodule