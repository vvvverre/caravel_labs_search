`timescale 1ns / 1ps
`default_nettype none


module wb_find #
(
    parameter BASE_ADR = 32'h 3000_0000,

    parameter SEQ_WIDTH = 8,
    parameter E_WIDTH = 16,

    parameter STAGE_WIDTH = 20,
    parameter PARALLEL_UNITS = 2
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

wire [SEQ_WIDTH-1:0]        seq [PARALLEL_UNITS-1:0];
wire [E_WIDTH-1:0]          e [PARALLEL_UNITS-1:0];
wire [PARALLEL_UNITS-1:0]   done;

wire                        soft_reset;

wire [PARALLEL_UNITS*72-1:0]            seq_packed;
wire [PARALLEL_UNITS*E_WIDTH-1:0]       e_packed;


wb_interface # (
    .BASE_ADR(BASE_ADR),

    .SEQ_WIDTH(SEQ_WIDTH),
    .E_WIDTH(E_WIDTH),

    .PARALLEL_UNITS(PARALLEL_UNITS)
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
    
    .i_seq(seq_packed),
    .i_e(e_packed),
    .i_done(done)
);


genvar ii;
generate
    for (ii = 0; ii < PARALLEL_UNITS; ii = ii + 1) begin
        find # (
            .SEQ_WIDTH(SEQ_WIDTH),
            .FIX_WIDTH($clog2(PARALLEL_UNITS)),
            .FIX_SEQ(ii),
            .STAGE_WIDTH(STAGE_WIDTH),
            .E_WIDTH(E_WIDTH)
        ) inst_find_ii (
            .clk(wb_clk_i),
            .rst(wb_rst_i | soft_reset),

            .o_seq(seq[ii]),
            .o_e(e[ii]),
            .o_done(done[ii])
        );

        assign e_packed[(ii+1)*E_WIDTH-1:ii*E_WIDTH] = e[ii];
        assign seq_packed[ii*72 + SEQ_WIDTH-1:ii*72] = seq[ii];
        assign seq_packed[(ii+1)*72-1:ii*72+SEQ_WIDTH] = 0;
    end
endgenerate

//assign e_packed = {e[1], e[0]};

endmodule

`default_nettype wire
