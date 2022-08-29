`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps
`default_nettype none

module tb_calc_e_buf;

    localparam period = 10;
    localparam hperiod = period/2;

    localparam SEQ_WIDTH = 30;
    localparam E_WIDTH = 20;
    localparam STAGE_WIDTH = 10;

    reg clk;
    reg rst;

    reg [SEQ_WIDTH-1:0] i_seq;
    reg [SEQ_WIDTH-1:0] i_mask;
    reg [6:0] i_offset;
    reg i_valid;
    reg i_ready;

    wire [E_WIDTH-1:0] o_e;
    wire o_valid;
    wire o_ready;

    calc_e_buf # (
        .SEQ_WIDTH(SEQ_WIDTH),
        .STAGE_WIDTH(STAGE_WIDTH),
        .E_WIDTH(E_WIDTH)
    ) UUT (
        .clk(clk), 
        .rst(rst),
        .i_seq(i_seq), 
        .i_offset(i_offset),
        .i_mask(i_mask),
        .i_valid(i_valid),
        .i_ready(i_ready),
        .o_ready(o_ready),
        .o_e(o_e), 
        .o_valid(o_valid)
    );

    always #hperiod clk = ~clk;

    initial begin
        $dumpfile("tb_calc_e_buf.vcd");
        $dumpvars(0,tb_calc_e_buf);

        clk = 1'b0;
        rst = 1'b0;

        i_valid = 1'b0;
        i_ready = 1'b1;

        i_seq = 0;
        i_mask = 0;
        i_offset = 0;

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
        
        i_offset = 6'd10;
        i_mask = 30'hFFFFF;
        i_valid = 1;
        
        i_seq = 20'h0BEEF;
        #period;
        
        i_seq = 20'h0BEF0;
        #period;

        i_seq = 20'h0BEF1;
        #period;

        i_seq = 20'h0BEF2;
        #period;

        i_valid = 0;
        
        wait (o_valid);
        
        for (int ii = 0; ii < 100; ii++)
            #period;

        $finish();
    end

endmodule

`default_nettype wire
