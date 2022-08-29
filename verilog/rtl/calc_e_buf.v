`timescale 1ns / 1ps
`default_nettype none

module calc_e_buf #
(
    parameter E_WIDTH = 20,
    parameter SEQ_WIDTH = 40,
    parameter STAGE_WIDTH = 20,
    parameter BUF_DEPTH = 8
)
(
    input  wire                     clk,
    input  wire                     rst,
    
    // Config
    input  wire [6:0]               i_offset,
    input  wire [SEQ_WIDTH-1:0]     i_mask,

    // Input bus
    input  wire [SEQ_WIDTH-1:0]     i_seq,
    input  wire                     i_valid,
    output wire                     o_ready,

    // Output bus
    output wire [E_WIDTH-1:0]       o_e,
    output reg                      o_valid,
    input  wire                     i_ready
);


wire fifo_inp_full, fifo_inp_empty;
wire fifo_out_full, fifo_out_empty;

wire [SEQ_WIDTH-1:0] ce_i_seq;
wire [E_WIDTH-1:0] ce_o_e;

wire ce_o_valid, ce_o_ready;
reg  ce_i_valid, ce_i_ready;
wire fifo_in_rd;

assign o_ready = ~rst & ~fifo_inp_full;

assign fifo_in_rd = (~ce_i_valid | (ce_i_valid & ce_o_ready)) & ~fifo_inp_empty & ~rst;

always @(posedge clk) begin
    if (rst) begin
        o_valid <= 1'b0;
    end else begin
        if (i_ready) 
            o_valid <= 1'b0;
        
        if ((~o_valid || i_ready) && ~fifo_out_empty)
            o_valid <= 1'b1;
    end 
end

always @(posedge clk) begin
    if (rst) begin
        ce_i_valid <= 1'b0;
    end else begin
        if (ce_o_ready)
            ce_i_valid <= 1'b0;
        
        if (fifo_in_rd)
            ce_i_valid <= 1'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        ce_i_ready <= 1'b0;
    end else begin
        ce_i_ready <= i_ready | ~o_valid | ~fifo_out_full;
    end
end

sync_fifo # (
    .DATA_WIDTH(SEQ_WIDTH),
    .FIFO_DEPTH(BUF_DEPTH)
) fifo_input (
    .clk(clk),
    .rst(rst),
    .en(1'b1),

    .data_in(i_seq),
    .wr(i_valid & ~fifo_inp_full),

    .data_out(ce_i_seq),
    .rd(fifo_in_rd),

    .full(fifo_inp_full),
    .empty(fifo_inp_empty)
);


calc_e_pl # (
    .E_WIDTH(E_WIDTH),
    .SEQ_WIDTH(SEQ_WIDTH),
    .STAGE_WIDTH(STAGE_WIDTH)
) inst_calc_e (
    .clk(clk),
    .rst(rst),

    .i_offset(i_offset),
    .i_mask(i_mask),

    .i_seq(ce_i_seq),
    .i_valid(ce_i_valid),
    .o_ready(ce_o_ready),

    .o_e(ce_o_e),
    .o_valid(ce_o_valid),
    .i_ready(ce_i_ready)
);

sync_fifo # (
    .DATA_WIDTH(E_WIDTH),
    .FIFO_DEPTH(BUF_DEPTH)
) fifo_output (
    .clk(clk),
    .rst(rst),
    .en(1'b1),

    .data_in(ce_o_e),
    .wr(ce_o_valid & ~fifo_out_full),

    .data_out(o_e),
    .rd((~o_valid | i_ready) & ~fifo_out_empty),

    .full(fifo_out_full),
    .empty(fifo_out_empty)
);


endmodule