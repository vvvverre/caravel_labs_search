`timescale 1ns / 1ps
`default_nettype none


module wb_interface #
(
    parameter BASE_ADR = 32'h 2000_0000,

    parameter SEQ_WIDTH = 8,
    parameter E_WIDTH = 16,
    
    parameter PARALLEL_UNITS = 4
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

    input wire [PARALLEL_UNITS*SEQ_WIDTH-1:0]   i_seq,
    input wire [PARALLEL_UNITS*E_WIDTH-1:0]     i_e,
    input wire [PARALLEL_UNITS-1:0]             i_done
);

localparam N_REGISTERS = 8*PARALLEL_UNITS;
localparam REG_WIDTH = $clog2(N_REGISTERS);

wire [REG_WIDTH-1:0] aword;
wire amatch;
reg [31:0] cfg_reg;
  
reg [$clog2(PARALLEL_UNITS*8)-1:0] temp;
reg [$clog2(PARALLEL_UNITS)-1:0] seq_idx;

assign amatch = (wbs_adr_i & (32'h FF00_0000)) == BASE_ADR;
assign aword = wbs_adr_i[REG_WIDTH+2-1:2];
assign o_rst = cfg_reg[0];

always @(posedge wb_clk_i)
    wbs_ack_o <= ~wb_rst_i & wbs_cyc_i & wbs_stb_i;

always @(posedge wb_clk_i) begin
    if (wb_rst_i) begin
        wbs_dat_o <= 0;
    end else if (wbs_cyc_i & wbs_stb_i & ~wbs_we_i) begin
        if (!amatch) begin
            wbs_dat_o <= 0;
        end else if (aword == 0) begin
            wbs_dat_o <= {{(32-PARALLEL_UNITS){1'b0}}, i_done};
        end else if (aword == 1) begin
            wbs_dat_o <= cfg_reg;
        end else if (aword < PARALLEL_UNITS) begin
            wbs_dat_o <= 0;
        end else if (aword < 2*PARALLEL_UNITS) begin
            wbs_dat_o <= {{(32-E_WIDTH){1'b0}}, i_e[aword-PARALLEL_UNITS]};
        end else if (aword < 4*PARALLEL_UNITS) begin
            wbs_dat_o <= 0;
        end else if (aword < 8*PARALLEL_UNITS) begin          
            temp = (aword[$clog2(PARALLEL_UNITS*8)-1:0] - 4 * PARALLEL_UNITS) / 4;
            seq_idx = temp[$clog2(PARALLEL_UNITS)-1:0];
            
            if (aword[1:0] == 2'b00) begin
                
                if (SEQ_WIDTH < 32) begin
                    wbs_dat_o <= {{(32-SEQ_WIDTH){1'b0}}, i_seq[seq_idx][SEQ_WIDTH-1:0]};
                end else begin
                    wbs_dat_o <= i_seq[seq_idx][31:0];
                end

            end else if (aword[1:0] == 2'b01) begin

                if (SEQ_WIDTH <= 32) begin
                    wbs_dat_o <= 0;
                end else if (SEQ_WIDTH < 63) begin
                    wbs_dat_o <= {{(64-SEQ_WIDTH){1'b0}}, i_seq[seq_idx][SEQ_WIDTH-1:32]};
                end else begin
                    wbs_dat_o <= i_seq[seq_idx][63:32];
                end
                
            end else if (aword[1:0] == 2'b10) begin

                if (SEQ_WIDTH <= 64) begin
                    wbs_dat_o <= 0;
                end else if (SEQ_WIDTH < 95) begin
                    wbs_dat_o <= {{(96-SEQ_WIDTH){1'b0}}, i_seq[seq_idx][SEQ_WIDTH-1:64]};
                end else begin
                    wbs_dat_o <= i_seq[seq_idx][95:64];
                end
                
            end else if (aword[1:0] == 2'b11) begin
                wbs_dat_o <= 0;
            end
        end else begin
            wbs_dat_o <= 0;
        end
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
