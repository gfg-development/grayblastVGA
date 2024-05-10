/* The top-level of a small gray scale GPU for TinyTapeout.
 * It will use the RP2040 as frame buffer.
 *
 * -----------------------------------------------------------------------------
 *
 * Copyright (c) 2024 Gerrit Grutzeck (g.grutzeck@gfg-development.de)
 * SPDX-License-Identifier: Apache-2.0
 *
 * -----------------------------------------------------------------------------
 *
 * Author   : Gerrit Grutzeck g.grutzeck@gfg-development.de
 * File     : grayblastvga.v
 * Create   : Mai 10, 2024
 * Revise   : Mai 10, 2024
 * Revision : 1.0
 *
 * -----------------------------------------------------------------------------
 */

`default_nettype none

module tt_um_gfg_development_grayblastvga (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    // all output pins must be assigned. If not used, assign to 0.
    // assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // synchronize the reset
    reg [2:0] latch_reset_n;
    always @(posedge clk) begin
        latch_reset_n   <= {latch_reset_n[1:0], rst_n};  
    end

    wire reset_n;
    assign reset_n = latch_reset_n[2];

    // the component to generate the VGA signals and read from the framebuffer
    vga vga(
        .clk(clk),
        .rst_n(reset_n),

        .pixel_div(pixel_div),

        .v_sync_out(uo_out[0]),
        .h_sync_out(uo_out[1]),
        .gray_out(uo_out[5:2]),

        .frame_next_pixel_out(uo_out[6]),
        .frame_reset_out(uo_out[7]),
        .frame_pixel_in(ui_in[7:4])
    );

    // register to select pixel divider
    reg [3:0] pixel_div;
    always @(posedge clk) begin
        if (ui_in[7] == 1) begin
            pixel_div   <= ui_in[3:0];
        end
    end

    // test register to extrapolate needed size for register
    reg [135:0] registers;
    always @(posedge clk) begin
        registers <= {registers[134:0], uio_in[0]};
    end
    assign uio_out = registers[134:127];

endmodule
