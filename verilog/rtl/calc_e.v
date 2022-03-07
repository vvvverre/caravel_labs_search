`timescale 1ns / 1ps
`default_nettype none

module calc_e #
(
    parameter SEQ_WIDTH = 8,
    parameter STAGE_WIDTH = 20,
    parameter E_WIDTH = 20
)
(
    input  wire                     clk,
    input  wire                     rst,

    input  wire [SEQ_WIDTH-1:0]     i_seq,
    input  wire                     i_valid,
    output wire [SEQ_WIDTH-1:0]     o_seq,
    output wire [E_WIDTH-1:0]       o_e,
    output wire                     o_valid
);

    reg [SEQ_WIDTH-1:0] pl_ina [SEQ_WIDTH+1:0];
    reg [SEQ_WIDTH-1:0] pl_inb [(SEQ_WIDTH-1)-1:0];
    reg pl_valid [SEQ_WIDTH+1:0];

    wire [7:0] pl_ck [(SEQ_WIDTH-1)-1:0];
    wire [E_WIDTH-1:0] pl_e [SEQ_WIDTH-1:0];


assign pl_e[0] = 0;
assign o_e = pl_e[SEQ_WIDTH-1];
assign o_valid = pl_valid[SEQ_WIDTH+1];
assign o_seq = pl_ina[SEQ_WIDTH+1];


genvar i;
generate for (i = 0; i < SEQ_WIDTH-1; i = i + 1) begin
    initial begin
        pl_inb[i] = 0;
    end
end endgenerate
generate for (i = 0; i < SEQ_WIDTH; i = i + 1) begin
    initial begin
        pl_ina[i] = 0;
        pl_valid[i] = 0;
    end
end endgenerate

generate for (i = 0; i < SEQ_WIDTH-1; i = i + 1) begin
    calc_ck_pl # (
        .SEQ_WIDTH(SEQ_WIDTH-1-i),
        .STAGE_WIDTH(STAGE_WIDTH)
    ) ck_stage (
        .clk(clk),
        .rst(rst),

        .a(pl_ina[i][SEQ_WIDTH-2-i:0]),
        .b(pl_inb[i][SEQ_WIDTH-2-i:0]),
        .z(pl_ck[i])
    );
    
    square_accumulate # (
        .Z_WIDTH(E_WIDTH)
    ) sqa_stage (
        .clk(clk),
        .rst(rst),

        .a(pl_ck[i]),
        .b(pl_e[i]),
        .z(pl_e[i+1])
    );
end endgenerate


always @* begin
    pl_ina[0] = i_seq & ~{(SEQ_WIDTH){rst}};
    pl_inb[0] = {1'b0, i_seq[SEQ_WIDTH-1:1]} & ~{(SEQ_WIDTH){rst}};
    pl_valid[0] = i_valid & ~rst;
end

generate for (i = 1; i < SEQ_WIDTH-1; i = i + 1) begin
    always @(posedge clk) begin
        pl_inb[i] <= {1'b0, pl_inb[i-1][SEQ_WIDTH-1:1]} & ~{(SEQ_WIDTH){rst}};
    end
end endgenerate

generate for (i = 1; i < SEQ_WIDTH + 2; i = i + 1) begin
    always @(posedge clk) begin
        pl_ina[i] <= pl_ina[i-1] & ~{(SEQ_WIDTH){rst}};
    end
end endgenerate

generate for (i = 1; i < SEQ_WIDTH + 2; i = i + 1) begin
    always @(posedge clk) begin
        pl_valid[i] <= pl_valid[i-1] & ~rst;
    end
end endgenerate

endmodule

`default_nettype wire
