`timescale 1ns / 1ps
`default_nettype none


module wb_interface_e #
(
    parameter BASE_ADR = 32'h 3000_0000,

    parameter SEQ_WIDTH = 8,
    parameter E_WIDTH = 16
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

    output wire [6:0]                           o_offset,

    output wire [SEQ_WIDTH-1:0]                 o_s00_seq,
    output reg                                  o_s00_valid,
    input  wire                                 i_s00_ready,

    input  wire [E_WIDTH-1:0]                   i_s00_e,
    input  wire                                 i_s00_valid,
    output wire                                 o_s00_ready,

    output wire [SEQ_WIDTH-1:0]                 o_s01_seq,
    output reg                                  o_s01_valid,
    input  wire                                 i_s01_ready,

    input  wire [E_WIDTH-1:0]                   i_s01_e,
    input  wire                                 i_s01_valid,
    output wire                                 o_s01_ready
);


reg [31:0] cfg_reg;

reg [63:0] seq_s00_reg;
reg [63:0] seq_s01_reg;

reg [E_WIDTH-1:0] e_s00_reg;
reg e_s00_reg_valid;

reg [E_WIDTH-1:0] e_s01_reg;
reg e_s01_reg_valid;

wire do_read, do_write;

assign o_rst = cfg_reg[31];
assign o_offset = cfg_reg[6:0];

assign o_s00_seq = seq_s00_reg[SEQ_WIDTH-1:0];
assign o_s01_seq = seq_s01_reg[SEQ_WIDTH-1:0];

assign do_read = wbs_cyc_i & wbs_stb_i & ~wbs_we_i & ~wbs_ack_o;
assign do_write = wbs_cyc_i & wbs_stb_i & wbs_we_i & ~wbs_ack_o;

always @(posedge wb_clk_i)
    wbs_ack_o <= ~wb_rst_i & wbs_cyc_i & wbs_stb_i;

