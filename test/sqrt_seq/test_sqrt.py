import math

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles


@cocotb.test()
async def test_sqrt(dut):
    dut._log.info("Start")

    clock = Clock(dut.clk, 25, units="ns")
    cocotb.start_soon(clock.start())

    await RisingEdge(dut.clk)

    for i in range(2**16):
        dut.x_in.value      = i
        dut.start.value     = 1

        await ClockCycles(dut.clk, 1)

        dut.start.value     = 0

        await RisingEdge(dut.finish)
        assert dut.x_out.value.integer == int(math.floor(math.sqrt(i)))