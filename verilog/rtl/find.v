`timescale 1ns / 1ps
`default_nettype none

module find #
(
    parameter SEQ_WIDTH = 8,
    parameter FIX_WIDTH = 2,
    parameter FIX_SEQ = 0,
    parameter STAGE_WIDTH = 20,
    parameter E_WIDTH = 20
)
(
    input  wire                     clk,
    input  wire                     rst,

    input  wire [6:0]               i_offset,

    output wire [SEQ_WIDTH-1:0]     o_seq,
    output wire [E_WIDTH-1:0]       o_e,
    output reg                      o_done
);

wire [SEQ_WIDTH-1:0] seq, seq2;
wire [SEQ_WIDTH-1:0] mask;
wire [E_WIDTH-1:0] e;
wire seq_valid, e_valid;
wire seq_done;
wire i_ready, o_ready;

assign i_ready = 1'b1;

gen_mask # (
    .SEQ_WIDTH(SEQ_WIDTH)
) inst_gen_mask (
    .clk(clk),
    .rst(rst),

    .i_offset(i_offset),
    .o_mask(mask)
);

sequence_generator # (
    .SEQ_WIDTH(SEQ_WIDTH), 
    .FIX_WIDTH(FIX_WIDTH), 
    .FIX_SEQ(FIX_SEQ)
) gen (
    .clk(clk),
    .rst(rst),

    .i_ready(o_ready),
    .i_offset(i_offset),

    .o_seq(seq),
    .o_valid(seq_valid),
    .o_done(seq_done)
);


calc_e_pl # (
    .SEQ_WIDTH(SEQ_WIDTH),
    .E_WIDTH(E_WIDTH),
    .STAGE_WIDTH(STAGE_WIDTH)
) calc (
    .clk(clk),
    .rst(rst),

    .i_offset(i_offset),
    .i_mask(mask),
    .i_seq(seq),
    .i_valid(seq_valid),
    .i_ready(i_ready),

    .o_seq(seq2),
    .o_e(e),
    .o_valid(e_valid),
    .o_ready(o_ready)
);

optimum_sequence # (
    .SEQ_WIDTH(SEQ_WIDTH), 
    .E_WIDTH(E_WIDTH)
) opt (
    .clk(clk),
    .rst(rst),
    
    .i_seq(seq2),
    .i_e(e),
    .i_valid(e_valid),
    .o_seq(o_seq), 
    .o_e(o_e)
);

always @(posedge clk)
    o_done <= seq_done & ~e_valid & ~rst;

endmodule

`default_nettype wire
