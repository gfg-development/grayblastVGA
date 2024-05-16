# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, First

@cocotb.test()
async def test_sync_aligment(dut):
    dut._log.info("Start")

    # Set the clock period to 25 ns (40 MHz)
    clock = Clock(dut.clk, 25, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.rst_n.value         = 0
    dut.pixel_div.value     = 9
    dut.frame_pixel.value   = 1
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value         = 1

    # Measure v_sync length
    await RisingEdge(dut.v_sync)

    for _ in range(2):
        for clock_counter in range(628 * 1056):
            await ClockCycles(dut.clk, 1)

            # Check v_sync
            assert dut.v_sync.value == (1 if clock_counter < 4 * 1056 else 0), "VSync: {} at {}".format(dut.v_sync.value, clock_counter)

            # Check h_sync
            assert dut.h_sync.value == (1 if clock_counter % 1056 < 128 else 0), "HSync: {} at {}".format(dut.h_sync.value, clock_counter)

            # Check gray value
            assert dut.gray.value == (1 if (clock_counter / 1056 >= 27 and clock_counter / 1056 < 627) and (clock_counter % 1056 >= 216 and clock_counter % 1056 < 1016) else 0), "Gray: {} at {}".format(dut.gray.value, clock_counter)



async def frame_buffer(frame, pixel, next_pixel, frame_reset):
    ptr = 0
    while True:
        pixel.value = frame[ptr]
        ptr = (ptr  + 1) % len(frame)

        await First(RisingEdge(next_pixel), RisingEdge(frame_reset))

        if frame_reset.value == 1:
            ptr = 0
           


@cocotb.test()
async def test_pixel_value_position_horizontal(dut):
    PIXEL_DIV = 10
    dut._log.info("Start")

    # Set the clock period to 25 ns (40 MHz)
    clock = Clock(dut.clk, 25, units="ns")
    cocotb.start_soon(clock.start())
    
    frame = []
    for _ in range(600):
        for x in range(800 // PIXEL_DIV):
            frame.append(x % 16)
    cocotb.start_soon(frame_buffer(frame, dut.frame_pixel, dut.next_pixel, dut.frame_reset))

    # Reset
    dut._log.info("Reset")
    dut.rst_n.value         = 0
    dut.pixel_div.value     = PIXEL_DIV - 1
    dut.frame_pixel.value   = 1
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value         = 1

    # Measure v_sync length
    await RisingEdge(dut.v_sync)

    expected_gray = 0
    for _ in range(2):
        for clock_counter in range(628 * 1056):
            await ClockCycles(dut.clk, 1)

            # Check gray value
            assert dut.gray.value == (expected_gray // PIXEL_DIV) % 16, "Gray: {} != {} at {}".format((expected_gray // PIXEL_DIV) % 16, dut.gray.value, clock_counter)

            # Increment at each valid pixel position
            if (clock_counter / 1056 >= 27 and clock_counter / 1056 < 627) and (clock_counter % 1056 >= 216 and clock_counter % 1056 < 1016):
                expected_gray += 1
            else:
                expected_gray = 0



@cocotb.test()
async def test_pixel_value_position_vertical(dut):
    PIXEL_DIV = 10
    dut._log.info("Start")

    # Set the clock period to 25 ns (40 MHz)
    clock = Clock(dut.clk, 25, units="ns")
    cocotb.start_soon(clock.start())
    
    frame = []
    for y in range(600):
        for _ in range(800 // PIXEL_DIV):
            frame.append(y % 16)
    cocotb.start_soon(frame_buffer(frame, dut.frame_pixel, dut.next_pixel, dut.frame_reset))

    # Reset
    dut._log.info("Reset")
    dut.rst_n.value         = 0
    dut.pixel_div.value     = PIXEL_DIV - 1
    dut.frame_pixel.value   = 1
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value         = 1

    # Measure v_sync length
    await RisingEdge(dut.v_sync)

    expected_gray = 0
    for _ in range(2):
        for clock_counter in range(628 * 1056):
            await ClockCycles(dut.clk, 1)

            # Check gray value
            assert dut.gray.value == (expected_gray if (clock_counter / 1056 >= 27 and clock_counter / 1056 < 627) and (clock_counter % 1056 >= 216 and clock_counter % 1056 < 1016) else 0), "Gray: {} != {} at {}".format((expected_gray) % 16, dut.gray.value, clock_counter)

            # Increment at the end of each line
            if (clock_counter / 1056 >= 27 and clock_counter / 1056 < 627) and (clock_counter % 1056 == 1055):
                expected_gray = (expected_gray + 1) % 16

            # Reset pointer if VSync
            if dut.v_sync.value == 1:
                expected_gray = 0