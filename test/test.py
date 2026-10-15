# SPDX-FileCopyrightText: © 2026 Pranav Sapkale
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_lift_controller(dut):
    dut._log.info("Starting Smart Lift Controller Test")

    # 20 MHz clock -> period of 50 ns
    clock = Clock(dut.clk, 50, unit="ns")
    cocotb.start_soon(clock.start())

    # Initialize inputs
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    # Hold reset for 5 clock cycles
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    # Check reset state: lift at floor 0 (uo_out[3:2] == 00), not moving
    curr_floor = (dut.uo_out.value >> 2) & 0x3
    motor_enable = dut.uo_out.value & 0x1
    assert curr_floor == 0, f"Expected floor 0, got {curr_floor}"
    assert motor_enable == 0, f"Expected motor off initially, got {motor_enable}"

    # Request: insider destination = floor 2 (insider_dest = 2'b10, ui_in[3:2] = 2'b10)
    # outsider_loc = 0, outsider_dir = 0, req_valid = 1 (ui_in[5] = 1)
    # ui_in bits: [5]=req_valid(1), [4]=dir(0), [3:2]=dest(10), [1:0]=loc(00) -> 0b00101000 = 0x28
    dut.ui_in.value = 0x28
    await ClockCycles(dut.clk, 1)

    # Deassert req_valid
    dut.ui_in.value = 0x00

    # The lift should start moving UP (motor_enable=1, motor_dir=1, dir_up_led=1)
    # Let it run for a few cycles to transition and reach floor 2
    for _ in range(10):
        await ClockCycles(dut.clk, 1)
        curr_floor = (dut.uo_out.value >> 2) & 0x3
        if curr_floor == 2:
            break

    curr_floor = (dut.uo_out.value >> 2) & 0x3
    assert curr_floor == 2, f"Expected lift to reach floor 2, got {curr_floor}"

    # Wait another cycle for stop and clear
    await ClockCycles(dut.clk, 2)
    dut._log.info("Lift arrived at requested floor successfully.")
