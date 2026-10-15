/*
 * Copyright (c) 2026 Pranav Sapkale
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_lift (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Unused IOs
    assign uio_out = 8'b0000_0000;
    assign uio_oe  = 8'b0000_0000;
    wire _unused = &{ena, ui_in[7:6], uio_in, 1'b0};

    // Input signal mapping
    wire [1:0] outsider_loc = ui_in[1:0];
    wire [1:0] insider_dest = ui_in[3:2];
    wire       outsider_dir = ui_in[4];
    wire       req_valid    = ui_in[5];

    // Internal wires
    wire [3:0] pending_mask;
    wire       clear_floor;
    wire [1:0] curr_floor;
    wire       motor_enable;
    wire       motor_dir;
    wire       dir_up_led;
    wire       dir_down_led;

    // Active-low reset inside submodules matches rst_n directly
    floor_tracker u_tracker (
        .clk       (clk),
        .rst       (rst_n),              
        .move_en   (motor_enable),
        .move_dir  (motor_dir),
        .curr_floor(curr_floor)
    );

    request_manager u_requests (
        .clk                 (clk),
        .rst                 (rst_n),
        .outsider_loc        (outsider_loc),
        .outsider_dir        (outsider_dir),
        .insider_destination (insider_dest),
        .req_valid           (req_valid),
        .curr_floor          (curr_floor),
        .clear_floor         (clear_floor),
        .pending_mask        (pending_mask)
    );

    lift_fsm u_fsm (
        .clk         (clk),
        .rst         (rst_n),
        .pending_mask(pending_mask),
        .curr_floor  (curr_floor),
        .motor_en    (motor_enable),
        .motor_dir   (motor_dir),
        .up_led      (dir_up_led),
        .down_led    (dir_down_led),
        .clear_floor (clear_floor)
    );

    // Output mapping
    assign uo_out[0]   = motor_enable;
    assign uo_out[1]   = motor_dir;
    assign uo_out[3:2] = curr_floor;
    assign uo_out[4]   = dir_up_led;
    assign uo_out[5]   = dir_down_led;
    assign uo_out[7:6] = 2'b00;

endmodule
