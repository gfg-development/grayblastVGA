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

module core #(
    parameter CORE_ID       = 0,
    parameter BIT_WIDTH     = 8,
    parameter NR_LOCAL_REGS = 8
) (
    /* Control signals */
    input  wire                         clk,                    // clock
    input  wire [15:0]                  opcode,                 // OP code to execute
    input  wire                         execute,

    /* Global registers */
    input  wire [BIT_WIDTH - 1 : 0]     global_registers_in [0 : 8],

    /* Output signals */
    output wire [2 * BIT_WIDTH - 1 : 0] accu
);

reg [2 * BIT_WIDTH - 1 : 0] accumulator;
reg [BIT_WIDTH - 1 : 0]     local_registers [0 : NR_LOCAL_REGS - 1];

wire [BIT_WIDTH - 1 : 0]    registers [0 : 31];
assign registers[14]                    = 0;
assign registers[15]                    = CORE_ID[BIT_WIDTH - 1 : 0];
generate
    genvar i;
    for (i = 0; i < NR_LOCAL_REGS; i++) begin
        assign registers[i]             = local_registers[i];
    end
endgenerate

generate
    genvar y;
    for (y = 0; y < 9; y++) begin
        assign registers[y + 16]        = global_registers_in[y];
    end
endgenerate

wire [4:0] select_regs [0:1];
assign select_regs[0]   = opcode[13:9];
assign select_regs[1]   = {1'b0, opcode[8:5]};

wire [4:0] destination_reg;
assign destination_reg  = opcode[13:9];


wire [2 * BIT_WIDTH - 1 : 0] product;
assign product = registers[select_regs[0]] * registers[select_regs[1]];


wire [2 * BIT_WIDTH - 1 : 0] adder_inputs [1 : 0];
wire [2 * BIT_WIDTH - 1 : 0] adder_result;


generate
    genvar n;
    for (n = 0; n < 2; n++) begin
        assign adder_inputs[n] = (opcode[2 + n] == 0) ? 
            {{BIT_WIDTH{registers[select_regs[n]][BIT_WIDTH - 1]}}, registers[select_regs[n]]} : 
            accumulator;
        
    end
endgenerate
assign adder_result     = (opcode[0] == 0) ? (adder_inputs[0] + adder_inputs[1]) : (adder_inputs[0] - adder_inputs[1]);

always @(posedge clk) begin
    if (execute == 1) begin
        casez (opcode[15:14])
            2'b00:     // Load register
                begin
                    if (destination_reg < NR_LOCAL_REGS) begin
                        local_registers[destination_reg]        <= opcode[7:0];
                    end
                end

            2'b01:      // ALU operation with 2 operands
                begin
                    if (opcode[1] == 0) begin
                        accumulator                             <= adder_result;
                    end else begin
                        accumulator                             <= product;
                    end
                end

            2'b10:      // ALU operation with 0 or 1 operands
                begin
                end


            2'b11:      // Misc
                begin
                    /* Local store command */
                    if (opcode[8] == 1) begin
                        if (destination_reg < NR_LOCAL_REGS) begin
                            local_registers[destination_reg]    <= accumulator[7:0];
                        end
                    end
                end


        endcase
    end
end

assign accu         = accumulator;

endmodule
