`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps
`default_nettype none


module tb_gen_mask;

    localparam period = 10;
    localparam hperiod = period/2;

    localparam SEQ_WIDTH = 20;

    integer ii;

    reg clk;
    reg rst;
    
    reg [6:0] i_offset;
    reg [SEQ_WIDTH-1:0] o_mask;

    gen_mask # (
        .SEQ_WIDTH(SEQ_WIDTH)
    ) UUT (
        .clk(clk),
        .rst(rst),

        .i_offset(i_offset),
        .o_mask(o_mask)
    );

    always #hperiod clk = ~clk;

    initial begin
        $dumpfile("tb_gen_mask.vcd");
        $dumpvars(0, tb_gen_mask);

        clk = 1'b0;
        rst = 1'b0;


        i_offset = 6'd0;

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

        for (ii = 0; ii < 128; ii++) begin
            i_offset = ii;

            #period;
        end;


        #period;
        #period;
        #period;
        #period;

        $finish();
    end

endmodule

`default_nettype wire
