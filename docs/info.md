<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Explain how your project works

1. Request manager (request_manager) Stores every pending call in three 4-bit registers (one bit per floor):

hall_up: up button pressed outside the lift on that floor
hall_down: down button pressed outside the lift on that floor
car_calls: destination button pressed inside the lift

When req_valid is high on a rising clock edge, the inputs are captured:

A hall call is stored at floor outsider_loc, in the up or down register depending on outsider_dir (1 = up, 0 = down). An up call at floor 3 and a down call at floor 0 are ignored, because they cannot exist.
A car call is stored at floor insider_destination.

One req_valid pulse registers both a hall call and a car call. The three registers are ORed together into a 4-bit pending_mask. When the lift is at a floor with a pending request, clear_floor goes high and that floor's bits are cleared on the next clock edge.

2. Lift FSM (lift_fsm) A three-state machine (IDLE, UP, DOWN) that decides where to go using pending_mask and the current floor:

It splits the pending requests into "at this floor", "above" and "below".
In IDLE it goes UP if any request is above, otherwise DOWN if any is below.
In UP it keeps going up while requests remain above, then turns around if requests are only below, otherwise returns to IDLE. DOWN works the same way in reverse. This is a simple scan-style policy that serves all requests in the current direction before reversing.
If there is a pending request at the current floor, the motor is disabled for that cycle (the lift "stops") and the request is cleared. Otherwise, the motor runs when there is a request in the direction of travel.
Outputs: motor_enable, motor_dir (1 = up), and two direction LEDs (dir_up_led in state UP, dir_down_led in state DOWN).

3. Floor tracker (floor_tracker) A 2-bit counter holding the current floor. While motor_enable is high it moves one floor per clock cycle in the direction of motor_dir, and it saturates at floor 0 and floor 3. It is reset to floor 0.

All state is reset by the active-low reset, which brings the lift back to floor 0 with no pending requests and the FSM in IDLE.

Simplifications: the lift moves one floor per clock cycle and has no door or timing model. The lift stops at a floor for any pending request there, regardless of the hall-call direction.
## How to test

Explain how to use your project

Apply a clock and pull reset low for a few cycles, then release it. The lift is at floor 0 (curr_floor_out = 00), and both direction LEDs are off.
To place a request, set:
outsider_loc[1:0]: floor where the call is made
outsider_dir: 1 for up, 0 for down
insider_dest[1:0]: destination floor chosen inside the lift
Then hold req_valid high for one clock cycle and lower it again.
Watch the outputs:
dir_up_led or dir_down_led turns on as the lift starts moving.
motor_enable is high while moving and low while stopped, with motor_dir showing the direction.
curr_floor_out counts the floors passed (one per clock).
When the lift reaches a requested floor, motor_enable drops for a cycle and the request is cleared. When all requests are served, the LEDs go off (IDLE).

Example: from floor 0, set outsider_loc = 01, outsider_dir = 1, insider_dest = 11 and pulse req_valid. The lift goes up to floor 1 and stops, then continues to floor 3, and returns to IDLE.

Suggested pin mapping (adjust it to match your project.v):

Pin	Signal
ui[1:0]	outsider_loc
ui[3:2]	insider_dest
ui[4]	outsider_dir
ui[5]	req_valid
uo[0]	motor_enable
uo[1]	motor_dir
uo[3:2]	curr_floor_out
uo[4]	dir_up_led
uo[5]	dir_down_led
rst_n	active-low reset
## External hardware

List external hardware used in your project (e.g. PMOD, LED display, etc), if any
No external hardware is required. For a hands-on demo you can optionally connect:

Push buttons or DIP switches to the input pins (floor select, direction and request valid)
LEDs on the output pins to show motor enable, direction, and the current floor in binary
Optionally a 7-segment display to show the current floor number
