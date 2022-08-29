`timescale 1ns / 1ps
`default_nettype none


module wb_calc_e #
(
    parameter BASE_ADR = 32'h 3000_0000,

    parameter SEQ_WIDTH = 8,
    parameter E_WIDTH = 16,

    parameter STAGE_WIDTH = 8,
    parameter PARALLEL_UNITS = 1
)
(
    input           wb_clk_i,
    input           wb_rst_i,
    input           wbs_stb_i,
    input           wbs_cyc_i,
    input           wbs_we_i,
    input   [3:0]   wbs_sel_i,
    input   [31:0]  wbs_dat_i,
    input   [31:0]  wbs_adr_i,
    output          wbs_ack_o,
    output  [31:0]  wbs_dat_o,
    

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb
);


wire        soft_reset;

wire ce_i_valid, ce_o_ready;
wire ce_o_valid, ce_i_ready;
wire [SEQ_WIDTH-1:0] ce_i_seq;
wire [E_WIDTH-1:0] ce_o_e;

wire [SEQ_WIDTH-1:0] mask;
wire [6:0] offset;


gen_mask # (
    .SEQ_WIDTH(SEQ_WIDTH)
) inst_gen_mask (
    .clk(wb_clk_i),
    .rst(wb_rst_i),

    .i_offset(offset),
    .o_mask(mask)
);


calc_e_buf # (
    .SEQ_WIDTH(SEQ_WIDTH),
    .STAGE_WIDTH(STAGE_WIDTH),
    .E_WIDTH(E_WIDTH)
) inst_calc_e (
    .clk(wb_clk_i), 
    .rst(wb_rst_i | soft_reset),
 
    .i_offset(offset),
    .i_mask(mask),

    .i_seq(ce_i_seq),
    .i_valid(ce_i_valid),
    .o_ready(ce_o_ready),

    .o_e(ce_o_e), 
    .o_valid(ce_o_valid),
    .i_ready(ce_i_ready)
);

wb_interface_e # (
    .BASE_ADR(BASE_ADR),

    .SEQ_WIDTH(SEQ_WIDTH),
    .E_WIDTH(E_WIDTH)
) inst_wb_intf (
    .wb_clk_i(wb_clk_i),
    .wb_rst_i(wb_rst_i),

    .wbs_stb_i(wbs_stb_i),
    .wbs_cyc_i(wbs_cyc_i),

    .wbs_we_i(wbs_we_i),
    .wbs_sel_i(wbs_sel_i),

    .wbs_dat_i(wbs_dat_i),
    .wbs_adr_i(wbs_adr_i),

    .wbs_ack_o(wbs_ack_o),
    .wbs_dat_o(wbs_dat_o),

    .o_rst(soft_reset),
    
    .o_offset(offset),

    .o_seq(ce_i_seq),
    .o_valid(ce_i_valid),
    .i_ready(ce_o_ready),

    .i_e(ce_o_e),
    .i_valid(ce_o_valid),
    .o_ready(ce_i_ready)
);



endmodule

`default_nettype wire
