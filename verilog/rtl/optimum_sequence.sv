`timescale 1ns / 1ps
`default_nettype none

module optimum_sequence #
(
    parameter SEQ_WIDTH = 8,
    parameter E_WIDTH = 20
)
(
    input  wire                     clk,
    input  wire                     rst,

    input  wire [SEQ_WIDTH-1:0]     i_seq,
    input  wire [E_WIDTH-1:0]       i_e,
    input  wire                     i_valid,

    output reg  [SEQ_WIDTH-1:0]     o_seq,
    output reg  [E_WIDTH-1:0]       o_e
);

localparam LIMIT = 2**(SEQ_WIDTH-2) - 1;
reg [SEQ_WIDTH-2-1:0] counter = 0;

initial begin
    o_seq = 0;
    o_e = '1;
end

always_ff @(posedge clk) begin
    if (rst) begin
        o_seq <= 0;
        o_e <= '1;
    end else if (i_e < o_e && i_valid) begin
        o_seq <= i_seq;
        o_e <= i_e;
    end
end

endmodule

`default_nettype wire
