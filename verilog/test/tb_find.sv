`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps
`default_nettype none


module tb_find;

    localparam period = 10;
    localparam hperiod = period/2;

    localparam SEQ_WIDTH = 16;

    integer ii;

    reg clk;
    reg rst;
    wire [SEQ_WIDTH-1:0] o_seq;
    wire [19:0] o_e;
    wire o_done;
    reg [6:0] i_offset;

    find # (
        .SEQ_WIDTH(SEQ_WIDTH),
        .FIX_WIDTH(0)
    ) UUT (
        .clk(clk),
        .rst(rst),
        .i_offset(i_offset),
        .o_seq(o_seq),
        .o_e(o_e),
        .o_done(o_done)
    );

    always #hperiod clk = ~clk;

    initial begin
        $dumpfile("tb_find.vcd");
        $dumpvars(0, tb_find);

        i_offset <= 6'd0;

        clk <= 1'b0;
        rst <= 1'b1;

        #period;
        #period;
        #period;
        #period;

        rst <= 1'b0;

        i_offset <= 6'd0;

        #period;
        #period;
        #period;
        #period;

        wait (o_done);

        #period;
        $display(o_seq);
        $display(o_e);

        for (ii = 0; ii < 100; ii++) begin
            #period;
        end

        i_offset <= 6'd6;
        rst <= 1'b1;
        #period; #period;
        #period; #period;
        rst <= 1'b0;

        wait (o_done);

        #period;
        $display(o_seq);
        $display(o_e);

        for (ii = 0; ii < 100; ii++) begin
            #period;
        end

        $finish();
    end

endmodule

`default_nettype wire
