import math

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles


@cocotb.test()
async def test_sqrt(dut):
    dut._log.info("start")

    await Timer(1, 'ns')

    for i in range(2**16):
        dut.x_in.value = i
        await Timer(1, 'ns')
        assert dut.x_out.value.integer == int(math.floor(math.sqrt(i)))