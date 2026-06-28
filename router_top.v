`timescale 1ns/1ps

module router_top(
input clock,resetn,
input read_en_0,
input read_en_1,
input read_en_2,
input [7:0]data_in,
input pkt_valid,

output [7:0]data_out_0,
output [7:0]data_out_1,
output [7:0]data_out_2,
output valid_out_0,
output valid_out_1,
output valid_out_2,
output error,busy
);
wire [2:0]write_en;
wire [7:0]data_out;

router_fsm FSM(
            .clock(clk),
            .resetn(rst_n),
            .pkt_valid(pkt_valid),
            .parity_done(parity_done),
            .data_in(data_in[1:0]),
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
            .lfd_state(.lfd_state)
);

router_sync synchroniser(
             .clk(clock),
             .rst_n(resetn),
             .detect_add(detect_add),
             .data_in(data_in[1:0]),
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
             .write_en(write_en[2:0]),
             .valid_out_0(valid_out_0),
             .valid_out_1(valid_out_1),
             .valid_out_2(valid_out_2),
             .fifo_full(fifo_full),
             .soft_rst_0(soft_rst_0),
             .soft_rst_1(soft_rst_1),
             .soft_rst_2(soft_rst_2)
);

router_register Register(
             .clk(clock),
             .rst_n(resetn),
             .pkt_valid(pkt_valid),
             .data_in(data_in[7:0]),
             .fifo_full(fifo_full),
             .rst_int_reg(rst_int_reg),
             .detect_add(.detect_add),
             .ld_state(ld_state),
             .laf_state(laf_state),
             .lfd_state(lfd_state),
             .full_state(full_state),
             .parity_done(parity_done),
             .low_pkt_valid(low_pkt_valid),
             .err(err),
             .data_out(data_out)
);

router_fifo FIFO_0(
             .clk(clock),
             .rst_n(resetn),
             .soft_rst(soft_rst_0),
             .rd_en(read_en_0),
             .wr_en(wr_en_0),
             .data_in(data_out),
             .lfd_state(lfd_state),
             .empty(fifo_empty_0),
             .data_out(data_out_0),
             .full(full_0)
);

router_fifo FIFO_1(
             .clk(clock),
             .rst_n(resetn),
             .soft_rst(soft_rst_1),
             .rd_en(read_en_1),
             .wr_en(wr_en_1),
             .data_in(data_out),
             .lfd_state(lfd_state),
             .empty(fifo_empty_1),
             .data_out(data_out_1),
             .full(full_1)
);

router_fifo FIFO_2(
             .clk(clock),
             .rst_n(resetn),
             .soft_rst(soft_rst_2),
             .rd_en(read_en_2),
             .wr_en(wr_en_0),
             .data_in(data_out),
             .lfd_state(lfd_state),
             .empty(fifo_empty_2),
             .data_out(data_out_2),
             .full(full_2)
);

endmodule 