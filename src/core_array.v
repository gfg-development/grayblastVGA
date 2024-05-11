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
    parameter NR_CORES      = 4,
    parameter BIT_WIDTH     = 8
) (
    /* Control signals */
    input  wire                             clk,                    // clock
    input  wire [15:0]                      opcode,                 // OP code to execute
    input  wire                             execute,

    /* Output signals */
    output reg                              valid_bit,
    output reg                              output_bit
);

/* Global registers */
reg [BIT_WIDTH - 1 : 0] global_registers [0 : 8];

/* Handling the core specific commands */
reg [NR_CORES - 1 : 0] execute_core;
integer i;
always @(posedge clk) begin
    valid_bit                       <= 0;
    if (execute == 1) begin

        // Misc commands
        if (opcode[15:14] == 2'b11) begin
            /* Glboal store command */
            if (opcode[7] == 1) begin
                for (i = 0; i < NR_CORES; i++) begin
                    if (execute_core[i] == 1) begin
                        global_registers[opcode[13:9]]  <= accu_core[i][7 : 0]; 
                    end
                end
            end

            /* Core enable and disable */
            case (opcode[6:5])
                2'b01:
                    for (i = 0; i < NR_CORES; i++) begin
                        if (i[4:0] == opcode[13:9]) begin
                            execute_core[i] <= 1;
                        end
                    end
                2'b10:
                    execute_core                        <= {NR_CORES{1'b1}};
                default: begin end 
            endcase
        end
    end
end

/* Instanciate the cores */
wire [2 * BIT_WIDTH - 1 : 0] accu_core [0 : NR_CORES - 1];
generate
    genvar y;
    for (y = 0; y < NR_CORES; y++) begin
        core #(
            .CORE_ID(y),
            .BIT_WIDTH(BIT_WIDTH)
        ) core (
            .clk(clk),
            .opcode(opcode),
            .execute(execute_core[y] & execute),
            .accu(accu_core[y]),
            .global_registers_in(global_registers)
        );
    end
endgenerate

endmodule
