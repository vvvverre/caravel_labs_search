`timescale 1ns / 1ps
`default_nettype none

module calc_ck #
(
    parameter SEQ_WIDTH = 8
)
(
    input  wire                     clk,
    input  wire                     rst,

    input  wire [SEQ_WIDTH-1:0]     a,
    input  wire [SEQ_WIDTH-1:0]     b,
    output reg  [7:0]               z
);

initial begin
    z = 0;
end

always_ff @(posedge clk) begin
    if (rst) begin
        z <= 0;
    end else begin
        logic [7:0] temp;
        temp = 0;
        for (int i = 0; i < SEQ_WIDTH; i++) begin
            if (a[i] == b[i]) begin
                temp = temp + 1;
            end else begin
                temp = temp - 1;
            end
        end

        z <= temp;
    end
end

endmodule

`default_nettype wire
