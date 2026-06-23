module Internal_counter_fifo(
    input clk,rst_n,soft_rst,
    input rd_en,wr_en,
    input [7:0]data_in,
    input lfd_state,
    output reg [7:0]data_out,
    input empty,full
);
reg [8:0]mem[0:15];
 reg [6:0]counter;
 reg [4:0]rd_ptr,wr_ptr;

//--------------------------------------------------------------------------------------//s
// Payload length count logic 
always@(posedge clk)
if(rst_in)
    counter<=7'b0;
else if(soft_rst)
counter<=7'b0;
else if(read_en && (!empty))   // empty has high priority it will check first 
 if(mem[rd_ptr[3:0]][8]==1'b1)
count <= mem[rd_ptr[3:0]][7:2];
else if(count != 0)
     counter<=counter-1;
//--------------------------------------------------------------------------------------//

assign full=(wr_ptr  == {!rd_ptr[4],rd_ptr[3:0]});   //Full logic 
assign empty=(ed_ptr==wr_ptr);                       //empty logic 

//--------------------------------------------------------------------------------------//
//Read logic 

always@(posedge clk)
begin
    if(!rst_n)
    begin 
    data_out<=0;
    rd_ptr<=0;
    end 
    else if(soft_rst)
    begin 
    data_out<=8'hz;;
     rd_ptr<=0;
    end 
    else if(counter==0 && data_out!=0 )
    data_out<=8'hz;
    else if(read_en && !empty)
    begin
        data_out<=mem[rd_ptr[3:0]];
        rd_ptr<=rd_ptr+1;
    end  
end 

//--------------------------------------------------------------------------------------//
//Write logic 
always@(posedge clk)
begin
    if(!rst_n)
    begin
        wr_ptr<=0;
        for(i=0;i<16;i=i+1)
        mem[i] <= 0; 
    end  
    else if(soft_rst)
    begin
         wr_ptr<=0;
            for(i=0;i<16;i=i+1)
        mem[i] <= 0; 
    end 
    else if (write_en && !full)
    begin 
    mem[wr_ptr[3:0]] <= {lfd_state,data_in};
    wr_ptr<=wr_ptr+1;
    end 
end 
    endmodule  