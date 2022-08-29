`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps
`default_nettype none

module tb_wb_calc_e;

    localparam period = 10;
    localparam hperiod = period/2;

    localparam SEQ_WIDTH = 64;
    localparam E_WIDTH = 20;
    localparam STAGE_WIDTH = 10;

    reg clk;
    reg rst;

    reg wb_clk_i, wb_rst_i;
    reg wbs_stb_i, wbs_cyc_i;
    reg wbs_we_i, wbs_ack_o;
    reg [3:0] wbs_sel_i;
    reg [31:0] wbs_dat_i;
    reg [31:0] wbs_adr_i;
    reg [31:0] wbs_dat_o;

    reg [127:0] la_data_in;
    reg [127:0] la_oenb;

    assign wb_clk_i = clk;
    assign wb_rst_i = rst;

    assign la_data_in = 128'b0;
    assign la_oenb = 128'b0;

    wb_calc_e # (
        .SEQ_WIDTH(SEQ_WIDTH),
        .STAGE_WIDTH(STAGE_WIDTH),
        .E_WIDTH(E_WIDTH)
    ) UUT (
        .wb_clk_i(wb_clk_i), 
        .wb_rst_i(wb_rst_i),
        
        .wbs_stb_i(wbs_stb_i),
        .wbs_cyc_i(wbs_cyc_i),
        .wbs_we_i(wbs_we_i),

        .wbs_sel_i(wbs_sel_i),
        .wbs_dat_i(wbs_dat_i),
        .wbs_adr_i(wbs_adr_i),

        .wbs_dat_o(wbs_dat_o),
        .wbs_ack_o(wbs_ack_o),

        .la_data_in(la_data_in),
        .la_oenb(la_oenb)
    );

    always #hperiod clk = ~clk;

    initial begin
        $dumpfile("tb_wb_calc_e.vcd");
        $dumpvars(0, tb_wb_calc_e);

        clk = 1'b0;
        rst = 1'b0;
        
        wbs_stb_i = 1'b0;
        wbs_cyc_i = 1'b0;
        wbs_we_i = 1'b0;
        wbs_sel_i = 4'hF;
        wbs_dat_i = 32'b0;
        wbs_adr_i = 32'b0;

        #period;
        #period;
        #period;
        #period;

        rst = 1'b1;

        #period;
        #period;
        #period;
        #period;

        rst = 1'b0;

        wbs_adr_i <= 32'h3000_0008;
        wbs_dat_i <= 32'h8000_002C;
        wbs_stb_i <= 1'b1;
        wbs_cyc_i <= 1'b1;
        wbs_we_i <= 1'b1;

        wait (wbs_ack_o);

        wbs_adr_i <= 32'h3000_0008;
        wbs_dat_i <= 32'h0000_002C;

        #period;
        wait (wbs_ack_o);

        wbs_adr_i <= 32'h3000_0010;
        wbs_dat_i <= 32'h0000_BEEF;

        #period;
        wait (wbs_ack_o);

        wbs_dat_i <= 32'h0000_BEF0;

        #period;
        wait (wbs_ack_o);

        wbs_dat_i <= 32'h0000_BEF1;

        #period;
        wait (wbs_ack_o);

        wbs_dat_i <= 32'h0000_BEF2;

        #period;
        wait (wbs_ack_o);

        wbs_stb_i <= 1'b0;
        wbs_cyc_i <= 1'b0;
        wbs_we_i <= 1'b0;

        
        // for (int ii = 0; ii < 500; ii++)
        //     #period;



        while (wbs_dat_o[0] == 1'b0) begin
            wbs_adr_i <= 32'h3000_0000;
            wbs_stb_i <= 1'b1;
            wbs_cyc_i <= 1'b1;
            #period;
        end

        wbs_adr_i <= 32'h3000_000C;

        wait (wbs_ack_o);
        #period;

        wbs_adr_i <= 32'h3000_0000;
        #period;

        while (wbs_dat_o[0] == 1'b0) begin
            #period;
        end

        wbs_adr_i <= 32'h3000_000C;

        wait (wbs_ack_o);
        #period;

        wbs_stb_i <= 1'b0;
        wbs_cyc_i <= 1'b0;
        

        
        for (int ii = 0; ii < 100; ii++)
            #period;


        $finish();
    end

endmodule

`default_nettype wire
