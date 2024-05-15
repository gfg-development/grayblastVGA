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
    await FallingEdge(dut.v_sync)
    
    assert get_sim_time("ns") - start_v_sync == 105600

    for _ in range(600):
        # Measure h_sync length
        await RisingEdge(dut.h_sync)
        start_h_sync = get_sim_time("ns")
        await FallingEdge(dut.h_sync)
        assert get_sim_time("ns") - start_h_sync == 3200

        await ClockCycles(dut.clk, 87)
        assert dut.gray.value == 0

        for _ in range(800):
            await ClockCycles(dut.clk, 1)
            assert dut.gray.value == 1

        await ClockCycles(dut.clk, 0)
        assert dut.gray.value == 0

        # Measure length of line
        await RisingEdge(dut.h_sync)   
        assert get_sim_time("ns") - start_h_sync == 26400
    
    # Measure frame length
    await RisingEdge(dut.v_sync)    
    assert get_sim_time("ns") - start_v_sync == 16579200
