/* A single core of the GPU
 *
 * -----------------------------------------------------------------------------
 *
 * Copyright (c) 2024 Gerrit Grutzeck (g.grutzeck@gfg-development.de)
 * SPDX-License-Identifier: Apache-2.0
 *
 * -----------------------------------------------------------------------------
 *
 * Author   : Gerrit Grutzeck g.grutzeck@gfg-development.de
 * File     : core.v
 * Create   : Mai 11, 2024
 * Revise   : Mai 11, 2024
 * Revision : 1.0
 *
 * -----------------------------------------------------------------------------
 */

`default_nettype none

module core (
    /* Control signals */
    input  wire                             clk,                    // clock
    input  wire [13:0]                      opcode,                 // OP code to execute
    input  wire                             execute,

    /* Output signals */
    output wire                             accu_lsb
);

endmodule
