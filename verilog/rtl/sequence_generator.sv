`timescale 1ns / 1ps
`default_nettype none

module sequence_generator#
(
    parameter SEQ_WIDTH = 8,
    parameter FIX_WIDTH = 2,
    parameter FIX_SEQ = 0
)
(
    input  wire                     clk,
    input  wire                     rst,

    output reg  [SEQ_WIDTH-1:0]     o_seq,
    output reg                      o_done,
    output reg                      o_valid
);

localparam LIMIT = 2**(SEQ_WIDTH-FIX_WIDTH-2) - 1;
reg [SEQ_WIDTH-FIX_WIDTH-2-1:0] counter = 0;

initial begin
    o_done = 0;
    o_valid = 0;
end

always_ff @(posedge clk)
    if (rst)
        counter <= 0;
    else if (o_valid & (counter < LIMIT))
        counter <= counter + 1;
    

always_ff @(posedge clk)
    o_done <= (counter == LIMIT) & ~rst;

always_ff @(posedge clk)
    o_valid <= ~o_done & ~rst;

assign o_seq = {2'b0, FIX_WIDTH'(FIX_SEQ), counter};

endmodule

`default_nettype wire
