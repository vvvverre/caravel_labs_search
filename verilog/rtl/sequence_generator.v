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

    input  wire                     i_ready,
    input  wire [6:0]               i_offset,

    output wire [SEQ_WIDTH-1:0]     o_seq,
    output reg                      o_done,
    output reg                      o_valid
);

//localparam LIMIT = 2**(SEQ_WIDTH-FIX_WIDTH-2) - 1;
reg [SEQ_WIDTH-FIX_WIDTH-2:0] counter = 0;
reg [SEQ_WIDTH-FIX_WIDTH-2:0] limit = 0;
wire [FIX_WIDTH-1:0] fixed = FIX_SEQ;
reg running;

initial begin
    o_done = 0;
    o_valid = 0;
end

assign fixed = FIX_SEQ;

always @(posedge clk)
    if (rst)
        counter <= 0;
    else if (o_valid && i_ready && running && (counter < limit))
        counter <= counter + 1;

always @(posedge clk)
    if (rst)
        limit <= 0;
    else if (!running)
        limit <= 2**(SEQ_WIDTH-FIX_WIDTH-i_offset-2);
    
always @(posedge clk)
    if (rst)
        running <= 1'b0;
    else if (!running)
        running <= 1'b1;
    

always @(posedge clk)
    o_done <= (counter == limit) & running & ~rst;

always @(posedge clk)
    o_valid <= ~o_done & ~rst;

assign o_seq = {2'b0, fixed, counter};

endmodule

`default_nettype wire