assign o_s00_ready = ~wb_rst_i & ((do_read && wbs_adr_i == (BASE_ADR | 32'h0C)) | ~e_s00_reg_valid);
assign o_s01_ready = ~wb_rst_i & ((do_read && wbs_adr_i == (BASE_ADR | 32'h18)) | ~e_s01_reg_valid);


always @(posedge wb_clk_i) begin
    if (wb_rst_i) begin
        e_s00_reg <= 0;
        e_s00_reg_valid <= 1'b0;
    end else begin
        if (do_read && wbs_adr_i == (BASE_ADR | 32'h0C)) begin
            e_s00_reg_valid <= i_s00_valid;
            if (i_s00_valid)
                e_s00_reg <= i_s00_e;
        end else begin
            if (i_s00_valid && ~e_s00_reg_valid) begin
                e_s00_reg <= i_s00_e;
                e_s00_reg_valid <= 1'b1;
            end
        end
    end
end

always @(posedge wb_clk_i) begin
    if (wb_rst_i) begin
        e_s01_reg <= 0;
        e_s01_reg_valid <= 1'b0;
    end else begin
        if (do_read && wbs_adr_i == (BASE_ADR | 32'h18)) begin
            e_s01_reg_valid <= i_s01_valid;
            if (i_s01_valid)
                e_s01_reg <= i_s01_e;
        end else begin
            if (i_s01_valid && ~e_s01_reg_valid) begin
                e_s01_reg <= i_s01_e;
                e_s01_reg_valid <= 1'b1;
            end
        end
    end
end


always @(posedge wb_clk_i) begin
    if (wb_rst_i) begin
        wbs_dat_o <= 0;
    end else if (do_read) begin
        if (wbs_adr_i == (BASE_ADR | 32'h00)) 
            wbs_dat_o <= {28'b0, i_s01_ready, e_s01_reg_valid, i_s00_ready, e_s00_reg_valid};

        else if (wbs_adr_i == (BASE_ADR | 32'h04)) 
            wbs_dat_o <= {24'h0, SEQ_WIDTH};

        else if (wbs_adr_i == (BASE_ADR | 32'h08)) 
            wbs_dat_o <= cfg_reg;

        else if (wbs_adr_i == (BASE_ADR | 32'h0C)) 
            wbs_dat_o <= {{(32-E_WIDTH){1'b0}}, e_s00_reg[E_WIDTH-1:0]};
        
        else if (wbs_adr_i == (BASE_ADR | 32'h10))
            wbs_dat_o <= seq_s00_reg[31:0];
        
        else if (wbs_adr_i == (BASE_ADR | 32'h14))
            wbs_dat_o <= seq_s00_reg[63:32];

        else if (wbs_adr_i == (BASE_ADR | 32'h18)) 
            wbs_dat_o <= {{(32-E_WIDTH){1'b0}}, e_s01_reg[E_WIDTH-1:0]};
        
        else if (wbs_adr_i == (BASE_ADR | 32'h1C))
            wbs_dat_o <= seq_s01_reg[31:0];
        
        else if (wbs_adr_i == (BASE_ADR | 32'h20))
            wbs_dat_o <= seq_s01_reg[63:32];

        else 
            wbs_dat_o <= 0;
    end
end

always @(posedge wb_clk_i) begin
    if (wb_rst_i) begin
        cfg_reg <= 0;

        seq_s00_reg <= 0;
        o_s00_valid <= 1'b0;

        seq_s01_reg <= 0;
        o_s01_valid <= 1'b0;
    end else begin
        if (i_s00_ready)
            o_s00_valid <= 1'b0;

        if (i_s01_ready)
            o_s01_valid <= 1'b0;

        if (do_write) begin
            if (wbs_adr_i == (BASE_ADR | 32'h08)) begin
                if (wbs_sel_i[0])
                    cfg_reg[7:0] <= wbs_dat_i[7:0];
                if (wbs_sel_i[1])
                    cfg_reg[15:8] <= wbs_dat_i[15:8];
                if (wbs_sel_i[2])
                    cfg_reg[23:16] <= wbs_dat_i[23:16];
                if (wbs_sel_i[3])
                    cfg_reg[31:24] <= wbs_dat_i[31:24];

            end else if (wbs_adr_i == (BASE_ADR | 32'h10)) begin
                if (wbs_sel_i[0])
                    seq_s00_reg[7:0] <= wbs_dat_i[7:0];
                if (wbs_sel_i[1])
                    seq_s00_reg[15:8] <= wbs_dat_i[15:8];
                if (wbs_sel_i[2])
                    seq_s00_reg[23:16] <= wbs_dat_i[23:16];
                if (wbs_sel_i[3])
                    seq_s00_reg[31:24] <= wbs_dat_i[31:24];

                o_s00_valid <= 1'b1;

            end else if (wbs_adr_i == (BASE_ADR | 32'h14)) begin
                if (wbs_sel_i[0])
                    seq_s00_reg[39:32] <= wbs_dat_i[7:0];
                if (wbs_sel_i[1])
                    seq_s00_reg[47:40] <= wbs_dat_i[15:8];
                if (wbs_sel_i[2])
                    seq_s00_reg[55:48] <= wbs_dat_i[23:16];
                if (wbs_sel_i[3])
                    seq_s00_reg[63:56] <= wbs_dat_i[31:24];

            end else if (wbs_adr_i == (BASE_ADR | 32'h1C)) begin
                if (wbs_sel_i[0])
                    seq_s01_reg[7:0] <= wbs_dat_i[7:0];
                if (wbs_sel_i[1])
                    seq_s01_reg[15:8] <= wbs_dat_i[15:8];
                if (wbs_sel_i[2])
                    seq_s01_reg[23:16] <= wbs_dat_i[23:16];
                if (wbs_sel_i[3])
                    seq_s01_reg[31:24] <= wbs_dat_i[31:24];

                o_s01_valid <= 1'b1;

            end else if (wbs_adr_i == (BASE_ADR | 32'h20)) begin
                if (wbs_sel_i[0])
                    seq_s01_reg[39:32] <= wbs_dat_i[7:0];
                if (wbs_sel_i[1])
                    seq_s01_reg[47:40] <= wbs_dat_i[15:8];
                if (wbs_sel_i[2])
                    seq_s01_reg[55:48] <= wbs_dat_i[23:16];
                if (wbs_sel_i[3])
                    seq_s01_reg[63:56] <= wbs_dat_i[31:24];
            end
        end
    end
end

endmodule

`default_nettype wire
