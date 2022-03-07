`timescale 1ns / 1ps
`default_nettype none

module calc_ck_pl #
(
    parameter SEQ_WIDTH = 40,
    parameter STAGE_WIDTH = 20
)
(
    input  wire                     clk,
    input  wire                     rst,

    input  wire [SEQ_WIDTH-1:0]     a,
    input  wire [SEQ_WIDTH-1:0]     b,
    output reg  [7:0]               z
);

localparam integer N_STAGES = $rtoi($ceil($itor(SEQ_WIDTH)/STAGE_WIDTH));
localparam integer LAST_STAGE_WIDTH = SEQ_WIDTH - (N_STAGES-1) * STAGE_WIDTH;

wire [7:0] t [N_STAGES-1:0];

initial begin
    z = 0;
end

genvar ii;
generate
    for (ii = 0; ii < N_STAGES-1; ii = ii + 1) begin
        calc_ck # (
            .SEQ_WIDTH(STAGE_WIDTH)
        ) inst_calc_ck_ii (
            .clk(clk), 
            .rst(rst),

            .a(a[STAGE_WIDTH*ii +: STAGE_WIDTH]),
            .b(b[STAGE_WIDTH*ii +: STAGE_WIDTH]),
            .z(t[ii])
        );
    end
endgenerate

calc_ck # (
    .SEQ_WIDTH(LAST_STAGE_WIDTH)
) inst_calc_ck_last (
    .clk(clk),
    .rst(rst),

    .a(a[SEQ_WIDTH-1 -: LAST_STAGE_WIDTH]),
    .b(b[SEQ_WIDTH-1 -: LAST_STAGE_WIDTH]),
    .z(t[N_STAGES-1])
);

reg [7:0] temp;
integer jj;

always @(posedge clk) begin
    if (rst) begin
        z <= 0;
    end else begin
        temp = 0;

        for (jj = 0; jj < N_STAGES; jj = jj + 1) begin
            temp = temp + t[jj];
        end

        z <= temp;
    end
end

endmodule

`default_nettype wire
