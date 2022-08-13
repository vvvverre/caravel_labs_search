`timescale 1ns / 1ps
`default_nettype none

module gen_mask #
(
    parameter SEQ_WIDTH = 40
)
(
    input  wire                     clk,
    input  wire                     rst,
    
    input  wire [6:0]               i_offset,
    output reg  [SEQ_WIDTH-1:0]     o_mask    
);

integer ii;
integer idx;

always @(posedge clk) begin
    if (rst) begin
        o_mask <= {(SEQ_WIDTH){1'b0}};
    end else begin
        for (ii = 0; ii < SEQ_WIDTH; ii++) begin
            idx = SEQ_WIDTH - 1 - ii;
            o_mask[idx] <= !(i_offset > ii);
        end
    end
end

endmodule

`default_nettype wire
