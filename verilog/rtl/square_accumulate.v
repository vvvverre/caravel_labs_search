`timescale 1ns / 1ps
`default_nettype none

module square_accumulate #
(
    parameter Z_WIDTH = 16
)
(
    input  wire                 clk,
    input  wire                 rst,

    input  wire [7:0]           a,
    input  wire [Z_WIDTH-1:0]   b,
    output reg  [Z_WIDTH-1:0]   z
);

initial begin
    z = 0;
end

wire signed [15:0] s;

assign s = {{8{a[7]}}, a};

always @(posedge clk)
    if (rst)
        z <= 0;
    else
        z <= $unsigned(s * s) + b;

endmodule

`default_nettype wire
