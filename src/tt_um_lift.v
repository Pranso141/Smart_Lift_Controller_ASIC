`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.10.2026
// Design Name: 
// Module Name: smart_lift_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Top level. Only wiring: floor_tracker + request_manager + lift_fsm.
//              8 input pins, 6 output pins.
// 
// Dependencies: floor_tracker.v, request_manager.v, lift_fsm.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:

// 
//////////////////////////////////////////////////////////////////////////////////


module smart_lift_top(
input  wire       clk,
input  wire       rst,
input  wire [1:0] outsider_loc,
input  wire [1:0] insider_dest,
input  wire       outsider_dir,
input  wire       req_valid,
output wire       motor_enable,
output wire       motor_dir,
output wire [1:0] curr_floor_out,
output wire       dir_up_led,
output wire       dir_down_led
    );

    wire [3:0] pending_mask;
    wire       clear_floor;
    wire [1:0] curr_floor;




    floor_tracker u_tracker (
        .clk       (clk),
        .rst       (rst),              
        .move_en   (motor_enable),
        .move_dir  (motor_dir),
        .curr_floor(curr_floor)
    );


    request_manager u_requests (
        .clk                 (clk),
        .rst                 (rst),
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
        .rst         (rst),
        .pending_mask(pending_mask),
        .curr_floor  (curr_floor),
        .motor_en    (motor_enable),
        .motor_dir   (motor_dir),
        .up_led      (dir_up_led),
        .down_led    (dir_down_led),
        .clear_floor (clear_floor)
    );

    assign curr_floor_out = curr_floor;

endmodule
