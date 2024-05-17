`default_nettype none
`timescale 1ns/1ps

/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

// testbench is controlled by test.py
module tb_sqrt ();

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("tb.vcd");
        $dumpvars (0, tb_sqrt);
        #1;
    end

    // wire up the inputs and outputs
    reg             clk;
    reg             reset;

    reg             start;
    reg [15 : 0]    x_in;

    wire            finish;
    wire [15 : 0]   x_out;

    sqrt_pipe #(.BIT_WIDTH(16)) sqrt_pipe (
        .clk(clk),
        .reset(reset),

        .x_in(x_in),
        .start(start),
        
        .x_out(x_out),
        .finish(finish)
    );

endmodule
