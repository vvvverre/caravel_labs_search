`timescale 1ns / 1ps
`default_nettype none


module wb_interface #
(
    parameter BASE_ADR = 32'h 3000_0000,

    parameter SEQ_WIDTH = 8,
    parameter E_WIDTH = 16,
    
    parameter PARALLEL_UNITS = 1
)
(
    input  wire                                 wb_clk_i,
    input  wire                                 wb_rst_i,
    input  wire                                 wbs_stb_i,
    input  wire                                 wbs_cyc_i,
    input  wire                                 wbs_we_i,
    input  wire [3:0]                           wbs_sel_i,
    input  wire [31:0]                          wbs_dat_i,
    input  wire [31:0]                          wbs_adr_i,
    output reg                                  wbs_ack_o,
    output reg  [31:0]                          wbs_dat_o,

    output wire                                 o_rst,

    input wire [PARALLEL_UNITS*72-1:0]          i_seq,
    input wire [PARALLEL_UNITS*E_WIDTH-1:0]     i_e,
    input wire [PARALLEL_UNITS-1:0]             i_done
);

localparam N_REGISTERS = 8*PARALLEL_UNITS;
localparam REG_WIDTH = $clog2(N_REGISTERS);

wire [REG_WIDTH-1:0] aword;
reg [31:0] cfg_reg;

assign o_rst = cfg_reg[0];

always @(posedge wb_clk_i)
    wbs_ack_o <= ~wb_rst_i & wbs_cyc_i & wbs_stb_i;

always @(posedge wb_clk_i) begin
    if (wb_rst_i) begin
        wbs_dat_o <= 0;
    end else if (wbs_cyc_i & wbs_stb_i & ~wbs_we_i) begin
        if (wbs_adr_i == (BASE_ADR | 32'h00)) 
            wbs_dat_o <= {{(32-PARALLEL_UNITS){1'b0}}, i_done};
        else if (wbs_adr_i == (BASE_ADR | 32'h04)) 
            wbs_dat_o <= cfg_reg;

        else if (wbs_adr_i == (BASE_ADR | 32'h08)) 
            wbs_dat_o <= {{(32-E_WIDTH){1'b0}}, i_e[E_WIDTH-1:0]};
            
        else if (wbs_adr_i == (BASE_ADR | 32'h10)) 
            wbs_dat_o <= i_seq[31:0];
        else if (wbs_adr_i == (BASE_ADR | 32'h14)) 
            wbs_dat_o <= i_seq[63:32];
        else if (wbs_adr_i == (BASE_ADR | 32'h18)) 
            wbs_dat_o <= {24'b0, i_seq[71:64]};
        else 
            wbs_dat_o <= 0;
    end
end

always @(posedge wb_clk_i) begin
    if (wb_rst_i) begin
        cfg_reg <= 0;
    end else if (wbs_cyc_i & wbs_stb_i & wbs_we_i) begin
        if (aword == 1) begin
            if (wbs_sel_i[0])
                cfg_reg[7:0] <= wbs_dat_i[7:0];
            if (wbs_sel_i[1])
                cfg_reg[15:8] <= wbs_dat_i[15:8];
            if (wbs_sel_i[2])
                cfg_reg[23:16] <= wbs_dat_i[23:16];
            if (wbs_sel_i[3])
                cfg_reg[31:24] <= wbs_dat_i[31:24];
        end
    end
end

endmodule

`default_nettype wire
