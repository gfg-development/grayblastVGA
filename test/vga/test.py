# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge
from cocotb.utils import get_sim_time

@cocotb.test()
async def test_durations(dut):
    dut._log.info("Start")

    # Set the clock period to 25 ns (40 MHz)
    clock = Clock(dut.clk, 25, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.rst_n.value = 0
    dut.pixel_div = 10
    dut.frame_pixel = 1
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # Measure v_sync length
    await RisingEdge(dut.v_sync)
    start_v_sync = get_sim_time("ns")

    for _ in range(2):
        for clock_counter in range(628 * 1056):
            await ClockCycles(dut.clk, 1)

            # Check v_sync
            assert dut.v_sync.value == (1 if clock_counter < 4 * 1056 else 0), "VSync: {} at {}".format(dut.v_sync.value, clock_counter)

            # Check h_sync
            assert dut.h_sync.value == (1 if clock_counter % 1056 < 128 else 0), "HSync: {} at {}".format(dut.h_sync.value, clock_counter)

            # Check gray value
            assert dut.gray.value == (1 if (clock_counter / 1056 >= 27 and clock_counter / 1056 < 627) and (clock_counter % 1056 >= 216 and clock_counter % 1056 < 1016) else 0), "Gray: {} at {}".format(dut.gray.value, clock_counter)
