/* The core array for the GPU.
 *
 * -----------------------------------------------------------------------------
 *
 * Copyright (c) 2024 Gerrit Grutzeck (g.grutzeck@gfg-development.de)
 * SPDX-License-Identifier: Apache-2.0
 *
 * -----------------------------------------------------------------------------
 *
 * Author   : Gerrit Grutzeck g.grutzeck@gfg-development.de
 * File     : core_array.v
 * Create   : Mai 11, 2024
 * Revise   : Mai 11, 2024
 * Revision : 1.0
 *
 * -----------------------------------------------------------------------------
 */

`default_nettype none

module core_array #(
    parameter NR_CORES      = 4
) (
    /* Control signals */
    input  wire                             clk,                    // clock
    input  wire [13:0]                      opcode,                 // OP code to execute
    input  wire                             execute,

    /* Output signals */
    output reg                              valid_bit,
    output reg                              output_bit
);

/* Handling the core specific commands */
reg [NR_CORES - 1 : 0] execute_core;
integer i;
always @(posedge clk) begin
    valid_bit                       <= 0;
    if (execute == 1) begin
        if ((opcode[13] == 0) && (opcode[7:0] == 8'b10111111)) begin
            execute_core            <= 0;
            for (i = 0; i < NR_CORES; i++) begin
                if (i[4:0] == opcode[12:8]) begin
                    execute_core[i] <= 1;
                end
            end
        end

        if ((opcode[13] == 0) && (opcode[7:0] == 8'b11111111)) begin
            execute_core            <= {NR_CORES{1'b1}};
        end

        if ((opcode[13] == 0) && (opcode[7:0] == 8'b01111111)) begin
            valid_bit               <= 1;
            for (i = 0; i < NR_CORES; i++) begin
                if (i[4:0] == opcode[12:8]) begin
                    output_bit      <= accu_lsb_core[i];
                end
            end
        end
    end
end

/* Instanciate the cores */
wire [NR_CORES - 1 : 0] accu_lsb_core;
generate
    genvar y;
    for (y = 0; y < NR_CORES; y++) begin
        core core(
            .clk(clk),
            .opcode(opcode),
            .execute(execute_core[y] & execute),
            .accu_lsb(accu_lsb_core[y])
        );
    end
endgenerate

endmodule
