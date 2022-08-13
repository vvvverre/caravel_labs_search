`timescale 1ns / 1ps
`default_nettype none

module calc_e_pl #
(
    parameter E_WIDTH = 20,
    parameter SEQ_WIDTH = 40,
    parameter STAGE_WIDTH = 20
)
(
    input  wire                     clk,
    input  wire                     rst,
    
    input  wire [6:0]               i_offset,
    input  wire [SEQ_WIDTH-1:0]     i_mask,
    input  wire [SEQ_WIDTH-1:0]     i_seq,
    input  wire                     i_valid,
    input  wire                     i_ready,

    output reg  [E_WIDTH-1:0]       o_e,
    output reg  [SEQ_WIDTH-1:0]     o_seq,
    output reg                      o_valid,
    output reg                      o_ready
);

reg  [6:0]              counter;
reg  [SEQ_WIDTH-1:0]    mask, mask_cpy;
reg  [SEQ_WIDTH-1:0]    seq_cpy;
reg  [SEQ_WIDTH-1:0]    seq_a, seq_b;

wire [7:0]              wire_ck;
reg  [7:0]              sqa_in_a;
reg  [E_WIDTH-1:0]      sqa_in_b;
wire [E_WIDTH-1:0]      sqa_out;

wire                    load;
wire                    last;
reg                     active, active_dly;
reg                     done;
reg                     acc_reset;


assign load = i_valid & o_ready;
assign last = counter == (SEQ_WIDTH-1);

// assign o_ready = !active && (!done || i_ready);

always @* begin
    if (rst || acc_reset)
        sqa_in_b = 0;
    else
        sqa_in_b = sqa_out;
end 

always @* begin
    if (rst || acc_reset)
        sqa_in_a = 0;
    else
        sqa_in_a = wire_ck - counter;
end 

always @(posedge clk)
    if (rst)
        acc_reset <= 1'b0;
    else
        acc_reset <= !(active_dly);

always @(posedge clk) begin
    if (rst)
        counter <= 0;
    else if (load)
        counter <= i_offset;
    else if (active_dly && counter < SEQ_WIDTH)
        counter <= counter + 1;
end 

always @(posedge clk)
    if (rst)
        mask_cpy <= 0;
    else if (load)
        mask_cpy <= i_mask;

always @(posedge clk) begin
    if (rst)
        mask <= 0;
    else if (load)
        mask <= {i_mask[SEQ_WIDTH-1:2], 2'b0};
    else 
        mask <= {mask[SEQ_WIDTH-1-1:0], 1'b0};
end 

always @(posedge clk)
    if (rst)
        seq_a <= 0;
    else if (load)
        seq_a <= {i_seq[SEQ_WIDTH-1:1], 1'b0};
    else 
        seq_a <= seq_a & mask;

always @(posedge clk)
    if (rst)
        seq_b <= 0;
    else if (load)
        seq_b <= {i_seq[SEQ_WIDTH-1-1:0], 1'b0};
    else 
        seq_b <= {seq_b[SEQ_WIDTH-1-1:0], 1'b0} & mask_cpy;

always @(posedge clk)
    if (rst)
        active <= 1'b0;
    else if (load)
        active <= 1'b1;
    else if (done)
        active <= 1'b0;

always @(posedge clk)
    if (rst)
        active_dly <= 1'b0;
    else
        active_dly <= active;

always @(posedge clk)
    if (rst)
        done <= 1'b0;
    else if (last)
        done <= 1'b1;
    else
        done <= 1'b0;

always @(posedge clk)
    if (rst)
        o_e <= 0;
    else if (done)
        o_e <= sqa_out;

always @(posedge clk)
    if (rst)
        seq_cpy <= 0;
    else if (load)
        seq_cpy <= i_seq;

always @(posedge clk)
    if (rst)
        o_seq <= 0;
    else if (done)
        o_seq <= seq_cpy;

always @(posedge clk)
    if (rst)
        o_valid <= 1'b0;
    else if (done)
        o_valid <= 1'b1;
    else if (i_ready)
        o_valid <= 1'b0;

always @(posedge clk)
    if (rst)
        o_ready <= 1'b0;
    else if (load)
        o_ready <= 1'b0;
    else if ((!o_valid && !active) || (done && i_ready))
        o_ready <= 1'b1;



square_accumulate # (
    .Z_WIDTH(E_WIDTH)
) inst_sqa (
    .clk(clk),
    .rst(rst),

    .a(sqa_in_a),
    .b(sqa_in_b),
    .z(sqa_out)
);
    
calc_ck_split # (
    .SEQ_WIDTH(SEQ_WIDTH),
    .STAGE_WIDTH(STAGE_WIDTH)
) inst_calc_ck_split (
    .clk(clk),
    .rst(rst),

    .a(seq_a),
    .b(seq_b),
    .z(wire_ck)
);



endmodule

`default_nettype wire
